
clear
DATAFOLDER = 'EFMerge';
RESFOLDER = 'EFRes';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'RT', 'Score'};

data = readtable(fullfile(DATAFOLDER, 'AntiSac.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@antisac, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(RESFOLDER, 'AntiSacResult.csv'))

function [stats, labels] = antisac(rt, acc)

NTrial = length(acc);
NResp = sum(rt ~= 0);
% set rt of no response trials as NaN
rt(rt == 0) = nan;
% remove too-quick trials
acc(outlier(rt, 'Method', 'cutoff', 'Boundary', [0.1, inf])) = nan;
NInclude = sum(~isnan(acc));
MRT = mean(rt(acc == 1));
PE = 1 - nanmean(acc);
stats = [NTrial, NResp, NInclude, MRT, PE];
labels = {'NTrial', 'NResp', 'NInclude', 'MRT', 'PE'};

end
