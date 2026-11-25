#!/usr/bin/env Rscript

# Convert Week 12's gene count table to the required id-column CSV format.
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
project_dir <- dirname(dirname(normalizePath(sub("^--file=", "", file_arg[[1L]]))))
design <- read.csv(file.path(project_dir, "design.csv"), stringsAsFactors = FALSE)
counts <- read.delim(file.path(project_dir, "counts", "gene_counts.tsv"), check.names = FALSE)
if (!all(c("gene_id", "gene_name", design$sample) %in% names(counts)) ||
    anyDuplicated(counts$gene_id) || anyNA(counts$gene_id) ||
    anyNA(counts[, design$sample, drop = FALSE])) stop("Invalid design or count table.")
counts <- counts[, c("gene_id", "gene_name", design$sample), drop = FALSE]
names(counts)[1L] <- "id"
output_dir <- file.path(project_dir, "results", "hbr_uhr")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(counts, file.path(output_dir, "gene_counts.csv"), row.names = FALSE)
cat("Wrote Week 12 gene counts in CSV format.\n")