clear
DATAFOLDER = 'EFMerge';
RESFOLDER = 'EFRes';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'condition', 'RT', 'Score'};

data = readtable(fullfile(DATAFOLDER, 'CateSwitch.csv'));
data(data.tskSwitch == 0, :) = [];
stimMap = containers.Map(1:2, {'Repeat', 'Switch'});
data.condition = values(stimMap, num2cell(data.tskSwitch));
data.Score(data.RT == 0) = -1;
data.RT = data.RT * 1000;
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@sngprocControl, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(RESFOLDER, 'CateSwitchResult.csv'))
