clear
DATAFOLDER = 'EFMerge';

% load data
data = readtable(fullfile(DATAFOLDER, 'AntiSacResult.csv'));
% remove those without enough responded trials
rate = 0.8;
data(data.NResp < rate * data.NTrial, :) = [];
[grps, id] = findgroups(data.id);
PE = splitapply(@min, data.PE, grps);
% combine to a table
filtered = table(id, PE);
writetable(filtered, fullfile(DATAFOLDER, 'AntiSacFiltered.csv'))
