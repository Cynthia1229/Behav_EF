
clear
DATAFOLDER = 'EFMerge';
RESFOLDER = 'EFRes';
KEYMETAVAR = {'id', 'time'};
ANADATAVAR = {'RT', 'ACC', 'IsStop', 'SSD', 'SSDCat'};

data = readtable(fullfile(DATAFOLDER, 'StopSignal.csv'));
% calculate the accuracy type of each trial
data.ACC = zeros(height(data), 1);
data.ACC((data.IsStop == 1 & data.SSDNext == 1) | ...
    (data.IsStop == 0 & ...
    ((data.STIM == 0 & data.Resp == 70) | (data.STIM == 1 & data.Resp == 74)))) = 1;
data.ACC(data.IsStop == 0 & data.Resp == 0) = -1;
% modify unit of reaction time
data.RT = data.RT * 1000;
[grps, gid] = findgroups(data(:, KEYMETAVAR));
[stats, labels] = splitapply(@stopSignal, data(:, ANADATAVAR), grps);
results = [gid, array2table(stats, 'VariableNames', labels(1, :))];
writetable(results, fullfile(RESFOLDER, 'StopSignalResult.csv'))

function [stats, labels] = stopSignal(RT, ACC, IsStop, SSD, SSDCat)
%SNGPROCBART Does some basic data transformation to BART task.

% By Zhang, Liang. 04/13/2016. E-mail:psychelzh@gmail.com

% record trial information
NTrial = length(RT);
NResp = sum(ACC ~= -1);
% remove RT's with no response
RT(ACC == -1) = NaN;
% remove RT outlier
RT(~IsStop) = rmoutlier(RT(~IsStop));
ACC(isnan(RT)) = nan;
NInclude = sum(~isnan(ACC));
% mean reaction time and proportion of error for Go and Stop condition
MRT_Go = mean(RT(ACC == 1 & IsStop == 0));
MRT_Stop = mean(RT(ACC == 0 & IsStop == 1));
PE_Go = 1 - nanmean(ACC(IsStop == 0));
PE_Stop = 1 - mean(ACC(IsStop == 1));
% mark out those ssd categories with negative ssd
ssdcats = 1:4;
ssdnormal = arrayfun(@(ssdcat) ...
    ~any(SSD(IsStop == 1 & SSDCat == ssdcat) <= 0), ...
    ssdcats);
% mean SSD
MSSDMat = arrayfun(@(ssdcat) mean( ...
    [findpeaks(SSD(IsStop == 1 & SSDCat == ssdcat)); ...
    -findpeaks(-SSD(IsStop == 1 & SSDCat == ssdcat))]), ...
    ssdcats);

stats = [NTrial, NResp, NInclude, MRT_Go, MRT_Stop, PE_Go, PE_Stop, MSSDMat, ssdnormal];
labels = {'NTrial', 'NResp', 'NInclude', 'MRT_Go', 'MRT_Stop', 'PE_Go', 'PE_Stop', 'MSSD1', 'MSSD2', 'MSSD3', 'MSSD4', 'SSSD1', 'SSSD2', 'SSSD3', 'SSSD4'};
end
