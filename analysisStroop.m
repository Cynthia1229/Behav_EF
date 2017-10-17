
clear
DATAFOLDER = 'EFMerge';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'Material', 'Unknown', 'RT', 'KeyResponse'};

data = readtable(fullfile(DATAFOLDER, 'Stroop.csv'));
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@stroop, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(DATAFOLDER, 'analysisStroop.csv'))

function [stats, labels] = stroop(material, color, rt, acc)

NTrial = length(material);
NResp = sum(~isnan(acc));

cond = categorical ((strncmp (material, 'r', 1)) & (color == 32418) | ...
    (strncmp (material, 'g', 1)) & (color == 32511) | ...
    (strncmp (material, 'b', 1)) & (color == 34013) | ...
    (strncmp (material, 'y', 1)) & (color == 40644) == 1, [true, false], {'Cong', 'Incong'});
rt = rmoutlier(rt * 1000);
acc(isnan(rt)) = nan;
NInclude = sum(~isnan(acc));
mRT_Cong = nanmean(rt(acc == 1 & cond == 'Cong'));
mRT_Incong = nanmean(rt(acc == 1 & cond == 'Incong'));
mRT_Incon_Con = mRT_Incong - mRT_Cong;
stats = [NTrial, NResp, NInclude, mRT_Cong, mRT_Incong, mRT_Incon_Con];
labels = {'NTrial', 'NResp', 'NInclude', 'mRT_Cong', 'mRT_Incong', 'mRT_Incon_Con'};

end
