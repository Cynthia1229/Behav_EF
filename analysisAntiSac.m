
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'RT', 'Score'};

data = readtable(fullfile(DATAFOLDER, 'AntiSac.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@antisac, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'AntiSacResult.csv'))

function [stats, labels] = antisac(rt, acc)

NTrial = length(acc);
NResp = sum(rt ~= 0);
% set rt of no response trials as NaN
acc(outlier(rt, 'Method', 'cutoff', 'Boundary', [100, inf])) = -1;
NInclude = sum(acc ~= -1);
MRT = mean(rt(acc == 1));
PE = 1 - sum(acc == 1) / NInclude;
stats = [NTrial, NResp, NInclude, MRT, PE];
labels = {'NTrial', 'NResp', 'NInclude', 'MRT', 'PE'};

end
