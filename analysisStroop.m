
clear
DATAFOLDER = 'EFMerge';
RESFOLDER = 'EFRes';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'condition', 'RT', 'KeyResponse'};

data = readtable(fullfile(DATAFOLDER, 'Stroop.csv'));
data(isnan(data.id), :) = [];
data.condition = categorical ((strncmp (data.Material, 'r', 1)) & (data.Color == 32418) | ...
    (strncmp (data.Material, 'g', 1)) & (data.Color == 32511) | ...
    (strncmp (data.Material, 'b', 1)) & (data.Color == 34013) | ...
    (strncmp (data.Material, 'y', 1)) & (data.Color == 40644) == 1, [true, false], {'Cong', 'Incong'});

data.RT = data.RT * 1000;
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@sngprocControl, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(RESFOLDER, 'StroopResult.csv'))
