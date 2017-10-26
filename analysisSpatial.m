
clear
DATAFOLDER = 'EFMerge';
RESFOLDER = 'EFRes';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'flashLoc', 'respCorrect', 'RT'};

data = readtable(fullfile(DATAFOLDER, 'spatialWM.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@spatial, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(RESFOLDER, 'SpatialWMResult.csv'))

function [stats, labels] = spatial(loc, acc, rt)

NTrial = length(loc);
NResp = sum(~isnan(acc));
acc(isnan(acc)) = 0;
% remove too-quick trials
acc(outlier(rt, 'Method', 'cutoff', 'Boundary', [0.1, inf])) = nan;
NInclude = sum(~isnan(acc));
PE = 1 - nanmean(acc);
MRT = mean(rt(acc == 1));
IES = MRT / (1 - PE);
cond = categorical((loc - circshift(loc, 2)) == 0, [false, true], {'Change', 'Stay'});
hitRate = nanmean(acc(cond == 'Stay'));
FARate = 1 - nanmean(acc(cond == 'Change'));
[dprime, c] = sdt(hitRate, FARate);
stats = [NTrial, NResp, NInclude, PE, MRT, IES, hitRate, FARate, dprime, c];
labels = {'NTrial', 'NResp', 'NInclude', 'PE', 'MRT', 'IES', 'hitRate', 'FARate', 'dprime', 'c'};

end
