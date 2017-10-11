
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'RT', 'Score'};

data = readtable(fullfile(DATAFOLDER, 'AntiSac.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@antisac, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'analysisAntiSac.csv'))

function [stats, labels] = antisac(rt, score)

NTrial = length(score);
NResp = sum(~isnan(rt));
rt = rmoutlier(rt * 1000);
NInclude = sum(~isnan(rt));
RT = nanmean(rt(score == 1));
stats = [NTrial, NResp, NInclude, RT];
labels = {'NTrial', 'NResp', 'NInclude', 'RT'};

end


