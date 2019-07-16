% In this script we plot MSE and MFDFA for 30 secs windows from Processed RS run.
% Epoch length: 30 seconds

%% Analysis of _RS.xlsx files
computerName = {'pc', 'mac', 'linux'};
measureName = {'MSE', 'MFDFA'};

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
    
    % Sort rows by filename
    resultTable = sortrows(resultTable, 'Filename');
    
    % Plot MSE and MFDFA
    for jMeasure = 1:2
        % Get indices for each measure
        indMeasure = find(~cellfun(@isempty, ...
            strfind(resultTable.Properties.VariableNames, measureName{jMeasure})));

        % Create example data
        EOEC = resultTable{find(strcmp(resultTable.Event, 'EOEC')), indMeasure}';
        EO = resultTable{find(strcmp(resultTable.Event, 'EO')), indMeasure}';
        EC = resultTable{find(strcmp(resultTable.Event, 'EC')), indMeasure}';
        
        % Colors, markers and plotting
        cMap = colormap(parula(21));
        mMar = {'-+', '-o', '-*', '-.', '-x', '-s', '-d', ...
            '-+', '-o', '-*', '-.', '-x', '-s', '-d',...
            '-+', '-o', '-*', '-.', '-x', '-s', '-d'};
        vLab = {'E9', 'E11', 'E15', 'E22', 'E24', 'E33', 'E36',...
            'E45', 'E52', 'E58', 'E70', 'E83', 'E92', 'E96', 'E104', 'E108',...
            'E122', 'E124'};
        for kES = 1:9 % Iterate through events and subjects
            for kChannel = 1:18 % Iterate through 21 channels
                if jMeasure == 1 % MSE
                    fig = figure(1);
                    plot(resultTable{kES, indMeasure((kChannel - 1)*20+1:kChannel*20)}, ...
                        mMar{kChannel}, 'Color', cMap(kChannel, :))
                    hold on;
                end
                if jMeasure == 2 % MFDFA
                    fig = figure(1);
                    MFDFA = resultTable{kES, indMeasure((kChannel - 1)*4+1:kChannel*4)};
                    plot([0.5 - MFDFA(4)/2 0.5 0.5 + MFDFA(4)/2], [MFDFA(1), MFDFA(2), MFDFA(3)], ...
                        mMar{kChannel}, 'Color', cMap(kChannel, :))
                    hold on;
                end
            end
            
            % Add titles and labels
            if jMeasure == 1
                ylabel('MSE')
                 ylim([0, 1.8])
            else
                ylabel('Dq')
                xlabel('max(hq) - min(hq)')
                xlim([0, 1])
                ylim([0, 1.6])
            end
            title(['Processed; Length: 30s; Subject: ', resultTable.Filename{kES}, ...
                '; Event: ', resultTable.Event{kES},...
                '; Computer: ', computerName{iComp}])
            legend(vLab)
            
            % Save results
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 18 9];
            saveas(gcf, ['../Results/Processed_RS_', measureName{jMeasure},...
                '_', computerName{iComp}, '_', resultTable.Filename{kES}, '_', ...
                resultTable.Event{kES}, '.png'])
            clf
        end % events and subjects
    end %jMeasure 
end %iComp




