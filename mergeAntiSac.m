% clear variables in case of incompatibilities
clear

% directory of spatial working memory data
ANTISAC_DIR = 'AntiSac';
MRGDAT_DIR = 'EFMerge';

% get the files information
antisacfiles = dir(fullfile(ANTISAC_DIR, 'AntiSac_sub*.mat'));

% load and merge files
% use a table `mrgdata` to store all the data
mrgdata = table;
for ifile = 1:length(antisacfiles)
    % get data file name
    filename = antisacfiles(ifile).name;
    % extract subject id and participate date and time
    sid = str2double(regexp(filename, '(?<=sub)\d+', 'once', 'match'));
    sdate = datetime(regexp(filename, '\d{2}-[A-Za-z]{3}_\d{2}-\d{2}', 'once', 'match'), ...
        'InputFormat', 'dd-MMM_HH-mm', 'Locale', 'en_US');
    % load data
    load(fullfile(ANTISAC_DIR, filename))
    % get number the trials and recorded variables
    [ntrial, nvar] = size(Seq);
    % check whether the data is correctly recorded
    if nvar ~= 8
        warning('SCRIPT:DATAINVALID', 'Invalid data for subject: %d.', sid)
        continue
    end
    % form a table to store the subject info and experiment data
    SeqTrans = table;
    SeqTrans.id = repmat(sid, ntrial, 1);
    SeqTrans.time = repmat(sdate, ntrial, 1);
    varnames = {'iTrial', 'targetLoc', 'targetDir', 'fixationDur', 'keySelect', 'RT', 'Score', 'OnsetTime'};
    SeqTrans = [SeqTrans, array2table(Seq, 'VariableNames', varnames)]; %#ok<AGROW>
    % merge current subject data to the total data set
    mrgdata = [mrgdata; SeqTrans]; %#ok<AGROW>
end

% write out data.
if ~exist(MRGDAT_DIR, 'dir'), mkdir(MRGDAT_DIR); end
writetable(mrgdata, fullfile(MRGDAT_DIR, 'AntiSac.csv'))
