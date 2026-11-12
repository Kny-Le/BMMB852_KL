#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) > 0L) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1L]]))
  project_dir <- dirname(dirname(script_path))
} else if (file.exists("design.csv") && file.exists(file.path("gtf", "chr22.gtf"))) {
  project_dir <- normalizePath(getwd())
} else {
  stop("Set the working directory to the project folder before sourcing this script.")
}

design_path <- file.path(project_dir, "design.csv")
gtf_path <- file.path(project_dir, "gtf", "chr22.gtf")
counts_dir <- file.path(project_dir, "counts")

if (!file.exists(design_path)) stop("Missing design file: ", design_path)
if (!file.exists(gtf_path)) stop("Missing GTF file: ", gtf_path)

design <- read.csv(design_path, stringsAsFactors = FALSE, check.names = FALSE)
if (!"sample" %in% names(design)) {
  stop("The design file must contain a 'sample' column.")
}
if (!"group" %in% names(design) || anyNA(design$group)) {
  stop("The design file must contain a non-missing 'group' column.")
}
if (!all(c("HBR", "UHR") %in% unique(design$group))) {
  stop("The design file must contain samples from both the HBR and UHR groups.")
}
samples <- design$sample
if (length(samples) == 0L || anyNA(samples) || anyDuplicated(samples)) {
  stop("The design file must list unique, non-empty sample names.")
}
hbr_samples <- design$sample[design$group == "HBR"]
uhr_samples <- design$sample[design$group == "UHR"]

quant_files <- file.path(counts_dir, samples, "quant.sf")
missing_files <- quant_files[!file.exists(quant_files)]
if (length(missing_files) > 0L) {
  stop("Missing Salmon quantification file(s):\n", paste(missing_files, collapse = "\n"))
}

# Extract quoted attributes such as transcript_id and gene_name from GTF column 9.
get_attribute <- function(attributes, key) {
  pattern <- paste0("(?:^|;\\s*)", key, '\\s+"([^";]+)"')
  matches <- regexec(pattern, attributes, perl = TRUE)
  values <- regmatches(attributes, matches)
  vapply(values, function(x) if (length(x) >= 2L) x[[2L]] else NA_character_,
         character(1))
}

gtf <- read.delim(
  gtf_path,
  header = FALSE,
  sep = "\t",
  quote = "",
  comment.char = "#",
  stringsAsFactors = FALSE
)
transcript_rows <- gtf[gtf[[3L]] == "transcript", c(3L, 9L), drop = FALSE]
transcript_map <- data.frame(
  transcript_id = get_attribute(transcript_rows[[2L]], "transcript_id"),
  gene_id = get_attribute(transcript_rows[[2L]], "gene_id"),
  gene_name = get_attribute(transcript_rows[[2L]], "gene_name"),
  stringsAsFactors = FALSE
)
transcript_map <- unique(transcript_map[complete.cases(transcript_map), ])
if (nrow(transcript_map) == 0L) {
  stop("No transcript-to-gene mappings with gene names were found in the GTF.")
}
if (anyDuplicated(transcript_map$transcript_id)) {
  stop("The GTF contains conflicting gene mappings for a transcript ID.")
}

quant_tables <- lapply(quant_files, function(path) {
  read.delim(path, stringsAsFactors = FALSE, check.names = FALSE)
})
names(quant_tables) <- samples
if (!all(vapply(quant_tables, function(x) all(c("Name", "NumReads") %in% names(x)),
                logical(1)))) {
  stop("Each quant.sf file must contain 'Name' and 'NumReads' columns.")
}

transcript_ids <- quant_tables[[1L]]$Name
if (anyDuplicated(transcript_ids)) stop("Duplicate transcript IDs found in quant.sf.")
for (sample in samples) {
  current_ids <- quant_tables[[sample]]$Name
  if (length(current_ids) != length(transcript_ids) ||
      !setequal(current_ids, transcript_ids)) {
    stop("Transcript IDs differ between quant.sf files (sample: ", sample, ").")
  }
}

transcript_map <- transcript_map[match(transcript_ids, transcript_map$transcript_id), ]
if (anyNA(transcript_map$gene_id) || anyNA(transcript_map$gene_name)) {
  unmapped <- transcript_ids[is.na(transcript_map$gene_id) | is.na(transcript_map$gene_name)]
  stop("Some quantified transcripts have no gene mapping/name in the GTF. Examples: ",
       paste(head(unmapped, 10L), collapse = ", "))
}

transcript_counts <- vapply(samples, function(sample) {
  quant_table <- quant_tables[[sample]]
  quant_table$NumReads[match(transcript_ids, quant_table$Name)]
}, numeric(length(transcript_ids)))
colnames(transcript_counts) <- samples

transcript_output <- data.frame(
  transcript_id = transcript_ids,
  gene_id = transcript_map$gene_id,
  gene_name = transcript_map$gene_name,
  transcript_counts,
  check.names = FALSE
)

gene_ids <- unique(transcript_map$gene_id)
gene_names <- vapply(gene_ids, function(id) {
  names_for_gene <- unique(transcript_map$gene_name[transcript_map$gene_id == id])
  if (length(names_for_gene) != 1L) {
    stop("Gene ID ", id, " has inconsistent gene names in the GTF.")
  }
  names_for_gene[[1L]]
}, character(1))
gene_count_values <- rowsum(transcript_counts, group = transcript_map$gene_id,
                            reorder = FALSE)
gene_count_values <- gene_count_values[gene_ids, , drop = FALSE]
gene_output <- data.frame(
  gene_id = gene_ids,
  gene_name = gene_names,
  gene_count_values,
  check.names = FALSE
)

# Normalize gene counts to counts per million (CPM) for comparing samples.
library_sizes <- colSums(gene_count_values)
if (any(library_sizes == 0)) {
  stop("Cannot calculate CPM because at least one sample has zero gene counts.")
}
gene_cpm <- sweep(gene_count_values, 2L, library_sizes, "/") * 1e6

# Average normalized expression within each group and calculate the UHR/HBR ratio.
hbr_mean_cpm <- rowMeans(gene_cpm[, hbr_samples, drop = FALSE])
uhr_mean_cpm <- rowMeans(gene_cpm[, uhr_samples, drop = FALSE])
gene_group_summary <- data.frame(
  gene_id = gene_ids,
  gene_name = gene_names,
  HBR_mean_CPM = hbr_mean_cpm,
  UHR_mean_CPM = uhr_mean_cpm,
  log2FC_UHR_over_HBR = log2((uhr_mean_cpm + 1) / (hbr_mean_cpm + 1)),
  check.names = FALSE
)
gene_cpm_output <- data.frame(
  gene_id = gene_ids,
  gene_name = gene_names,
  gene_cpm,
  check.names = FALSE
)

write.table(
  transcript_output,
  file.path(counts_dir, "transcript_counts.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)
write.table(
  gene_output,
  file.path(counts_dir, "gene_counts.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)
write.table(
  gene_cpm_output,
  file.path(counts_dir, "gene_cpm.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)
write.table(
  gene_group_summary,
  file.path(counts_dir, "gene_group_summary.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)

message("Wrote transcript-level counts to counts/transcript_counts.tsv")
message("Wrote gene-level counts to counts/gene_counts.tsv")
message("Wrote normalized gene counts to counts/gene_cpm.tsv")
message("Wrote HBR/UHR gene summaries to counts/gene_group_summary.tsv")