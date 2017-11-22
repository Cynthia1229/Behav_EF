# load packages ----
library(tidyverse)
library(readxl)
library(stringr)

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
base_dir <- getSrcDirectory(function(x) x)
data_dir <- file.path(base_dir, "EFRes")
filt_dir <- file.path(base_dir, "EFFiltered")
rate <- 0.8
data_suffix <- "Result"
filt_suffix <- "Filtered"
file_ext <- ".csv"
indices <- read_csv(file.path(filt_dir, "index_map.csv"))
index_map <- setNames(indices$index, indices$Taskname)

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
  # remove subjects with abnormal switch costs
  filter(! MRT_diff %in% boxplot.stats(MRT_diff)$out) %>%
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
  # remove subjects with abnormal switch costs
  filter(! MRT_diff %in% boxplot.stats(MRT_diff)$out) %>%
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
  # remove subjects with abnormal switch costs
  filter(! MRT_diff %in% boxplot.stats(MRT_diff)$out) %>%
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
  gather(type, value, MSSD1:SSSD4) %>%
  separate(type, c("var", "ssd_cat"), -2) %>%
  spread(var, value) %>%
  # remove nonpositive MSSD
  filter(SSSD != 0) %>%
  group_by(ssd_cat) %>%
  # remove MSSD outlier
  mutate(MSSD = ifelse(MSSD %in% robustbase::adjboxStats(MSSD)$out, NA, MSSD)) %>%
  group_by_at(vars(id:PE_Stop)) %>%
  summarise(
    SSSD = sd(MSSD, na.rm = TRUE),
    MSSD = mean(MSSD, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(SSRT = MRT_Go - MSSD) %>%
  filter(
    # remove subjects without enough responses
    NResp > rate * NTrial,
    NInclude > rate * NTrial,
    # remove subjects with too many errors
    PE_keep_idx(PE_Go, NInclude),
    # remove subjects with NaN results
    ! is.nan(SSRT),
    # remove subjects with too spread SSDs
    ! SSSD %in% boxplot.stats(SSSD)$out,
    # remove subjects with abnormal stop signal RT
    ! SSRT %in% boxplot.stats(SSRT)$out
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
  # remove subjects with abnormal Incongruent-Congruent RT
  filter(! MRT_diff %in% boxplot.stats(MRT_diff)$out) %>%
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

# merge datasets ----
data_files <- list.files(filt_dir, "*Filtered*")
data_merged <- data_files %>%
  map(
    function (x){
      taskname <- str_match(x, ".+(?=Filtered)")
      index <- index_map[taskname]
      read_csv(file.path(filt_dir, x)) %>%
        select(one_of("id", index)) %>%
        # filter(id %in% sublist) %>%
        rename(!!taskname := !!index)
    }
  ) %>%
  reduce(
    function(x, y){
      full_join(x, y, by = "id")
    }
  ) %>%
  filter_all(all_vars(!is.na(.)))
write_csv(data_merged, file.path(filt_dir, "ef_behav_all.csv"))
