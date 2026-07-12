suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(patchwork)
  library(readr)
})

script_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
script_file <- gsub("~+~", " ", script_file, fixed = TRUE)
root <- normalizePath(file.path(dirname(script_file), ".."), mustWork = TRUE)
data <- read_csv(file.path(root, "data", "aggregate_figure_data.csv"), show_col_types = FALSE)
output_dir <- Sys.getenv("FIGURE_OUTPUT_DIR", file.path(root, "figures"))
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

ink <- "#263238"
blue <- "#0072B2"
green <- "#009E73"
orange <- "#E69F00"
grey <- "#7B8794"
light_blue <- "#DDEEF7"
theme_public <- theme_minimal(base_size = 10) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.text = element_text(color = ink),
    axis.title = element_text(color = ink),
    plot.title = element_text(face = "bold", color = ink),
    plot.background = element_rect(fill = "white", color = NA)
  )

# Figure 1: cohorts, analysis populations, and allowed transitions.
cohorts <- data %>% filter(figure == 1, analysis == "cohort") %>% arrange(row_order)
populations <- data %>% filter(figure == 1, analysis == "population") %>% arrange(row_order)
figure1 <- ggplot() + xlim(0, 10) + ylim(0, 10) + theme_void() +
  annotate("text", x = 0.4, y = 9.6, label = "A  Cohorts and analysis populations",
           hjust = 0, fontface = "bold", size = 4) +
  annotate("rect", xmin = seq(0.5, 8.5, 2), xmax = seq(1.7, 9.7, 2),
           ymin = 8.2, ymax = 9.0, fill = "#EAF4FA", color = blue) +
  annotate("text", x = seq(1.1, 9.1, 2), y = 8.6, label = cohorts$label, size = 3.5) +
  annotate("rect", xmin = 2.4, xmax = 7.6, ymin = 6.5, ymax = 7.4,
           fill = "#E9F6F1", color = green) +
  annotate("text", x = 5, y = 6.95,
           label = sprintf("%s\nN=%s | %s state records", populations$label[1],
                           format(populations$n[1], big.mark = ","),
                           format(populations$records[1], big.mark = ",")), size = 3.5) +
  annotate("rect", xmin = c(0.5, 3.6, 6.7), xmax = c(3.3, 6.4, 9.5),
           ymin = 4.8, ymax = 5.7, fill = c("#FFF4DE", "#F3EAF7", "#EAF4FA"),
           color = c(orange, "#8E5AA8", blue)) +
  annotate("text", x = c(1.9, 5.0, 8.1), y = 5.25,
           label = c(
             sprintf("Episode history\nN=%s", format(populations$n[2], big.mark = ",")),
             sprintf("Reciprocal temporal\nN=%s", format(populations$n[3], big.mark = ",")),
             sprintf("Qualitative replication\nN=%s", format(populations$n[4], big.mark = ","))
           ), size = 3.2) +
  annotate("text", x = 0.4, y = 4.1, label = "B  Primary disability-state model",
           hjust = 0, fontface = "bold", size = 4) +
  annotate("rect", xmin = c(0.8, 4.0, 7.4), xmax = c(2.6, 5.8, 9.2),
           ymin = 2.2, ymax = 3.1, fill = c("#E9F6F1", "#FFF4DE", "#EEEEEE"),
           color = c(green, orange, grey)) +
  annotate("text", x = c(1.7, 4.9, 8.3), y = 2.65,
           label = c("Independent", "Observed disability", "Death"), size = 3.4) +
  annotate("segment", x = c(2.6, 4.0, 2.6, 5.8), xend = c(4.0, 2.6, 7.4, 7.4),
           y = c(2.85, 2.45, 2.45, 2.85), yend = c(2.85, 2.45, 2.45, 2.85),
           arrow = arrow(length = unit(0.12, "inches")), color = ink)
ggsave(file.path(output_dir, "Figure1.pdf"), figure1, width = 11, height = 7.5)

transition_labels <- c(
  independent_to_disability = "Independence to disability",
  disability_to_recovery = "Disability to independence",
  independent_to_death = "Independence to death",
  disability_to_death = "Disability to death"
)

pooled <- data %>% filter(figure == 2, analysis == "pooled_transition") %>%
  mutate(display = factor(transition_labels[label], levels = rev(transition_labels)))
p2a <- ggplot(pooled, aes(estimate, display)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0) +
  geom_point(color = blue, size = 2.8) +
  scale_x_log10() + labs(title = "A  Transition-specific interactions",
                          x = "IC-by-environment interaction HR", y = NULL) + theme_public

cohort <- data %>% filter(figure == 2, analysis == "cohort_onset") %>%
  mutate(label = factor(label, levels = rev(label)))
p2b <- ggplot(cohort, aes(estimate, label)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0) +
  geom_point(aes(color = cohort == "Pooled"), size = 2.8) +
  scale_color_manual(values = c(`TRUE` = blue, `FALSE` = grey), guide = "none") +
  scale_x_log10() + labs(title = "B  Primary interaction by cohort",
                          x = "IC-by-environment interaction HR", y = NULL) + theme_public

conditional <- data %>% filter(figure == 2, analysis == "conditional_environment") %>%
  mutate(ic_level = factor(ic_level, levels = c("lower", "mean", "higher"),
                           labels = c("Mean - 1 SD", "Mean", "Mean + 1 SD")))
p2c <- ggplot(conditional, aes(ic_level, estimate, group = 1)) +
  geom_hline(yintercept = 1, linetype = "dashed") +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0) +
  geom_line(color = blue) + geom_point(color = blue, size = 2.8) +
  labs(title = "C  Environment association across IC", x = "Intrinsic capacity",
       y = "Environment HR") + theme_public

robustness <- data %>% filter(figure == 2, analysis == "robustness") %>%
  mutate(label = factor(label, levels = rev(label)))
p2d <- ggplot(robustness, aes(estimate, label)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0) +
  geom_point(color = blue, size = 2.6) + scale_x_log10() +
  labs(title = "D  Sensitivity analyses", x = "IC-by-environment interaction HR", y = NULL) +
  theme_public
figure2 <- (p2a | p2b) / (p2c | p2d)
ggsave(file.path(output_dir, "Figure2.pdf"), figure2, width = 12, height = 8.5)

absolute <- data %>% filter(figure == 3, analysis == "absolute_contrast") %>%
  mutate(ic_level = factor(ic_level, levels = c("lower", "mean", "higher"),
                           labels = c("Mean - 1 SD", "Mean", "Mean + 1 SD")))
probability <- absolute %>% filter(metric != "independent_years") %>%
  mutate(outcome = if_else(metric == "onset_probability", "Disability onset", "Independent state"),
         estimate = 100 * estimate, lower = 100 * lower, upper = 100 * upper)
p3a <- ggplot(probability, aes(estimate, ic_level, color = outcome, shape = outcome)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0,
                position = position_dodge(width = 0.45)) +
  geom_point(position = position_dodge(width = 0.45), size = 2.8) +
  scale_color_manual(values = c("Disability onset" = blue, "Independent state" = green)) +
  guides(color = guide_legend(title = NULL), shape = guide_legend(title = NULL)) +
  labs(title = "A  Five-year state-probability contrasts",
       x = "Absolute difference (percentage points)", y = NULL) + theme_public

years <- absolute %>% filter(metric == "independent_years")
p3b <- ggplot(years, aes(estimate, ic_level)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0) +
  geom_point(color = green, size = 2.8) +
  labs(title = "B  Independent time", x = "Five-year difference (years)", y = NULL) +
  theme_public

history <- data %>% filter(figure == 3, analysis == "history_difference") %>%
  mutate(
    display = recode(
      label,
      recurrent_onset_vs_first_onset = "Recurrent vs first observed\ndisability",
      late_recovery_vs_early_recovery = "Late vs early observed\nrecovery",
      death_after_persistent_disability_vs_death_after_new_disability =
        "Death after persistent vs newly\nobserved disability"
    ),
    display = factor(display, levels = rev(display))
  )
p3c <- ggplot(history, aes(estimate, display)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0) +
  geom_point(color = orange, size = 2.8) + scale_x_log10() +
  labs(title = "C  Episode-history contrasts", x = "Ratio of interaction HRs", y = NULL) +
  theme_public

phase_labels <- c(
  first_onset = "First observed disability since entry",
  recurrent_onset = "Recurrent disability",
  early_recovery = "Early observed recovery",
  late_recovery = "Late observed recovery"
)
phase <- data %>% filter(figure == 3, analysis == "episode_phase") %>%
  mutate(display = factor(phase_labels[label], levels = rev(phase_labels)))
p3d <- ggplot(phase, aes(estimate, display)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0) +
  geom_point(color = grey, size = 2.8) + scale_x_log10() +
  labs(title = "D  Episode-specific estimates", x = "IC-by-environment interaction HR", y = NULL) +
  theme_public
figure3 <- (p3a | p3b) / (p3c | p3d)
ggsave(file.path(output_dir, "Figure3.pdf"), figure3, width = 12, height = 8.5)
