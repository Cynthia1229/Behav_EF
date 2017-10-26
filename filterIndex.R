# please set working directory as the directory of this file.

# load packages ----
library(tidyverse)
library(readxl)

# user defined functions ----
PE_keep_idx <- function(PE, N, p = 0.5){
  mu <- p
  sigma <- sqrt(p * (1 - p) / N)
  PE < 1 - (mu + qnorm(0.95) * sigma)
}
rm_dup_id <- function(tbl, var_crit, fun = min){
  var_crit <- enquo(var_crit)
  tbl %>%
    group_by(id) %>%
    mutate(ranking = row_number(!!var_crit)) %>%
    filter(ranking == fun(ranking)) %>%
    ungroup() %>%
    select(-ranking)
}

# set some configurations ----
data_dir <- "EFRes"
filt_dir <- "EFFiltered"
rate <- 0.8

# AntiSac ----
antisac <- read_csv(file.path(data_dir, "AntiSacResult.csv"))
antisac_filtered <- antisac %>%
  # remove subjects without enough responses
  filter(NResp > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude, 1 / 3)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(antisac_filtered, file.path(filt_dir, "AntiSacFiltered.csv"))

# CateSwitch ----
cateSwitch <- read_csv(file.path(data_dir, "CateSwitchResult.csv"))
cateSwitch_filtered <- cateSwitch %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(cateSwitch_filtered, file.path(filt_dir, "CateSwitchFiltered.csv"))

# ShiftColor ----
shiftColor <- read_csv(file.path(data_dir, "ShiftColorResult.csv"))
shiftColor_filtered <- shiftColor %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(shiftColor_filtered, file.path(filt_dir, "ShiftColorFiltered.csv"))

# ShiftNumber ----
shiftNumber <- read_csv(file.path(data_dir, "ShiftNumberResult.csv"))
shiftNumber_filtered <- shiftNumber %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(shiftNumber_filtered, file.path(filt_dir, "ShiftNumberFiltered.csv"))

# spatialWM ----
spatialWM <- read_csv(file.path(data_dir, "SpatialWMResult.csv"))
spatialWM_filtered <- spatialWM %>%
  filter(
    # remove subjects without enough responses
    NResp > rate * NTrial,
    NInclude > rate * NTrial,
    # remove subjects with too many errors
    PE_keep_idx(PE, NInclude),
    # remove subjects with abnormal dprime
    ! dprime %in% boxplot.stats(dprime)$out
    ) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(spatialWM_filtered, file.path(filt_dir, "spatialWMFiltered.csv"))

# StopSignal ----
stopSignal <- read_csv(file.path(data_dir, "StopSignalResult.csv"))
stopSignal_filtered <- stopSignal %>%
  filter(
    # remove subjects without enough responses
    NResp > rate * NTrial,
    NInclude > rate * NTrial,
    # remove subjects with too many errors
    PE_keep_idx(PE_Go, NInclude),
    # remove subjects with NaN results
    ! is.nan(SSRT),
    # remove subjects with too spread SSDs
    ! SSSD %in% boxplot.stats(SSSD)$out
  ) %>%
  # remove duplicate id"s
  rm_dup_id(PE_Go)
write_csv(stopSignal_filtered, file.path(filt_dir, "StopSignalFiltered.csv"))

# Stroop ----
stroop <- read_csv(file.path(data_dir, "StroopResult.csv"))
stroop_filtered <- stroop %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude, 1 / 4)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(stroop_filtered, file.path(filt_dir, "StroopFiltered.csv"))

# WM3 ----
WM3 <- read_csv(file.path(data_dir, "WM3Result.csv"))
WM3_filtered <- WM3 %>%
  filter(
    # remove subjects without enough responses
    NResp > rate * NTrial,
    NInclude > rate * NTrial,
    # remove subjects with too many errors
    PE_keep_idx(PE, NInclude),
    # remove subjects with abnormal dprime
    ! dprime %in% boxplot.stats(dprime)$out
  ) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(WM3_filtered, file.path(filt_dir, "WM3filtered.csv"))

# Keep track ----
keepTrack <- read_excel(file.path(data_dir, "KeepTrack.xlsx"))
keepTrack_filtered <- keepTrack %>%
  filter(! score %in% boxplot.stats(score)$out)
write_csv(keepTrack_filtered, file.path(filt_dir, "KeepTrackFiltered.csv"))
