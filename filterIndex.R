# please set working directory as the directory of this file.

# load packages ----
library(tidyverse)

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
data_dir <- "EFMerge"
rate <- 0.8

# AntiSac ----
antisac <- read_csv(file.path(data_dir, "AntiSacResult.csv"))
antisac_filtered <- antisac %>% 
  # remove subjects without enough responses
  filter(NResp > rate * NTrial) %>% 
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude, 1 / 3)) %>% 
  # remove duplicate id's
  rm_dup_id(PE)
write_csv(antisac_filtered, file.path(data_dir, "AntiSacFiltered.csv"))

# CateSwitch ----
cateSwitch <- read_csv(file.path(data_dir, 'CateSwitchResult.csv'))
cateSwitch_filtered <- cateSwitch %>% 
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>% 
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>% 
  # remove duplicate id's
  rm_dup_id(PE)
write_csv(cateSwitch_filtered, file.path(data_dir, "CateSwitchFiltered.csv"))

# ShiftColor ----
shiftColor <- read_csv(file.path(data_dir, 'ShiftColorResult.csv'))
shiftColor_filtered <- shiftColor %>% 
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>% 
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>% 
  # remove duplicate id's
  rm_dup_id(PE)
write_csv(shiftColor_filtered, file.path(data_dir, "ShiftColorFiltered.csv"))

# ShiftNumber ----
shiftNumber <- read_csv(file.path(data_dir, 'ShiftNumberResult.csv'))
shiftNumber_filtered <- shiftNumber %>% 
  # remove subjects without enough responses
  filter(NInclude > rate * NTrial) %>% 
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude)) %>% 
  # remove duplicate id's
  rm_dup_id(PE)
write_csv(shiftNumber_filtered, file.path(data_dir, "ShiftNumberFiltered.csv"))

# spatialWM ---- 
spatialWM <- read_csv(file.path(data_dir, 'SpatialWMResult.csv'))
spatialWM_filtered <- spatialWM %>%
  # remove subjects without enough responses
  filter(
    NResp > rate * NTrial,
    NInclude > rate * NTrial
    ) %>% 
  # remove subjects with too many errors
  filter(PE_keep_idx(PE, NInclude))

# StopSignal ----

# Stroop ----

# WM3 ----
