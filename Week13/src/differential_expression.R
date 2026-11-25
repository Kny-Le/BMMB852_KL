#!/usr/bin/env Rscript

# Run with Rscript src/differential_expression.R from any working directory.
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) != 1L) stop("Run this script with Rscript.")
project_dir <- dirname(dirname(normalizePath(sub("^--file=", "", file_arg))))
for (pkg in c("tximport", "DESeq2", "edgeR")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)
}
suppressPackageStartupMessages(library(DESeq2))

design <- read.csv(file.path(project_dir, "design.csv"), stringsAsFactors = FALSE)
if (!all(c("sample", "group") %in% names(design)) || anyNA(design$sample) ||
    anyNA(design$group) || any(!nzchar(design$sample)) || anyDuplicated(design$sample) ||
    !setequal(unique(design$group), c("HBR", "UHR")) ||
    any(table(design$group) < 2)) {
  stop("Design must contain unique sample names and at least two samples per HBR/UHR group.")
}
design$group <- factor(design$group, levels = c("HBR", "UHR"))
rownames(design) <- design$sample
quant_files <- setNames(file.path(project_dir, "counts", design$sample, "quant.sf"), design$sample)
if (any(!file.exists(quant_files))) stop("Missing quantification: ", paste(quant_files[!file.exists(quant_files)], collapse = ", "))

# Week 12's transcript table contains the transcript-to-gene map derived from its GTF.
transcripts <- read.delim(file.path(project_dir, "counts", "transcript_counts.tsv"),
                          check.names = FALSE, stringsAsFactors = FALSE)
if (!all(c("transcript_id", "gene_id", "gene_name") %in% names(transcripts))) {
  stop("The transcript table must contain transcript_id, gene_id, and gene_name.")
}
map <- unique(transcripts[, c("transcript_id", "gene_id", "gene_name")])
if (anyNA(map) || any(!nzchar(map$transcript_id)) || any(!nzchar(map$gene_id)) ||
    anyDuplicated(map$transcript_id)) stop("Invalid or conflicting transcript-to-gene mappings.")
gene_names <- unique(map[, c("gene_id", "gene_name")])
if (anyDuplicated(gene_names$gene_id)) stop("A gene ID has multiple gene names.")
quant_ids <- read.delim(quant_files[[1L]], stringsAsFactors = FALSE)$Name
if (anyDuplicated(quant_ids) || !setequal(quant_ids, map$transcript_id)) {
  stop("Transcript IDs in the mapping and Salmon quantification do not match.")
}

txi <- tximport::tximport(quant_files, type = "salmon",
                          tx2gene = map[, c("transcript_id", "gene_id")],
                          dropInfReps = TRUE)
dds <- DESeqDataSetFromTximport(txi, colData = design, design = ~ group)
# Remove genes with fewer than 10 estimated counts across all six samples.
keep <- rowSums(counts(dds)) >= 10
kept_gene_ids <- rownames(dds)[keep]
dds <- dds[keep, ]
if (nrow(dds) == 0L) stop("No genes passed the count filter.")
dds <- DESeq(dds)
res <- results(dds, contrast = c("group", "UHR", "HBR"), alpha = 0.05)
result_table <- as.data.frame(res)
result_table$gene_id <- rownames(result_table)
result_table$gene_name <- gene_names$gene_name[match(result_table$gene_id, gene_names$gene_id)]
result_table <- result_table[, c("gene_id", "gene_name", "baseMean", "log2FoldChange",
                                  "lfcSE", "stat", "pvalue", "padj")]
result_table <- result_table[order(result_table$padj, result_table$pvalue, na.last = TRUE), ]
significant <- result_table[!is.na(result_table$padj) & result_table$padj < 0.05, ]

out_dir <- file.path(project_dir, "results")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
write.csv(result_table, file.path(out_dir, "deseq2.csv"), row.names = FALSE, na = "NA")
write.table(result_table, file.path(out_dir, "deseq2_all_genes.tsv"),
            sep = "\t", quote = FALSE, row.names = FALSE, na = "NA")
write.table(significant, file.path(out_dir, "deseq2_significant_genes.tsv"),
            sep = "\t", quote = FALSE, row.names = FALSE, na = "NA")
normalized <- counts(dds, normalized = TRUE)
normalized <- data.frame(gene_id = rownames(normalized),
                         gene_name = gene_names$gene_name[match(rownames(normalized), gene_names$gene_id)],
                         normalized, check.names = FALSE)
write.table(normalized, file.path(out_dir, "normalized_counts.tsv"),
            sep = "\t", quote = FALSE, row.names = FALSE)

# Use tximport's length-scaled counts for edgeR, rather than DESeq2's length offsets.
# Apply the same pre-filter as DESeq2 so both CSV files contain the same genes.
txi_edge <- tximport::tximport(quant_files, type = "salmon",
                               tx2gene = map[, c("transcript_id", "gene_id")],
                               countsFromAbundance = "lengthScaledTPM", dropInfReps = TRUE)
edge_counts <- txi_edge$counts[kept_gene_ids, design$sample, drop = FALSE]
if (anyNA(edge_counts) || any(!is.finite(edge_counts)) || any(edge_counts < 0)) {
  stop("Invalid edgeR counts after tximport.")
}
edge_design <- model.matrix(~ group, data = design)
edge_data <- edgeR::DGEList(counts = edge_counts)
edge_data <- edgeR::calcNormFactors(edge_data, method = "TMM")
edge_data <- edgeR::estimateDisp(edge_data, design = edge_design)
edge_fit <- edgeR::glmQLFit(edge_data, design = edge_design)
edge_test <- edgeR::glmQLFTest(edge_fit, coef = "groupUHR")
edge_table <- edgeR::topTags(edge_test, n = Inf, sort.by = "none")$table
edge_table$gene_id <- rownames(edge_table)
edge_table$gene_name <- gene_names$gene_name[match(edge_table$gene_id, gene_names$gene_id)]
edge_table <- edge_table[, c("gene_id", "gene_name", "logFC", "logCPM", "F", "PValue", "FDR")]
edge_table <- edge_table[order(edge_table$FDR, edge_table$PValue, na.last = TRUE), ]
write.csv(edge_table, file.path(out_dir, "edger.csv"), row.names = FALSE, na = "NA")
edge_significant <- edge_table[!is.na(edge_table$FDR) & edge_table$FDR < 0.05, ]

vsd <- varianceStabilizingTransformation(dds, blind = TRUE)
pca <- plotPCA(vsd, intgroup = "group", returnData = TRUE)
percent_var <- round(100 * attr(pca, "percentVar"), 1)
pdf(file.path(out_dir, "pca.pdf"), width = 7, height = 6)
plot(pca$PC1, pca$PC2, col = ifelse(pca$group == "HBR", "#2563eb", "#dc2626"),
     pch = 19, cex = 1.5, xlab = paste0("PC1 (", percent_var[1], "%)"),
     ylab = paste0("PC2 (", percent_var[2], "%)"), main = "Sample PCA")
text(pca$PC1, pca$PC2, labels = pca$name, pos = 3, cex = 0.8)
legend("topright", legend = c("HBR", "UHR"), col = c("#2563eb", "#dc2626"), pch = 19)
dev.off()
pdf(file.path(out_dir, "ma_plot.pdf"), width = 7, height = 6)
plotMA(res, alpha = 0.05, main = "UHR vs HBR (FDR < 0.05)")
dev.off()
pdf(file.path(out_dir, "volcano_plot.pdf"), width = 7, height = 6)
valid <- !is.na(result_table$pvalue) & !is.na(result_table$log2FoldChange)
plot_data <- result_table[valid, ]
colors <- ifelse(!is.na(plot_data$padj) & plot_data$padj < 0.05, "#dc2626", "#9ca3af")
plot(plot_data$log2FoldChange, -log10(pmax(plot_data$pvalue, .Machine$double.xmin)),
     pch = 16, cex = 0.55, col = colors, xlab = "log2 fold change (UHR / HBR)",
     ylab = "-log10 p-value", main = "Differential expression")
legend("topright", legend = c("FDR < 0.05", "Not significant / not adjusted"),
       col = c("#dc2626", "#9ca3af"), pch = 16, cex = 0.8)
dev.off()

summary_lines <- c(
  "Contrast: UHR vs HBR (positive log2 fold change means higher in UHR)",
  "Gene-level Salmon estimates imported with tximport; DESeq2 Wald test, BH adjustment",
  "Pre-filter: sum of rounded estimated counts across samples >= 10",
  paste("Total quantified genes:", length(keep)),
  paste("Genes passing pre-filter:", sum(keep)),
  paste("Genes with an adjusted p-value:", sum(!is.na(result_table$padj))),
  paste("Significant genes (adjusted p-value < 0.05):", nrow(significant)),
  paste("Higher in UHR:", sum(significant$log2FoldChange > 0)),
  paste("Higher in HBR:", sum(significant$log2FoldChange < 0)),
  "",
  "edgeR: lengthScaledTPM counts, TMM normalization, quasi-likelihood F-test, BH adjustment",
  "Same gene pre-filter as DESeq2",
  paste("Genes tested:", nrow(edge_table)),
  paste("Significant genes (FDR < 0.05):", nrow(edge_significant)),
  paste("Higher in UHR:", sum(edge_significant$logFC > 0)),
  paste("Higher in HBR:", sum(edge_significant$logFC < 0))
)
writeLines(summary_lines, file.path(out_dir, "summary.txt"))
writeLines(capture.output(sessionInfo()), file.path(out_dir, "session_info.txt"))
cat(paste(summary_lines, collapse = "\n"), "\n")