
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'respCorrect', 'RT'};

data = readtable(fullfile(DATAFOLDER, 'ShiftColor.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@shiftcolor, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'analysisShiftColor.csv'))

function [stats, labels] = shiftcolor(resp, rt)

NTrial = length(resp);
NResp = sum(~isnan(rt));
rt = rmoutlier(rt * 1000);
NInclude = sum(~isnan(rt));
RT = nanmean(rt(resp == 1));
stats = [NTrial, NResp, NInclude, RT];
labels = {'NTrial', 'NResp', 'NInclude', 'RT'};

end


