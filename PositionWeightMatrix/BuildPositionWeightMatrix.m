% Main function used to initiate the build of the matrix
function [PWM, numCols] = BuildPositionWeightMatrix(fastaFile, handles)

% PWM           The position weight matrix

% fastaFile     The fasta file to use when building the matrix
% handles       A structure with handles and user data

    % Determines the number of rows and columns in the fasta file
    [numRows, numCols] = determineNumRowsNumCols(fastaFile, handles);

    % Creates the position frequency matrix
    PFM = buildPositionFrequencyMatrix(fastaFile, numCols);
    
    % Creates the position percentage matrix
    PPM = buildPositionPercentageMatrix(PFM, numRows);

    % Creates the position weight matrix
    PWM = log(PPM / 0.25);

end

% Determines the number of rows and columns in the fasta file
function [numRows, numCols] = determineNumRowsNumCols(fastaFile, handles)

% numRows       The number of rows in the fasta file
% numCols       The number of columns in the fasta file

% fastaFile     The fasta file to use
% handles       A structure with handles and user data

    % Gets the ID of the PWM fasta file and opens it for reading
    fileID = fopen(get(handles.PWMfastaSelect, 'string'), 'rt');
    numRows = 0;
    
    % Runs through every row in the file
    while fgets(fileID) ~= -1

       numRows = numRows + 1;
        
    end
    
    % Closes the PWM fasta file
    fclose(fileID);
    
    % Decreases the number of rows by one to account for the row with the heading
    numRows = numRows - 1;
    
    % Determines how many columns there are using the length of the sequence and the number of rows
    numCols = ceil(sum(ismember(upper(fastaFile.Sequence), 'ACGT')) / numRows);

end

% Builds a position frequency matrix, measuring the frequency that each nucleotide occurs
function PFM = buildPositionFrequencyMatrix(fastaFile, numCols)

% PFM           The position frequency matrix

% fastaFile     The fasta file to use when building the matrix
% numRows       The number of rows of nucleotides in the fasta file

    % Preallocates the size of the position frequency matrix
    PFM = zeros(4, numCols);

    numInvalid = 0;

    % Runs through each character in the sequence
    for index = 1 : length(fastaFile.Sequence)

        % Checks to make sure the character at the current index is a valid nucleotide
        if ismember(upper(fastaFile.Sequence(index)), 'ACGT')

            % Calculates the column of the PWM matrix that should be appended
            matrixCol = mod(index - numInvalid, numCols);
            
            % Checks to see if the matrixCol is 0, which is not a valid column number
            if matrixCol == 0

               matrixCol = numCols;

            end
            
            % Determines which nucleotide is in the current index location and increments the correct position in the matrix
            if strcmpi(fastaFile.Sequence(index), 'A')

                PFM(1, matrixCol) = PFM(1, matrixCol) + 1;

            elseif strcmpi(fastaFile.Sequence(index), 'C')

                PFM(2, matrixCol) = PFM(2, matrixCol) + 1;

            elseif strcmpi(fastaFile.Sequence(index), 'G')
 
                PFM(3, matrixCol) = PFM(3, matrixCol) + 1;

            else
 
                PFM(4, matrixCol) = PFM(4, matrixCol) + 1;

            end

        else
            
            % If the character at the current index is not a valid nucleotide then this variable is incremented
            % This is needed in order for the algorithm to calculate the correct position to increment in the matrix to work
            numInvalid = numInvalid + 1;

        end
        
    end

end

% Builds a position percentage matrix, measuring the percentage that each nucleotide occurs in each column
function PPM = buildPositionPercentageMatrix(PFM, numRows)

% PPM           The position percentage matrix

% PFM           The position frequency matrix
% numRows       The number of rows in the fasta file

    PPM = PFM / numRows;

end
