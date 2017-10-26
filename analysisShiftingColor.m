clear
DATAFOLDER = 'EFMerge';
RESFOLDER = 'EFRes';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'condition', 'RT', 'respCorrect'};

data = readtable(fullfile(DATAFOLDER, 'ShiftColor.csv'));
data(isnan(data.id), :) = [];
data.tskSwitch = abs(data.task - circshift(data.task, 1));
data(data.iTrial == 1, :) = [];
stimMap = containers.Map(0:1, {'Repeat', 'Switch'});
data.condition = values(stimMap, num2cell(data.tskSwitch));
data.RT = data.RT * 1000;
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@sngprocControl, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(RESFOLDER, 'ShiftColorResult.csv'))
