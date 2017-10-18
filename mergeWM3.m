% clear variables in case of incompatibilities
clear

% directory of spatial working memory data
WM_DIR = 'WM';
MRGDAT_DIR = 'EFMerge';

% get the files information
WMfiles = dir(fullfile(WM_DIR, 'WM3_Sub*.mat'));

% load and merge files
% use a table `mrgdata` to store all the data
mrgdata = table;
for ifile = 1:length(WMfiles)
    % get data file name
    filename = WMfiles(ifile).name;
    % extract subject id and participate date and time
    sid = str2double(regexp(filename, '(?<=Sub)\d+', 'once', 'match'));
    sdate = datetime(regexp(filename, '\d{2}-[A-Za-z]{3}-\d{4}_\d{2}_\d{2}', 'once', 'match'), ...
        'InputFormat', 'dd-MMM-yyyy_HH_mm', 'Locale', 'en_US');
    % load data
    load(fullfile(WM_DIR, filename))
    % get number the trials and recorded variables
    [~, nvar] = size(rec);
    varnames = {'iTrial', 'stim', 'ismatch', 'type', 'ACC', 'RT', 'Resp'};
    % check whether the data is correctly recorded
    if nvar ~= 7
        warning('SCRIPT:DATAINVALID', 'Invalid data for subject: %d.', sid)
        continue
    end
    % remove trials of no response required
    rec(ismissing(rec(:, 4)), :) = []; %#ok<*SAGROW>
    % transform multiple response trials
    invalidRows = cellfun(@length, rec(:, 7)) ~= 1;
    rec(invalidRows, 5) = {-1};
    rec(invalidRows, 6) = {0};
    rec(invalidRows, 7) = {''};
    % form a table to store the subject info and experiment data
    recTrans = table;
    recTrans.id = repmat(sid, size(rec, 1), 1);
    recTrans.time = repmat(sdate, size(rec, 1), 1);
    % transform to table for better readability
    recTrans = [recTrans, cell2table(rec, 'VariableNames', varnames)]; %#ok<AGROW>
    % merge current subject data to the total data set
    mrgdata = [mrgdata; recTrans]; %#ok<AGROW>
end

% write out data.
if ~exist(MRGDAT_DIR, 'dir'), mkdir(MRGDAT_DIR); end
writetable(mrgdata, fullfile(MRGDAT_DIR, 'WM3.csv'))

