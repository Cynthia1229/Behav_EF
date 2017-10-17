% clear variables in case of incompatibilities
clear

% directory of spatial working memory data
STOPSIG_DIR = 'StopSignal';
MRGDAT_DIR = 'EFMerge';

% get the files information
stopsignalfiles = dir(fullfile(STOPSIG_DIR, 'StopSignal_Sub*.mat'));

% load and merge files
% use a table `mrgdata` to store all the data
mrgdata = table;
for ifile = 1:length(stopsignalfiles)
    % get data file name
    filename = stopsignalfiles(ifile).name;
    % extract subject id and participate date and time
    sid = str2double(regexp(filename, '(?<=Sub)\d+', 'once', 'match'));
    sdate = datetime(regexp(filename, '\d{2}-[A-Za-z]{3}-\d{4}_\d{2}_\d{2}', 'once', 'match'), ...
        'InputFormat', 'dd-MMM-yyyy_HH_mm', 'Locale', 'en_US');
    % load data
    load(fullfile(STOPSIG_DIR, filename))
    % get number the trials and recorded variables
    [ntrial, nvar] = size(Seeker);
    % check whether the data is correctly recorded
    if nvar ~= 10
        warning('SCRIPT:DATAINVALID', 'Invalid data for subject: %d.', sid)
        continue
    end
    % form a table to store the subject info and experiment data
    SeekerTrans = table;
    SeekerTrans.id = repmat(sid, ntrial, 1);
    SeekerTrans.time = repmat(sdate, ntrial, 1);
    varnames = {'iTrial', 'iBlock', 'IsStop', 'STIM', 'SSDCat', 'SSD', 'Resp', 'RT', 'OnsetTime', 'SSDNext'};
    SeekerTrans = [SeekerTrans, array2table(Seeker, 'VariableNames', varnames)]; %#ok<AGROW>
    % merge current subject data to the total data set
    mrgdata = [mrgdata; SeekerTrans]; %#ok<AGROW>
end

% write out data.
if ~exist(MRGDAT_DIR, 'dir'), mkdir(MRGDAT_DIR); end
writetable(mrgdata, fullfile(MRGDAT_DIR, 'StopSignal.csv'))
