#!/usr/bin/env Rscript

# Classify the simulated genes retained in each differential-expression result.
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) != 1L) stop("Run with Rscript src/classify_simulation.R")
project_dir <- dirname(dirname(normalizePath(sub("^--file=", "", file_arg[[1L]]))))
out_dir <- file.path(project_dir, "results", "simulation")
truth <- read.csv(file.path(out_dir, "simulated_counts.csv"), stringsAsFactors = FALSE)
if (!all(c("id", "status") %in% names(truth)) || anyNA(truth$id) ||
    anyDuplicated(truth$id) || anyNA(truth$status) ||
    any(!truth$status %in% c("changed", "unchanged"))) {
  stop("Simulation counts must have unique IDs and valid status labels.")
}

summaries <- lapply(c("edger", "deseq2"), function(method) {
  result <- read.csv(file.path(out_dir, paste0(method, ".csv")), stringsAsFactors = FALSE)
  if (!all(c("id", "status", "FDR") %in% names(result)) || anyNA(result$id) ||
      anyDuplicated(result$id) || !is.numeric(result$FDR) ||
      any(!is.finite(result$FDR)) || any(result$FDR < 0 | result$FDR > 1)) {
    stop("Invalid ID, status, or FDR in ", method, " results.")
  }
  truth_index <- match(result$id, truth$id)
  if (anyNA(truth_index) || anyNA(result$status) ||
      any(result$status != truth$status[truth_index])) {
    stop("Result IDs or statuses do not match simulation truth for ", method)
  }
  changed <- result$status == "changed"
  called <- result$FDR < 0.05
  result$classification <- ifelse(changed, ifelse(called, "TP", "FN"),
                                  ifelse(called, "FP", "TN"))
  write.csv(result, file.path(out_dir, paste0(method, "_classified.csv")),
            row.names = FALSE, na = "NA")
  excluded <- !truth$id %in% result$id
  data.frame(method = method, TP = sum(result$classification == "TP"),
             FP = sum(result$classification == "FP"),
             TN = sum(result$classification == "TN"),
             FN = sum(result$classification == "FN"), tested = nrow(result),
             excluded_changed = sum(excluded & truth$status == "changed"),
             excluded_unchanged = sum(excluded & truth$status == "unchanged"))
})
summary <- do.call(rbind, summaries)
write.csv(summary, file.path(out_dir, "classification_summary.csv"), row.names = FALSE)
print(summary, row.names = FALSE)