% Creates a new GUI window for the user to enter input and run the application
function varargout = CadiganProteomeSearch(varargin)

% varargin      The input arguments

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @CadiganProteomeSearch_OpeningFcn, ...
                       'gui_OutputFcn',  @CadiganProteomeSearch_OutputFcn, ...
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

% Executes just before the GUI is made visible.
function CadiganProteomeSearch_OpeningFcn(hObject, eventdata, handles, varargin)

% hObject       The handle to figure
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data
% varargin      Command line arguments to the GUI

    % Choose default command line output for CadiganProteomeSearch
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    
end

% Outputs from this function are returned to the command line.
function varargout = CadiganProteomeSearch_OutputFcn(hObject, eventdata, handles) 

% varargout     A cell array for returning output args

% hObject       The handle to figure
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
end

% Executes when the querySeqBtn button is pressed
function querySeqBtn_Callback(hObject, eventdata, handles)

% hObject       The handle to querySeqBtn
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Declares a global variable to keep track of type of query sequence entry
    global querySeqType;
    querySeqType = true;

    % Hides the fields for selecting a query file
    set(handles.textbox3, 'visible', 'off');
    set(handles.selectQueryFile, 'visible', 'off');
    set(handles.textbox4, 'visible', 'off');
    set(handles.windowSize, 'visible', 'off');
    
    % Shows the fields for manually entering a query sequence
    set(handles.textbox2, 'visible', 'on');
    set(handles.enterQuerySeq, 'visible', 'on');

    % Hides the querySeqBtn and shows the queryFileBtn
    set(handles.querySeqBtn, 'visible', 'off');
    set(handles.queryFileBtn, 'visible', 'on');

end

% Executes when the queryFileBtn button is pressed
function queryFileBtn_Callback(hObject, eventdata, handles)

% hObject       The handle to queryFileBtn
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Declares a global variable to keep track of type of query sequence entry
    global querySeqType;
    querySeqType = false;

    % Hides the fields for manually entering a query sequence
    set(handles.textbox2, 'visible', 'off');
    set(handles.enterQuerySeq, 'visible', 'off');
    
    % Shows the fields for selecting a query file
    set(handles.textbox3, 'visible', 'on');
    set(handles.selectQueryFile, 'visible', 'on');
    set(handles.textbox4, 'visible', 'on');
    set(handles.windowSize, 'visible', 'on');

    % Hides the queryFileBtn and shows the querySeqBtn
    set(handles.queryFileBtn, 'visible', 'off');
    set(handles.querySeqBtn, 'visible', 'on');

end

% Executes when the reset button is pressed
function reset_Callback(hObject, eventdata, handles)

% hObject       The handle to reset
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

    % Resets everything back to default values
    set(handles.querySeqBtn, 'visible', 'off');
    set(handles.queryFileBtn, 'visible', 'on');
    set(handles.textbox2, 'visible', 'on');
    set(handles.textbox3, 'visible', 'off');
    set(handles.enterQuerySeq, 'visible', 'on');
    set(handles.selectQueryFile, 'visible', 'off');
    set(handles.textbox4, 'visible', 'off');
    set(handles.windowSize, 'visible', 'off'); 
    set(handles.enterQuerySeq, 'string', []);
    set(handles.selectQueryFile, 'value', 1);
    set(handles.windowSize, 'string', []);
    set(handles.perSimThresh, 'string', []);
    set(handles.selectFastaFile, 'value', 1);

end

% Executes when the begin search button is pressed
function beginSearch_Callback(hObject, eventdata, handles)

% hObject       The handle to beginSearch
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data 

    % Adds files to the MATLAB path so the xlwrite function may be used and gets the main path to the project
    mainDirectory = addFiles();

    % Creates a reference array to help locate amino acid positions in the BLOSUM matrix 
    refArray = ['A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V', 'B', 'Z', 'X', '*'];
    
    % Defines a global variable used to determine which method of query data input was chosen
    global querySeqType;
    
    % Determines which method was used to enter the query data
    if querySeqType
        
        % Gets the query sequence entered by the user
        querySeq = upper(get(handles.enterQuerySeq, 'string'));
        
        % Runs through each character in the query sequence and makes sure it's a valid entry
        for aminoAcid = 1 : length(querySeq)
            
            % Makes sure the character is a valid amino acid
            if isempty(strfind(refArray, querySeq(aminoAcid)))
                
                % Informs the user that their input is invalid and exits the program
                uiwait(msgbox('Invalid entry for "Query Sequence".  Please enter only valid amino acids.', 'error', 'modal'));
                set(handles.enterQuerySeq, 'string', []);
                return;
                
            end
            
        end
        
        % Updates which file was read
        queryDataName = querySeq;
        
        % Updates the protein ID
        queryProteinID = 'None';
        
        % Gets the window size of the query sequence
        windowSize = length(querySeq);

    else
        
        % Gets the selected index from the selectQueryFile drop down box
        item = get(handles.selectQueryFile, 'value');

        % Determines which query fasta file to read
        switch item
            
            case 1
                
                % Reads in the fasta data and updates the variable storing which file was read
                queryFastaSeq = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'CompleteHumanProteome.fasta'));
                queryDataName = 'Complete Human Proteome';
                
            case 2
                
                % Reads in the fasta data and updates the variable storing which file was read
                queryFastaSeq = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'ECMProteins.fasta'));
                queryDataName = 'ECM Proteins';
                
            case 3
                
                % Reads in the fasta data and updates the variable storing which file was read
                queryFastaSeq = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'SecretedProteins.fasta'));
                queryDataName = 'Secreted Proteins';
                
            case 4
                
                % Reads in the fasta data and updates the variable storing which file was read
                queryFastaSeq = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'PlasmaMembraneProteins.fasta'));
                queryDataName = 'Plasma Membrane Proteins';
                
            case 5
                
                % Reads in the fasta data and updates the variable storing which file was read
                queryFastaSeq = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'Tiggrin.fasta'));
                queryDataName = 'Tiggrin';
                
            case 6
                
                % Reads in the fasta data and updates the variable storing which file was read
                queryFastaSeq = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'POSTN.fasta'));
                queryDataName = 'POSTN';
                
            otherwise
                
                % Attempts to read the user entered dataset
                try

                    % Gets the filename of the chosen file
                    [filename, pathname] = uigetfile({'*.fasta'}, 'Select .fasta file');

                    % Reads the user entered file
                    queryFastaSeq = fastaread(fullfile(pathname, filename));

                    % Updates the variable storing which file was read
                    queryDataName = filename;

                % Catches any errors in choosing and reading the file
                catch

                    % Produces a message box with the error
                    uiwait(msgbox('Error selecting or reading query fasta file.', 'error', 'modal'));
                    return;

                end
              
        end
        
        % Stores the amino acid sequence
        querySeq = queryFastaSeq.Sequence;
        
        % Updates the query protein ID
        queryProteinID = queryFastaSeq.Header;
        
        % Gets the percent similarity threshold from the GUI
        windowSize = get(handles.windowSize, 'string');

        % Checks to see if the percent similarity threshold entered is invalid
        if isempty(str2num(windowSize))

            % Creates a message box to inform the user that their input is invalid
            uiwait(msgbox('Invalid entry for "Window Size".  Please enter only numbers.', 'error', 'modal'));

            % Clears the percent similarity threshold field
            set(handles.windowSize, 'string', []);
            return;

        end
        
        % Converts from string to double for easy numeric calculations
        windowSize = str2double(windowSize);
        
    end
    
    % Gets the percent similarity threshold from the GUI
    perSimThresh = get(handles.perSimThresh, 'string');
    
    % Checks to see if the percent similarity threshold entered is invalid
    if isempty(str2num(perSimThresh))
       
        % Informs the user that their entry was invalid and exits the program
        uiwait(msgbox('Invalid entry for "Percent Similarity Threshold".  Please enter only numbers.', 'error', 'modal'));
        set(handles.perSimThresh, 'string', []);
        return;
        
    end
    
    % Converts from string to double for easy numeric calculations
    perSimThresh = str2double(perSimThresh);
    
    % Gets the index of whichever element was selected from the listbox
    item = get(handles.selectFastaFile, 'value');

    % Determines which FASTA file to read
    switch item

        case 1

            % Reads from the entire human proteome
            FastaData = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'CompleteHumanProteome.fasta'));

            % Updates the variable storing which file was read
            FastaFile = 'Human Proteome';

        case 2

            % Reads from the extracellular protein dataset
            FastaData = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'ECMProteins.fasta'));

            % Updates the variable storing which file was read
            FastaFile = 'ECM Proteins';

        case 3

            % Reads from the secreted protein dataset
            FastaData = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'SecretedProteins.fasta'));

            % Updates the variable storing which file was read
            FastaFile = 'Secreted Proteins';

        case 4

            % Reads from the plasma membrane protein dataset
            FastaData = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'PlasmaMembraneProteins.fasta'));

            % Updates the variable storing which file was read
            FastaFile = 'Plasma Membrane Proteins';

        case 5

            % Reads from the Tiggrin protein dataset
            FastaData = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'Tiggrin.fasta'));

            % Updates the variable storing which file was read
            FastaFile = 'Tiggrin';

        case 6

            % Reads from the POSTN protein dataset
            FastaData = fastaread(fullfile(mainDirectory, 'FASTADatasets', 'POSTN.fasta'));

            % Updates the variable storing which file was read
            FastaFile = 'POSTN';

        otherwise

            % Attempts to read the user entered dataset
            try
                
                % Gets the filename of the chosen file
                [filename, pathname] = uigetfile({'*.fasta'}, 'Select .fasta file');
            
                % Reads the user entered file
                FastaData = fastaread(fullfile(pathname, filename));
                
                % Updates the variable storing which file was read
                FastaFile = filename;
                
            % Catches any errors in choosing and reading the file
            catch
                
                % Produces a message box with the error
                uiwait(msgbox('Error selecting or reading FASTA file.  Make sure the file selected has the extension ".fasta"', 'error', 'modal'));
                return;
                
            end
            
    end
    
    % Creates a waitbar to show the user progress
    waitbarHandle = waitbar(0, 'Program progress');
    
    % Creates an array that will hold the results
    results = {'Query Sequence Data', 'Percent Similarity Threshold', 'Fasta Dataset Used', '', '', '', '';
               queryDataName, perSimThresh, FastaFile, '', '', '', '';
               '', '', '', '', '', '', '';
               'Query Sequence Protein ID', 'Query Sequence', 'Index of Query Sequence', 'Percent Match', 'Flagged Sequence Protein ID', 'Flagged Sequence', 'Index of Flagged Sequence'};
           
    % Stores the BLOSUM-62 matrix in a variable array 
    matrix = blosum(62, 'Order', 'ARNDCQEGHILKMFPSTWYVBZX*');

    % Runs through every sequence of length windowSize in the query sequence data
    for queryIndex = 1 : length(querySeq) - (windowSize - 1)

        % Updates waitbar
        waitbar(queryIndex / length(querySeq));

        % Determines the BLOSUM score of the query sequence to be used as a base score
        baseScore = BLOSUMScore(upper(querySeq(queryIndex : queryIndex + (windowSize - 1))), upper(querySeq(queryIndex : queryIndex + (windowSize - 1))), matrix, refArray);
        
        % Runs through each protein in the fasta dataset
        for proteinNum = 1 : length(FastaData)
            
            % Runs through each substring of length windowSize in the protein
            for subSeqIndex = 1 : length(FastaData(proteinNum).Sequence) - (windowSize - 1)
                
                % Calculates the subsequence BLOSUM score
                subScore = BLOSUMScore(upper(FastaData(proteinNum).Sequence(subSeqIndex : subSeqIndex + (windowSize - 1))), upper(querySeq(queryIndex : queryIndex + (windowSize - 1))), matrix, refArray);
                
                % Checks to see if the subsequence scores above the threshold
                if (subScore / baseScore) > (perSimThresh / 100)
                    
                    % Adds the data to the results
                    results = [results; {queryProteinID, upper(querySeq(queryIndex : queryIndex + (windowSize - 1))), queryIndex, (subScore / baseScore) * 100, FastaData(proteinNum).Header, upper(FastaData(proteinNum).Sequence(subSeqIndex : subSeqIndex + (windowSize - 1))), subSeqIndex}];
  
                end

            end
            
        end

    end
    
    % Stores the results in an excel file
    xlwrite(fullfile(mainDirectory, 'Results', [queryDataName '-' num2str(perSimThresh) '-' FastaFile]), results);

    % Closes the waitbar
    close(waitbarHandle);
    
    % Opens the excel file
    system(['open "' fullfile(mainDirectory, 'Results', [queryDataName '-' num2str(perSimThresh) '-' FastaFile '.xlsx"'])]);
    
end

% Adds files to the MATLAB path so the xlwrite function may be used and returns the path to the project .m file
function mainDirectory = addFiles()

% mainDirectory         The path to the MATLAB .m file where the project is located

    % Gets the path to the .m file where the project is located
    mainDirectory = fileparts(mfilename('fullpath'));
    
    % Adds the necessary files to be able to use the xlwrite function
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-ooxml-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'poi-ooxml-schemas-3.8-20120326.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'xmlbeans-2.3.0.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'dom4j-1.6.1.jar'));
    javaaddpath(fullfile(mainDirectory, 'poi_library', 'stax-api-1.0.1.jar'));

end

% Determines the BLOSUM score of the given subsequence to the given query sequence
function score = BLOSUMScore(subSeq, querySeq, matrix, refArray)

% score         The BLOSUM score of the given subsequence

% subSeq        The subsequence to score
% enterQuerySeq      The query sequence to use as a base value
% matrix        The BLOSUM-62 matrix to use in scoring the amino acids
% refArray      The reference array to determine amino acid indices
    
    % Stores the BLOSUM score of the subsequence
    score = 0;

    % Runs through each amino acid in the subsequence 
    for aminoAcidNum = 1 : length(subSeq)

        % Finds the BLOSUM score from the matrix using the reference array
        tempScore = matrix(strfind(refArray, querySeq(aminoAcidNum)), strfind(refArray, subSeq(aminoAcidNum)));
        
        % Checks for the possibility that the amino acid is not known to BLOSUM
        if ~isempty(tempScore)
           
            % Adds the calculated score to the cumulative score of the sequence
            score = score + tempScore;
            
        end

    end
    
end

%---------------------------------------------------------------------------------------------
% BEGIN - UNUSED GUI FUNCTIONS CREATED BY GUIDE

% Executes during the creation of the GUI after all properties are set
function CadiganProteomeSearch_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to the GUI
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

    % Defines a global variable to be used later in the program
    global querySeqType;
    querySeqType = true;

end

% Executes when the mouse is clicked over the GUI background
function CadiganProteomeSearch_ButtonDownFcn(hObject, eventdata, handles)

% hObject       The handle to the GUI
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during the creation of the query sequence textbox after all properties are set
function enterQuerySeq_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to enterQuerySeq
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% Executes when the query sequence textbox has a callback
function enterQuerySeq_Callback(hObject, eventdata, handles)

% hObject       The handle to the query sequence textbox
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes on selection change in selectQueryFile
function selectQueryFile_Callback(hObject, eventdata, handles)

% hObject       The handle to selectQueryFile
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during creation of selectQueryFile after setting all properties
function selectQueryFile_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to selectQueryFile
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% Executes when the windowSize textbox has a callback
function windowSize_Callback(hObject, eventdata, handles)

% hObject       The handle to windowSize
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during creation of the windowSize textbox after setting all properties
function windowSize_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to windowSize
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% Executes when the percent similarity threshold textbox has a callback
function perSimThresh_Callback(hObject, eventdata, handles)

% hObject       The handle to perSimThresh
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during the creation of the percent similarity threshold textbox after all properties are set
function perSimThresh_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to perSimThresh
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% Executes when there is a selection change in the listbox
function selectFastaFile_Callback(hObject, eventdata, handles)

% hObject       The handle to selectFastaFile
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       A structure with handles and user data

end

% Executes during the creation of the listbox after all properties are set
function selectFastaFile_CreateFcn(hObject, eventdata, handles)

% hObject       The handle to selectFastaFile
% eventdata     This is reserved to be defined in a future version of MATLAB
% handles       Empty - The handles are not created until after all CreateFcns are called

end

% END - UNUSED GUI FUNCTIONS CREATED BY GUIDE
%---------------------------------------------------------------------------------------------
