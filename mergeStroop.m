% clear variables in case of incompatibilities
clear

% directory of spatial working memory data
STROOP_DIR = 'Stroop';
MRGDAT_DIR = 'EFMerge';

% get the files information
stroopfiles = dir(fullfile(STROOP_DIR, 'Stroop_Sub*.mat'));

% load and merge files
% use a table `mrgdata` to store all the data
mrgdata = table;
for ifile = 1:length(stroopfiles)
    % get data file name
    filename = stroopfiles(ifile).name;
    % extract subject id and participate date and time
    sid = str2double(regexp(filename, '(?<=Sub)\d+', 'once', 'match'));
    sdate = datetime(regexp(filename, '\d{2}-[A-Za-z]{3}-\d{4}_\d{2}_\d{2}', 'once', 'match'), ...
        'InputFormat', 'dd-MMM-yyyy_HH_mm', 'Locale', 'en_US');
    % load data
    load(fullfile(STROOP_DIR, filename))
    % get number the trials and recorded variables
    [ntrial, nvar] = size(result);
    % check whether the data is correctly recorded
    if nvar ~= 7
        warning('SCRIPT:DATAINVALID', 'Invalid data for subject: %d.', sid)
        continue
    end
    % form a table to store the subject info and experiment data
    resultTrans = table;
    resultTrans.id = repmat(sid, ntrial, 1);
    resultTrans.time = repmat(sdate, ntrial, 1);
    varnames = {'iBlock', 'iTrial', 'Material', 'Color', 'RT', 'Key', 'KeyResponse'};
    resultTrans = [resultTrans, cell2table(result, 'VariableNames', varnames)]; %#ok<AGROW>
    % merge current subject data to the total data set
    mrgdata = [mrgdata; resultTrans]; %#ok<AGROW>
end

% write out data.
if ~exist(MRGDAT_DIR, 'dir'), mkdir(MRGDAT_DIR); end
writetable(mrgdata, fullfile(MRGDAT_DIR, 'Stroop.csv'))
