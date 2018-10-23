% Created by: Alex Cadigan, Abbey Roelofs
% Last modified: 11-29-2016

% Begins process of creating the GUI window
function varargout = PositionWeightMatrix(varargin)

% varargout     A cell array for returning output args

% varargin      The input arguments

    % Begin initialization code
    
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
    
    % End initialization code

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

% Executes when the begin program button is pressed
function beginButton_Callback(hObject, eventdata, handles)

% hObject       The handle to beginButton
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Stores the simularity threshold entered by the user
    simThresh = get(handles.simThresh, 'string');
    
    % Ensures the similarity threshold entered is an integer between 1 and 100
    if isemptsy(str2num(simThresh)) || str2double(simThresh) < 1 || str2double(simThresh) > 100
        
        % Alerts user to the error
        uiwait(msgbox('Invalid entry for similarity threshold.  Please enter only integer numbers between 1 and 100.', 'Error', 'modal'));
        set(handles.simThresh, 'string', 5);
        return;
        
    end
    
    simThresh = str2double(simThresh);
    
    % Stores the necleotide data to build the PWM
    PWMData = upper(get(handles.PWMData, 'string'));
    
    % Builds the PWM
    PWM = BuildPWM(PWMData);
    
    % Stores the raw nucleotide query data
    rawQueryData = upper(get(handles.QueryData, 'string'));
    
    % Stores the refined nucleotide query data
    queryData = '';
    
    % Goes through every character in the raw query data entered by the user
    for row = 1 : size(rawQueryData)
        
        for col = 1 : length(rawQueryData)
            
            % Checks if the current character is a valid nucleotide
            if ismember(rawQueryData(row, col), 'ACGT')
                
                % Adds the valid nucleotide to a string holding the sequence
                queryData = strcat(queryData, rawQueryData(row, col));
                
            end
            
        end
        
    end
    
    % Builds the structure to hold the results
    results = {'Sequence', 'Index Location of Sequence', 'PWM Score'};

    % Goes through all of the query data
    for index = 1 : length(queryData) - (length(PWM) - 1)
        
        % Determines the PWM score of the sequence
        score1 = detScore(queryData(index : index + (length(PWM) - 1)), PWM);
        
        % Checks to see if the sequence scored high enough be be flagged as output
        if score1 >= simThresh
            
            results = [results; {queryData(index : index + (length(PWM) - 1)), index, score1}];
            
        end
        
        % Creates the reverse complement of the current subsequence
        revComp = detRevComp(queryData(index : index + (length(PWM) - 1)));
        
        % Determines the PWM score of the reverse complement
        score2 = detScore(revComp, PWM);
        
        % Checks to see if the reverse complement scored high enough to be flagged as output
        if score2 >= simThresh
            
            results = [results; {queryData(index : index + (length(PWM) - 1)), index, score2}];
            
        end
        
    end
    
    % Creates a timestamp
    dateMDY = datestr(now, 'mmmm dd, yyyy');
    dateH = datestr(now, 'HH');
    dateM = datestr(now, 'MM');
    dateS = datestr(now, 'SS');
    
    % Gets the path to the .m file where the project is located
    mainDirectory = fileparts(mfilename('fullpath'));
    
    % Enables the xlwrite function to be used
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-ooxml-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-ooxml-schemas-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'xmlbeans-2.3.0.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'dom4j-1.6.1.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'stax-api-1.0.1.jar'));
    
    % Writes and opens an excel file containing the results
    xlwrite(fullfile(mainDirectory, 'Results', [dateMDY ' ' dateH '-' dateM '-' dateS]), results);
    system(['open "' fullfile(mainDirectory, 'Results', [dateMDY ' ' dateH '-' dateM '-' dateS '.xlsx"'])]);
    
end

% Initiates the building of the PWM
function PWM = BuildPWM(PWMData)

% PWM           The position weight matrix

% PWMData       The data used to build the PWM   

    % Creates the template of the matrix
    PFM = zeros(4, length(PWMData));

    % Goes through every row of the PWM data
    for row = 1 : size(PWMData, 1)
        
        % Goes through every column of the PWM data
        for col = 1 : length(PWMData)

            % Checks if current character is a valid nucleotide
            if ismember(PWMData(row, col), 'ACGT')
                
                % Determines which nucleotide position in the matrix to increment
                if strcmp(PWMData(row, col), 'A')
                    
                    PFM(1, col) = PFM(1, col) + 1;
                    
                elseif strcmp(PWMData(row, col), 'C')
                    
                    PFM(2, col) = PFM(2, col) + 1;
                    
                elseif strcmp(PWMData(row, col), 'G')
                    
                    PFM(3, col) = PFM(3, col) + 1;
                    
                else
                    
                    PFM(4, col) = PFM(4, col) + 1;
                    
                end

            end

        end
        
    end
    
    % Creates the position probability matrix
    PPM = PFM / size(PWMData, 1);

    % Creates the position weighted matrix
    PWM = log(PPM / 0.25);
    
end

% Determines the position weight matrix score of a given sequence
function score = detScore(sequence, PWM)

% score         The PWM score of the sequence

% sequence      The given nucleotide sequence
% PWM           The position weight matrix to use

    score = 0;
    
    % Goes through every character in the sequence
    for index = 1 : length(sequence)

        % Updates the score of the sequence
        if strcmp(sequence(index), 'A')
            
            score = score + PWM(1, index);
            
        elseif strcmp(sequence(index), 'C')
            
            score = score + PWM(2, index);
            
        elseif strcmp(sequence(index), 'G')
            
            score = score + PWM(3, index);
            
        else
            
            score = score + PWM(4, index);
            
        end
        
    end

end

% Determines the reverse complement of a given sequence
function revComp = detRevComp(sequence)

% revComp       The reverse complement of the sequence

% sequence      The given sequence to get the reverse complement of

    revComp = '';

    % Goes through every character in the sequence
    for index = length(sequence) : -1 : 1

        % Assigns each character to it's reverse compelement
        if strcmp(sequence(index), 'A')
            
            revComp = strcat(revComp, 'T');
            
        elseif strcmp(sequence(index), 'C')
            
            revComp = strcat(revComp, 'G');
            
        elseif strcmp(sequence(index), 'G')
            
            revComp = strcat(revComp, 'C');
            
        else
            
            revComp = strcat(revComp, 'A');
            
        end
        
    end

end

% Executes when the resetbutton button is pressed
function resetButton_Callback(hObject, eventdata, handles)

% hObject       The handle to resetButton
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Resets all fields to their default values
    set(handles.PWMData, 'string', []);
    set(handles.QueryData, 'string', []);
    set(handles.simThresh, 'string', 5);

end

% --------------------------------------------------------------------------------------------------------------------------
% BEGIN - Unused functions generated by GUIDE 

% Executes when there is a callback on the similarity threshold textbox
function simThresh_Callback(hObject, eventdata, handles)

% hObject       The handle to simThresh
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during the similarity threshold textbox creation after setting all properties
function simThresh_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to simThresh
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% Executes when there is a callback on the PWM data textbox
function PWMData_Callback(hObject, eventdata, handles)

% hObject       The handle to PWMData
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during PWM data textbox creation after setting all properties
function PWMData_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to PWMData
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% Executes when there is a callback on the query data textbox
function QueryData_Callback(hObject, eventdata, handles)

% hObject       The handle to QueryData
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during query data textobx creation after setting all properties
function QueryData_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to QueryData
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% END - Unused functions generated by GUIDE 
% --------------------------------------------------------------------------------------------------------------------------
