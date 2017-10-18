
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'Score'};

data = readtable(fullfile(DATAFOLDER, 'AntiSac.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@antisac, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'AntiSacResult.csv'))

function [stats, labels] = antisac(score)

NTrial = length(score);
ACC = sum(score)/NTrial;
stats = [NTrial, ACC];
labels = {'NTrial', 'ACC'};

end
