
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'ismatch', 'ACC', 'RT'};

data = readtable(fullfile(DATAFOLDER, 'WM3.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@wm, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'analysisWM3.csv'))

function [stats, labels] = wm(ismatch, acc, rt)

NTrial = length(ismatch);
NResp = sum(~isnan(acc));
rt = rmoutlier(rt * 1000);
acc(isnan(rt)) = nan;
NInclude = sum(~isnan(acc));
hitRate = nanmean(acc(ismatch == 1));
FARate = 1 - nanmean(acc(ismatch == 0));
[dprime, c] = sdt(hitRate, FARate);
stats = [NTrial, NResp, NInclude, hitRate, FARate, dprime, c];
labels = {'NTrial', 'NResp', 'NInclude', 'hitRate', 'FARate', 'dprime', 'c'};

end


