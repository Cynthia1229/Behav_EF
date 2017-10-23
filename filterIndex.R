# please set working directory as the directory of this file.

# load packages ----
library(tidyverse)

# user defined functions ----
PE_keep_idx <- function(PE, N, p = 0.5){
  mu <- p
  sigma <- sqrt(p * (1 - p) / N)
  PE < 1 - (mu + qnorm(0.95) * sigma)
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
  group_by(id) %>% 
  mutate(ranking = row_number(PE)) %>% 
  ungroup() %>% 
  filter(ranking == 1) %>% 
  select(-ranking)
write_csv(antisac_filtered, file.path(data_dir, "AntiSacFiltered.csv"))

# CateSwitch ----
