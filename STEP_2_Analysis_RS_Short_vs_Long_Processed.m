% In this script we compare measures for Processed RS conditions using 2 epochs: 30 sec vs 5 sec.

%% Analysis of RS files 
computerName = {'pc', 'mac', 'linux'};
measureName = {'CD', 'PK', 'LE', 'HFD', 'MSE_1', 'MSE_2', 'MSE_3', 'MSE_4',...
    'MSE_5', 'MSE_6', 'MSE_7', 'MSE_8', 'MSE_9', 'MSE_10', 'MSE_11', 'MSE_12',...
    'MSE_13', 'MSE_14', 'MSE_15', 'MSE_16', 'MSE_17', 'MSE_18', 'MSE_19', 'MSE_20',...
    'MFDFA_DQFIRST', 'MFDFA_MAXDQ', 'MFDFA_DQLAST', 'MFDFA_MAXMIN', 'KC'};

% Iterate through computerName and then measures
for iComp = 1:3
    % Get files and concatenate them
    fileList = dir(['../OutputFiles/Processed_RS/', computerName{iComp}, '*.xlsx']); 
    fileList = fileList(~cellfun('isempty', {fileList.date}));

    % Iterate through files to collect data for plotting and analysis - RS
    for jFile = 1:length(fileList(:))
        filename = fileList(jFile).name; 
        filenameSplit = strsplit(filename, '_');

        % Read file and add computerName, filename and resultType to table
        fileTable = readtable(['../OutputFiles/Processed_RS/', filename]);
        fileTable.Type = repmat('Processed', 3, 1);
        fileTable.Filename = {filenameSplit{4}; filenameSplit{4}; filenameSplit{4}};
        fileTable.Computer = repmat(computerName{iComp}, 3, 1);
        fileTable.Event = {'EOEC'; 'EO';'EC'};
        fileTable.Size = {'L'; 'L'; 'L'}; % Long

        % Concatenate results
        if jFile == 1
            resultTable  = fileTable;
        else
            t1colmissing = setdiff(fileTable.Properties.VariableNames, ...
                resultTable.Properties.VariableNames);
            t2colmissing = setdiff(resultTable.Properties.VariableNames,...
                fileTable.Properties.VariableNames);
            resultTable = [resultTable array2table(nan(height(resultTable), ...
                numel(t1colmissing)), 'VariableNames', t1colmissing)];
            fileTable = [fileTable array2table(nan(height(fileTable), ...
                numel(t2colmissing)), 'VariableNames', t2colmissing)];
            resultTable = [resultTable; fileTable];
        end
    end
    
    % Get files and concatenate them
    fileList = dir(['../OutputFiles/Processed_RS_BCST_RMET/', computerName{iComp}, '*rs_RS*.xlsx']); 
    fileList = fileList(~cellfun('isempty', {fileList.date}));

    % Iterate through files to collect data for plotting and analysis - RS
    for jFile = 1:length(fileList(:))
        filename = fileList(jFile).name; 
        filenameSplit = strsplit(filename, '_');

        % Read file and add computerName, filename and resultType to table
        fileTable = readtable(['../OutputFiles/Processed_RS_BCST_RMET/', filename]);
        fileTable.Type = repmat('Processed', 3, 1);
        fileTable.Filename = {filenameSplit{4}; filenameSplit{4}; filenameSplit{4}};
        fileTable.Computer = repmat(computerName{iComp}, 3, 1);
        fileTable.Event = {'EOEC'; 'EO';'EC'};
        fileTable.Size = {'S'; 'S'; 'S'}; % Short
        
        % Concatenate results
        t1colmissing = setdiff(fileTable.Properties.VariableNames, ...
            resultTable.Properties.VariableNames);
        t2colmissing = setdiff(resultTable.Properties.VariableNames,...
            fileTable.Properties.VariableNames);
        resultTable = [resultTable array2table(nan(height(resultTable), ...
            numel(t1colmissing)), 'VariableNames', t1colmissing)];
        fileTable = [fileTable array2table(nan(height(fileTable), ...
            numel(t2colmissing)), 'VariableNames', t2colmissing)];
        resultTable = [resultTable; fileTable];   
    end
    
    % Sort rows by filename
    resultTable = sortrows(resultTable, 'Filename');

    % Iterate through measures
    for jMeasure = 1:size(measureName, 2)
        % Plot boxplot for each measure
        indMeasure = find(~cellfun(@isempty, ...
            strfind(resultTable.Properties.VariableNames, measureName{jMeasure})));

        % Create example data
        eventName = {'EOEC', 'EO', 'EC'};

        for kEvent = 1:3
            E = resultTable{find(strcmp(resultTable.Event, eventName{kEvent})), indMeasure}';
            % Prepare data for plotting
            data = cell(3, 2); % 3 subjects x 2 boxplots
            for i = 1:3 %size(data, 1)
                Ac{i} = E(:, 2*i - 1);
                Bc{i} = E(:, 2*i);
            end

            data = vertcat(Ac, Bc);

            % Perform tests
            for i = 1:3
                % Anderson-Darling goodness-of-fit hypothesis test 
                [hAD(i), pAD(i)] = adtest(E(:, 2*i - 1) - E(:, 2*i));

                % Returns the p-value of a paired, two-sided test for the null hypothesis 
                % that x – y comes from a distribution with zero median. 
                % Wilcoxon signed rank test
                [pWSR(i), hWSR(i), ~] = signrank(E(:, 2*i - 1), E(:, 2*i), 'tail', 'right', 'method', 'exact');

                % Returns a test decision for the paired-sample t-test
                [hTT(i), pTT(i), ~, ~] = ttest(E(:, 2*i - 1), E(:, 2*i), 'Tail', 'right');
            end

            % Plot boxplots with results
            pAD = round(pAD, 2); pWSR = round(pWSR, 2); pTT = round(pTT, 2); % round
            xlab = {['1003rs, ', num2str(pAD(1)), ', ', num2str(pWSR(1)), ', ', num2str(pTT(1))],...
                ['2003rs, ', num2str(pAD(2)), ', ', num2str(pWSR(2)), ', ', num2str(pTT(2))],...
                ['3003rs, ', num2str(pAD(3)), ', ', num2str(pWSR(3)), ', ', num2str(pTT(3))]};
            col = [102, 255, 255, 200; 
                  51, 153, 255, 200]/255;

            figure(1)
            fcnBoxplot(data', xlab, {'Long', 'Short'}, col')
            title(strrep(['Processed_RS_Long_vs_Short, ', computerName{iComp}, ...
                ', ', measureName{jMeasure}, ', ', eventName{kEvent}], ...
                '_', '\_'))

            % Save results
            saveas(gcf, ['../Results/Processed_RS_Long_vs_Short_', ...
                computerName{iComp}, '_', measureName{jMeasure}, '_', ...
                eventName{kEvent}, '.png'])
        end
        
    end %jMeasure 
end %iComp


