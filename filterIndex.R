# please set working directory as the directory of this file.

# load packages ----
library(tidyverse)
library(readxl)

# clear jobs ----
rm(list = ls())

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
data_suffix <- "Result"
filt_suffix <- "Filtered"
file_ext <- ".csv"

# AntiSac ----
taskname <- "AntiSac"
antisac <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
antisac_filtered <- antisac %>%
  # remove subjects without enough responses
  filter(NResp > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude, 1 / 3)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(antisac_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# CateSwitch ----
taskname <- "CateSwitch"
cateSwitch <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
cateSwitch_filtered <- cateSwitch %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(cateSwitch_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# ShiftColor ----
taskname <- "ShiftColor"
shiftColor <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
shiftColor_filtered <- shiftColor %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(shiftColor_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# ShiftNumber ----
taskname <- "ShiftNumber"
shiftNumber <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
shiftNumber_filtered <- shiftNumber %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(shiftNumber_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# spatialWM ----
taskname <- "spatialWM"
spatialWM <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
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
write_csv(spatialWM_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# StopSignal ----
taskname <- "StopSignal"
stopSignal <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
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
write_csv(stopSignal_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# Stroop ----
taskname <- "Stroop"
stroop <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
stroop_filtered <- stroop %>%
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>%
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude, 1 / 4)) %>%
  # remove duplicate id"s
  rm_dup_id(PE)
write_csv(stroop_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# WM3 ----
taskname <- "WM3"
WM3 <- read_csv(file.path(data_dir, paste0(taskname, data_suffix, file_ext)))
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
write_csv(WM3_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))

# Keep track ----
taskname <- "KeepTrack"
keepTrack <- read_excel(file.path(data_dir, "KeepTrack.xlsx"))
keepTrack_filtered <- keepTrack %>%
  filter(
    # remove subjects with NA results
    ! is.na(score),
    # remove subjects with abnormal score
    ! score %in% boxplot.stats(score)$out
    ) %>%
  rename(id = ID)
write_csv(keepTrack_filtered, file.path(filt_dir, paste0(taskname, filt_suffix, file_ext)))
