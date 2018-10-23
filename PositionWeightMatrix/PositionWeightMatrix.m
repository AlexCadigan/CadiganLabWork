% Creates a new GUI window for the user to enter input and run the program
function varargout = PositionWeightMatrix(varargin)

% varargin      The input arguments

    % Begin initialization code - DO NOT EDIT
    
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @PositionWeightMatrix_OpeningFcn, ...
                       'gui_OutputFcn',  @PositionWeightMatrix_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    
    if nargin && ischar(varargin{1})
        
        gui_State.gui_Callback = str2func(varargin{1});
    
    end

    if nargout
        
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    
    else
        
        gui_mainfcn(gui_State, varargin{:});
        
    end
    
    % End initialization code - DO NOT EDIT

end

% Executes just before GUI is made visible
function PositionWeightMatrix_OpeningFcn(hObject, eventdata, handles, varargin)

% hObject       The handle to figure
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data
% varargin      Command line arguments to the GUI

    % Choose the default command line output for PositionWeightMatrix
    handles.output = hObject;

    % Update the handles structure
    guidata(hObject, handles);

end

% Outputs from this function are returned to the command line
function varargout = PositionWeightMatrix_OutputFcn(hObject, eventdata, handles) 

% varargout     A cell array for returning output args

% hObject       The handle to figure
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
end

% Executes when the PWMfasta button is pressed
function PWMfasta_Callback(hObject, eventdata, handles)

% hObject       The handle to PWMfasta
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Gets the filename and path chosen by the user and displays it in the static textbox
    [filename, path] = uigetfile({'*.fasta'}, 'Select the PWM fasta file');
    set(handles.PWMfastaSelect, 'string', fullfile(path, filename));

end

% Executes when the fastaData button is pressed
function fastaData_Callback(hObject, eventdata, handles)

% hObject       The handle to fastaData
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Gets the filename and path chosen by the user and displays it in the static textbox
    [filename, path] = uigetfile({'*.fasta'}, 'Select the fasta data file');
    set(handles.fastaDataSelect, 'string', fullfile(path, filename));

end

% Executes when the Reset button is pressed
function reset_Callback(hObject, eventdata, handles)

% hObject       The handle to reset
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Resets all the textboxes to default values
    set(handles.PWMfastaSelect, 'string', []);
    set(handles.fastaDataSelect, 'string', []);
    set(handles.simThresh, 'string', 5);

end

% Executes when the begin program button is pressed
function startButton_Callback(hObject, eventdata, handles)

% hObject       The handle to startButton
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Attempts to read the two fasta files selected by the user
    try

        % Reads the two fasta files
        PWMfasta = fastaread(get(handles.PWMfastaSelect, 'string'));
        fastaData = fastaread(get(handles.fastaDataSelect, 'string'));
        
    catch
        
        % Produces a messagebox with the error, resets the textboxes, and exits the program
        uiwait(msgbox('Error reading the fasta files.  Please try again.', 'error', 'modal'));
        set(handles.PWMfastaSelect, 'string', []);
        set(handles.fastaDataSelect, 'string', []);
        return;
        
    end

    % Gets the similarity threshold from the GUI
    simThresh = get(handles.simThresh, 'string');
    
    % Checks to see if the similarity threshold entered is invalid
    if isempty(str2num(simThresh))
        
        % Produces a messagebox with the error, resets the textbox, and exits the program
        uiwait(msgbox('Invalid entry for the similarity threshold.  Please enter only numbers', 'error', 'modal'));
        set(handles.simThresh, 'string', 5);
        return;
        
    end
    
    simThresh = str2double(simThresh);

    % Gets and stores the path to the .m file where the project is located
    mainDirectory = fileparts(mfilename('fullpath'));

    % Adds these files to the MATLAB path so the xlwrite function may be used
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-ooxml-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-ooxml-schemas-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'xmlbeans-2.3.0.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'dom4j-1.6.1.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'stax-api-1.0.1.jar'));

    % Builds the position weight matrix
    [PWM, numCols] = BuildPositionWeightMatrix(PWMfasta, handles);
    
    % Builds the structure to hold the results
    results = {'Sequence ID', 'PWM Score', 'Index Location of Sequence', 'Sequence'};
    
    % Runs through each sequence in the fasta file
    for seqNum = 1 : length(fastaData)
        
        % Runs through each character in the nucleotide sequence
        for index = 1 : length(fastaData(seqNum).Sequence) - (numCols - 1)

            % Determines the PWM score of the sequence
            score = determineScore(upper(fastaData(seqNum).Sequence(index: index + (numCols - 1))), PWM, numCols);

            % Checks to see if the sequence scored high enough and updates the results if it is
            if score >= simThresh

                results = [results; {fastaData(seqNum).Header, score, index, upper(fastaData(seqNum).Sequence(index: index + (numCols - 1)))}];
            
            end
        
        end
        
    end
    
    % Creates a timestamp
    dateMDY = datestr(now, 'mmmm dd, yyyy');
    dateH = datestr(now, 'HH');
    dateM = datestr(now, 'MM');
    dateS = datestr(now, 'SS');
    
    % Writes and opens an excel file containing the results
    xlwrite(fullfile(mainDirectory, 'Results', [dateMDY ' ' dateH '-' dateM '-' dateS]), results);
    system(['open "' fullfile(mainDirectory, 'Results', [dateMDY ' ' dateH '-' dateM '-' dateS '.xlsx"'])]);

end

% Determines the position weight matrix score of a given subsequence
function score = determineScore(sequence, PWM, numCols)

% score         The PWM score of the sequence

% sequence      The given nucleotide sequence
% PWM           The position weight matrix to use
% numCols       The number of columns in the fasta file

    score = 0;

    % Runs through each nucleotide in the sequence
    for index = 1 : length(sequence)

        % Calculates the column of the PWM matrix that should be appended
        matrixCol = mod(index, numCols);

        % Checks to see if the matrixCol is 0, which is not a valid column number
        if matrixCol == 0

           matrixCol = numCols;

        end
        
        % Determines which nucleotide is in the current index location and gets the correct score from the PWM
        if strcmpi(sequence(index), 'A')

            score = score + PWM(1, matrixCol);

        elseif strcmpi(sequence(index), 'C')

            score = score + PWM(2, matrixCol);

        elseif strcmpi(sequence(index), 'G')

            score = score + PWM(3, matrixCol);

        elseif strcmpi(sequence(index), 'T')

            score = score + PWM(4, matrixCol);
            
        else
            
            score = -Inf;

        end

    end

end

% ---------------------------------------------------------------------------------------------------
% BEGIN - Unused functions generated by GUIDE 

% Executes when there is a callback on the similarity threshold textbox
function simThresh_Callback(hObject, eventdata, handles)

% hObject       The handle to simThresh
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during the similarity threshold textbox creation after setting all properties.
function simThresh_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to simThresh
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% END - Unused functions generated by GUIDE 
% ---------------------------------------------------------------------------------------------------
