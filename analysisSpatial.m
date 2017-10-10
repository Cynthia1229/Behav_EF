
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'flashLoc', 'respCorrect', 'RT'};

data = readtable(fullfile(DATAFOLDER, 'spatial_2back.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@spatial, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];

function [stats, labels] = spatial(loc, acc, rt)

NTrial = length(loc);
NResp = sum(~isnan(acc));
cond = categorical((loc - circshift(loc, 2)) == 0, [false, true], {'Change', 'Stay'});
rt = rmoutlier(rt * 1000);
acc(isnan(rt)) = nan;
NInclude = sum(~isnan(acc));
hitRate = nanmean(acc(cond == 'Stay'));
FARate = 1 - nanmean(acc(cond == 'Change'));
[dprime, c] = sdt(hitRate, FARate);
stats = [NTrial, NResp, NInclude, hitRate, FARate, dprime, c];
labels = {'NTrial', 'NResp', 'NInclude', 'hitRate', 'FARate', 'dprime', 'c'};

end
