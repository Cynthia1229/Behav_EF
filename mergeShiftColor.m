% clear variables in case of incompatibilities
clear

% directory of spatial working memory data
SHIFTCOL_DIR = 'ShiftingColor';
MRGDAT_DIR = 'EFMerge';

% get the files information
shiftcolfiles = dir(fullfile(SHIFTCOL_DIR, 'ShiftingColor_Sub*.mat'));

% load and merge files
% use a table `mrgdata` to store all the data
mrgdata = table;
for ifile = 1:length(shiftcolfiles)
    % get data file name
    filename = shiftcolfiles(ifile).name;
    % extract subject id and participate date and time
    sid = str2double(regexp(filename, '(?<=Sub)\d+', 'once', 'match'));
    sdate = datetime(regexp(filename, '\d{2}-[A-Za-z]{3}-\d{4}_\d{2}-\d{2}', 'once', 'match'), ...
        'InputFormat', 'dd-MMM-yyyy_HH-mm', 'Locale', 'en_US');
    % load data
    load(fullfile(SHIFTCOL_DIR, filename))
    % get number the trials and recorded variables
    [ntrial, nvar] = size(rec);
    % check whether the data is correctly recorded
    if nvar ~= 8
        warning('SCRIPT:DATAINVALID', 'Invalid data for subject: %d.', sid)
        continue
    end
    % form a table to store the subject info and experiment data
    recTrans = table;
    recTrans.id = repmat(sid, ntrial, 1);
    recTrans.time = repmat(sdate, ntrial, 1);
    varnames = {'iTrial', 'shape', 'color', 'task', 'keepsameasnumber', 'keyPressed', 'respCorrect', 'RT'};
    recTrans = [recTrans, array2table(rec, 'VariableNames', varnames)]; %#ok<AGROW>
    % merge current subject data to the total data set
    mrgdata = [mrgdata; recTrans]; %#ok<AGROW>
end

% write out data.
if ~exist(MRGDAT_DIR, 'dir'), mkdir(MRGDAT_DIR); end
writetable(mrgdata, fullfile(MRGDAT_DIR, 'ShiftColor.csv'))
