
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'Score', 'RT'};

data = readtable(fullfile(DATAFOLDER, 'CateSwitch.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@cateswitch, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'analysisCateSwitch.csv'))

function [stats, labels] = cateswitch(score, rt)

NTrial = length(score);
NResp = sum(~isnan(rt));
rt = rmoutlier(rt * 1000);
NInclude = sum(~isnan(rt));
RT = nanmean(rt(score == 1));
stats = [NTrial, NResp, NInclude, RT];
labels = {'NTrial', 'NResp', 'NInclude', 'RT'};

end


