# Minimal model specification for external reuse.

required_panel_columns <- c(
  "subject_id", "time", "state", "ic", "environment",
  "age10", "female", "chronic_centered"
)

validate_panel <- function(panel) {
  missing <- setdiff(required_panel_columns, names(panel))
  if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))
  if (!all(panel$state %in% 1:3)) stop("state must be 1, 2, or 3")
  if (anyDuplicated(panel[c("subject_id", "time")])) {
    stop("Each subject-time combination must be unique")
  }
  invisible(TRUE)
}

initial_transition_matrix <- function(rate = 0.05) {
  if (!is.numeric(rate) || length(rate) != 1 || rate <= 0) stop("rate must be positive")
  q <- matrix(0, nrow = 3, ncol = 3)
  q[1, 2] <- rate
  q[1, 3] <- rate
  q[2, 1] <- rate
  q[2, 3] <- rate
  diag(q) <- -rowSums(q)
  dimnames(q) <- list(
    c("independent", "observed_disability", "death"),
    c("independent", "observed_disability", "death")
  )
  q
}

fit_cohort_model <- function(panel, qmatrix = initial_transition_matrix(), maxit = 2000) {
  if (!requireNamespace("msm", quietly = TRUE)) stop("Package 'msm' is required")
  validate_panel(panel)
  panel$ic_environment <- panel$ic * panel$environment
  panel <- panel[order(panel$subject_id, panel$time), ]
  msm::msm(
    state ~ time,
    subject = subject_id,
    data = panel,
    qmatrix = qmatrix,
    deathexact = 3,
    covariates = ~ ic + environment + ic_environment + age10 + female + chronic_centered,
    center = FALSE,
    method = "BFGS",
    control = list(maxit = maxit, fnscale = nrow(panel), reltol = 1e-8)
  )
}

pool_stage1_estimates <- function(stage1) {
  if (!requireNamespace("metafor", quietly = TRUE)) stop("Package 'metafor' is required")
  required <- c("cohort", "transition", "log_hr", "se")
  missing <- setdiff(required, names(stage1))
  if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))

  pooled <- lapply(split(stage1, stage1$transition), function(data) {
    model <- metafor::rma(
      yi = data$log_hr, sei = data$se, method = "REML", test = "knha"
    )
    prediction <- predict(model)
    data.frame(
      transition = data$transition[1],
      cohorts = nrow(data),
      log_hr = as.numeric(coef(model)),
      hr = exp(as.numeric(coef(model))),
      lower = exp(model$ci.lb),
      upper = exp(model$ci.ub),
      p_value = model$pval,
      i2 = model$I2,
      prediction_lower = exp(prediction$pi.lb),
      prediction_upper = exp(prediction$pi.ub)
    )
  })
  do.call(rbind, pooled)
}
