
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'ismatch', 'ACC', 'RT'};

data = readtable(fullfile(DATAFOLDER, 'WM3.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@wm, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'WM3Result.csv'))

function [stats, labels] = wm(ismatch, acc, rt)

NTrial = length(ismatch);
NResp = sum(acc ~= -1);
% set rt of no response trials as NaN
rt(rt == 0) = nan;
% remove too-quick trials
acc(outlier(rt, 'Method', 'cutoff', 'Boundary', [0.1, inf])) = nan;
NInclude = sum(~isnan(acc));
acc(acc == -1) = 0;
hitRate = nanmean(acc(ismatch == 1));
FARate = 1 - nanmean(acc(ismatch == 0));
[dprime, c] = sdt(hitRate, FARate);
IES = (sum(acc == 1)/NInclude)/nanmean(rt(acc == 1));
stats = [NTrial, NResp, NInclude, hitRate, FARate, dprime, c, IES];
labels = {'NTrial', 'NResp', 'NInclude', 'hitRate', 'FARate', 'dprime', 'c', 'IES'};

end
