#!/usr/bin/env Rscript

# Compare existing DE results with independent gene-level simulation truth.
# Usage: Rscript src/compare_known_state.R path/to/known_states.csv [output_dir]
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L || length(args) > 2L) {
  stop("Usage: Rscript src/compare_known_state.R known_states.csv [output_dir]")
}
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
project_dir <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[[1L]]))))
truth_path <- args[[1L]]
out_dir <- if (length(args) == 2L) args[[2L]] else file.path(project_dir, "results")
if (!file.exists(truth_path)) stop("Known-state CSV does not exist: ", truth_path)

truth <- read.csv(truth_path, stringsAsFactors = FALSE, colClasses = "character",
                  check.names = FALSE, na.strings = c("", "NA"))
if (!all(c("gene_id", "known_state") %in% names(truth))) {
  stop("Known-state CSV must have gene_id and known_state columns.")
}
truth$gene_id <- trimws(truth$gene_id)
truth$known_state <- tolower(trimws(truth$known_state))
if (anyNA(truth$gene_id) || any(!nzchar(truth$gene_id)) || anyDuplicated(truth$gene_id)) {
  stop("Known-state gene_id values must be nonempty and unique.")
}
if (anyNA(truth$known_state) || any(!truth$known_state %in% c("changed", "unchanged"))) {
  stop("Every known_state must be 'changed' or 'unchanged'.")
}

compare_method <- function(method, fdr_column) {
  path <- file.path(project_dir, "results", paste0(method, ".csv"))
  if (!file.exists(path)) stop("Missing differential expression results: ", path)
  result <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  if (!all(c("gene_id", fdr_column) %in% names(result)) ||
      anyNA(result$gene_id) || any(!nzchar(result$gene_id)) || anyDuplicated(result$gene_id)) {
    stop("Invalid gene_id or missing adjusted p-value column in ", path)
  }
  fdr <- result[[fdr_column]]
  if (!is.numeric(fdr) || any(!is.finite(fdr[!is.na(fdr)])) ||
      any(fdr[!is.na(fdr)] < 0 | fdr[!is.na(fdr)] > 1)) {
    stop("Adjusted p-values must be numeric values between 0 and 1, or NA: ", path)
  }
  result$known_state <- truth$known_state[match(result$gene_id, truth$gene_id)]
  result$classification <- NA_character_
  valid <- !is.na(result$known_state) & !is.na(fdr)
  result$classification[valid & result$known_state == "changed" & fdr < 0.05] <- "TP"
  result$classification[valid & result$known_state == "unchanged" & fdr < 0.05] <- "FP"
  result$classification[valid & result$known_state == "unchanged" & fdr >= 0.05] <- "TN"
  result$classification[valid & result$known_state == "changed" & fdr >= 0.05] <- "FN"
  if (!any(!is.na(result$known_state))) {
    stop("No known-state gene IDs match ", method, " results; check IDs and versions.")
  }
  counts <- table(factor(result$classification, levels = c("TP", "FP", "TN", "FN")))
  summary <- data.frame(
    method = method, TP = unname(counts["TP"]), FP = unname(counts["FP"]),
    TN = unname(counts["TN"]), FN = unname(counts["FN"]),
    result_genes = nrow(result),
    missing_truth = sum(is.na(result$known_state)),
    missing_adjusted_p_with_truth = sum(!is.na(result$known_state) & is.na(fdr)),
    truth_genes_not_in_results = sum(!truth$gene_id %in% result$gene_id)
  )
  list(result = result, summary = summary)
}

# DESeq2's padj is its BH-adjusted p-value; edgeR calls the equivalent column FDR.
comparisons <- list(deseq2 = compare_method("deseq2", "padj"),
                    edger = compare_method("edger", "FDR"))
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
for (method in names(comparisons)) {
  write.csv(comparisons[[method]]$result,
            file.path(out_dir, paste0(method, "_known_state_comparison.csv")),
            row.names = FALSE, na = "NA")
}
summary <- do.call(rbind, lapply(comparisons, `[[`, "summary"))
write.csv(summary, file.path(out_dir, "classification_summary.csv"), row.names = FALSE)
print(summary, row.names = FALSE)