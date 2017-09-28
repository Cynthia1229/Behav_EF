% clear variables in case of incompatibilities
clear

% directory of spatial working memory data
CATESWI_DIR = 'CateSwitch';
MRGDAT_DIR = 'EFMerge';

% get the files information
cateswifiles = dir(fullfile(CATESWI_DIR, 'CateSwitch_Sub*.mat'));

% load and merge files
% use a table `mrgdata` to store all the data
mrgdata = table;
for ifile = 1:length(cateswifiles)
    % get data file name
    filename = cateswifiles(ifile).name;
    % extract subject id and participate date and time
    sid = str2double(regexp(filename, '(?<=Sub)\d+', 'once', 'match'));
    sdate = datetime(regexp(filename, '\d{2}-[A-Za-z]{3}-\d{4}_\d{2}-\d{2}', 'once', 'match'), ...
        'InputFormat', 'dd-MMM-yyyy_HH-mm', 'Locale', 'en_US');
    % load data
    load(fullfile(CATESWI_DIR, filename))
    % get number the trials and recorded variables
    [ntrial, nvar] = size(SM);
    % check whether the data is correctly recorded
    if nvar ~= 13
        warning('SCRIPT:DATAINVALID', 'Invalid data for subject: %d.', sid)
        continue
    end
    % form a table to store the subject info and experiment data
    SMTrans = table;
    SMTrans.id = repmat(sid, ntrial, 1);
    SMTrans.time = repmat(sdate, ntrial, 1);
    varnames = {'iTrial', 'iMaterial', 'task', 'semL', 'semS', 'respCorrect', 'keySelect', 'Score', 'RT', 'DonsetTime', 'AonsetTime', 'tskSwitch', 'respSwitch'};
    SMTrans = [SMTrans, array2table(SM, 'VariableNames', varnames)]; %#ok<AGROW>
    % merge current subject data to the total data set
    mrgdata = [mrgdata; SMTrans]; %#ok<AGROW>
end

% write out data.
if ~exist(MRGDAT_DIR, 'dir'), mkdir(MRGDAT_DIR); end
writetable(mrgdata, fullfile(MRGDAT_DIR, 'CateSwitch.csv'))
