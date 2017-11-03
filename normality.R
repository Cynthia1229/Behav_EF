# load packages ----
library(tidyverse)
library(stringr)
library(psych)
library(extrafont)

# clear jobs ----
rm(list = ls())

# configurations ----
setwd(getSrcDirectory(function(x) x))
filt_dir <- "EFFiltered"
sublist <- parse_integer(read_lines(file.path(filt_dir, "sublist.txt")))

# read and filter data ----
ef_data_raw <- read_csv(file.path(filt_dir, "ef_behav_all.csv")) %>%
  filter(id %in% sublist) %>%
  select(-id)

# data transformation in order that high score -> high ability
ef_data_tran <- ef_data_raw %>%
  mutate(
    # logit transformation to stabilize
    AntiSac = logit(1 - AntiSac),
    CateSwitch = - CateSwitch,
    # due to the small sample size, use Bayesian estimation
    # PC = (n + 1) / (N + 2)
    KeepTrack = logit((KeepTrack + 1) / 38),
    ShiftColor = - ShiftColor,
    ShiftNumber = - ShiftNumber,
    StopSignal = - StopSignal,
    Stroop = - Stroop
  )

# standardisation ----
ef_data_tran_scale <- ef_data_tran %>%
  mutate_all(scale)

# descriptive statistics ----
ef_data_tran_scale %>%
  do(describe(.))

# visualisation raw data ----
ef_data_raw_stack <- gather(ef_data_raw, task, score) %>%
  mutate(
    task = factor(
      task,
      levels = c(
        "AntiSac", "StopSignal", "Stroop",
        "CateSwitch", "ShiftColor", "ShiftNumber",
        "KeepTrack", "spatialWM", "WM3")
    )
  )
ggplot(ef_data_raw_stack, aes(score, fill = task)) +
  geom_histogram() +
  facet_wrap(~ task, scales = "free") +
  labs(title = "Distribution of raw scores") +
  theme_minimal() +
  theme(
    plot.title = element_text(family = "Gill Sans MT", size = 20, hjust = 0.5, margin = margin(b = 20)),
    axis.title = element_text(family = "Gill Sans MT", size = 16),
    axis.text = element_text(family = "Gill Sans MT", size = 12),
    legend.text = element_text(family = "Gill Sans MT", size = 12),
    strip.text = element_text(family = "Gill Sans MT", size = 16),
    legend.title = element_text(family = "Gill Sans MT", size = 16),
    plot.margin = margin(20, 20, 20, 20)
  )
ggsave("Distribution Raw Data.jpg")

# visualisation transformed data ----
ef_data_tran_stack <- gather(ef_data_tran, task, score) %>%
  mutate(
    task = factor(
      task,
      levels = c(
        "AntiSac", "StopSignal", "Stroop",
        "CateSwitch", "ShiftColor", "ShiftNumber",
        "KeepTrack", "spatialWM", "WM3")
    )
  )
ggplot(ef_data_tran_stack, aes(score, fill = task)) +
  geom_histogram() +
  facet_wrap(~ task, scales = "free") +
  labs(title = "Distribution of transformed scores") +
  theme_minimal() +
  theme(
    plot.title = element_text(family = "Gill Sans MT", size = 20, hjust = 0.5, margin = margin(b = 20)),
    axis.title = element_text(family = "Gill Sans MT", size = 16),
    axis.text = element_text(family = "Gill Sans MT", size = 12),
    legend.text = element_text(family = "Gill Sans MT", size = 12),
    strip.text = element_text(family = "Gill Sans MT", size = 16),
    legend.title = element_text(family = "Gill Sans MT", size = 16),
    plot.margin = margin(20, 20, 20, 20)
  )
ggsave("Distribution Transformed Data.jpg")

# visualisation scaled data in Q-Q plot ----
ef_data_scale_stack <- gather(ef_data_tran_scale, task, score) %>%
  mutate(
    task = factor(
      task,
      levels = c(
        "AntiSac", "StopSignal", "Stroop",
        "CateSwitch", "ShiftColor", "ShiftNumber",
        "KeepTrack", "spatialWM", "WM3")
      )
    )
ggplot(ef_data_scale_stack, aes(sample = score, color = task)) +
  stat_qq() +
  geom_abline(slope = 1, intercept = 0, alpha = 0.5, linetype = "dashed") +
  facet_wrap(~ task) +
  labs(title = "Q-Q plot of all tasks") +
  theme_minimal() +
  theme(
    plot.title = element_text(family = "Gill Sans MT", size = 20, hjust = 0.5, margin = margin(b = 20)),
    axis.title = element_text(family = "Gill Sans MT", size = 16),
    axis.text = element_text(family = "Gill Sans MT", size = 12),
    legend.text = element_text(family = "Gill Sans MT", size = 12),
    strip.text = element_text(family = "Gill Sans MT", size = 16),
    legend.title = element_text(family = "Gill Sans MT", size = 16),
    plot.margin = margin(20, 20, 20, 20)
    )
ggsave("QQ-plot.jpg")

mardia(ef_data_tran_scale)
