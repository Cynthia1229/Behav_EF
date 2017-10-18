
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'RT', 'Score'};

data = readtable(fullfile(DATAFOLDER, 'AntiSac.csv'));
data.Score(data.keySelect == 0) = -1;
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@antisac, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'AntiSacResult.csv'))

function [stats, labels] = antisac(rt, acc)

NTrial = length(acc);
NResp = sum(acc ~= -1);
% set rt of no response trials as NaN
rt(acc == -1) = nan;
rt = rmoutlier(rt * 1000);
acc(isnan(rt)) = nan;
NInclude = sum(~isnan(acc));
MRT = nanmean(rt(acc == 1));
PE = 1 - nanmean(acc);
stats = [NTrial, NResp, NInclude, MRT, PE];
labels = {'NTrial', 'NResp', 'NInclude', 'MRT', 'PE'};

end
