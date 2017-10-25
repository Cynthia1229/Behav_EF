% clear variables in case of incompatibilities
clear

% directory of spatial working memory data
SPATIAL_DIR = 'spatial';
MRGDAT_DIR = 'EFMerge';

% get the files information
spatialfiles = dir(fullfile(SPATIAL_DIR, 'spatial_2back_Sub*.mat'));

% load and merge files
% use a table `mrgdata` to store all the data
mrgdata = table;
for ifile = 1:length(spatialfiles)
    % get data file name
    filename = spatialfiles(ifile).name;
    % extract subject id and participate date and time
    sid = str2double(regexp(filename, '(?<=Sub)\d+', 'once', 'match'));
    sdate = datetime(regexp(filename, '\d{2}-[A-Za-z]{3}-\d{4}_\d{2}-\d{2}', 'once', 'match'), ...
        'InputFormat', 'dd-MMM-yyyy_HH-mm', 'Locale', 'en_US');
    % load data
    load(fullfile(SPATIAL_DIR, filename))
    % remove the first two trials of each block
    blocks = unique(rec(:, 2));
    subcfg.type = '()';
    subcfg.subs = {[1, 2]};
    rmRows = arrayfun(@(block) subsref(find(rec(:, 2) == block), subcfg), blocks, 'UniformOutput', false);
    rmRows = cat(1, rmRows{:});
    rec(rmRows, :) = []; %#ok<SAGROW>
    % get number the trials and recorded variables
    [ntrial, nvar] = size(rec);
    % check whether the data is correctly recorded
    if nvar ~= 6
        warning('SCRIPT:DATAINVALID', 'Invalid data for subject: %d.', sid)
        continue
    end
    % form a table to store the subject info and experiment data
    recTrans = table;
    recTrans.id = repmat(sid, ntrial, 1);
    recTrans.time = repmat(sdate, ntrial, 1);
    varnames = {'iTrial', 'iBlock', 'flashLoc', 'respCorrect', 'RT', 'OnsetTime'};
    recTrans = [recTrans, array2table(rec, 'VariableNames', varnames)]; %#ok<AGROW>
    % merge current subject data to the total data set
    mrgdata = [mrgdata; recTrans]; %#ok<AGROW>
end

% write out data.
if ~exist(MRGDAT_DIR, 'dir'), mkdir(MRGDAT_DIR); end
writetable(mrgdata, fullfile(MRGDAT_DIR, 'spatialWM.csv'))
