# Variant calling pipeline for 8 samples from BioProject PRJNA1538546.
#
# NOTE: These samples are 16S amplicon (metagenomic) data, not WGS.
# Aligning them against a single reference (H. pylori 26695) will only
# capture the small fraction of reads originating from that genome.
# Treat the resulting VCF as exploratory.

SHELL := /bin/zsh
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

# Tools from the bioinfo micromamba environment (absolute paths are robust
# against PATH clobbering in .ONESHELL recipes).
ENV         := $(HOME)/micromamba/envs/bioinfo/bin
BIO         := $(ENV)/bio
EFETCH      := $(ENV)/efetch
BWA         := $(ENV)/bwa
SAMTOOLS    := $(ENV)/samtools
BCFTOOLS    := $(ENV)/bcftools
FASTERQDUMP := $(ENV)/fasterq-dump

# ---- Configuration -------------------------------------------------------

# BioProject accession and design file.
BPRP    := PRJNA1538546
DESIGN  := design.csv

# Sample (run) accessions parsed from the design file (skip header).
SAMPLES := $(shell tail -n +2 $(DESIGN) | cut -d, -f1)

# Reference genome: Helicobacter pylori 26695.
REF_ACC := NC_000915.1
REF     := ref/$(REF_ACC).fa

# Directories.
FASTQ_DIR := fastq
BAM_DIR   := bam
VCF_DIR   := vcf

# Final merged VCF.
MERGED  := results/merged.vcf.gz

# Per-sample VCF targets.
VCFS := $(addprefix $(VCF_DIR)/,$(addsuffix .vcf.gz,$(SAMPLES)))

# Keep intermediate files (BAMs) instead of auto-deleting them.
.SECONDARY:

# Threads for bwa/samtools.
THREADS := 4

# Number of samples processed in parallel by the batch target.
# Override on the command line: make batch JOBS=8
JOBS ?= 4

.PHONY: all batch design fastq ref align call merge clean

all: merge

# ---- Batch mode ------------------------------------------------------------
# Reads the sample list from $(DESIGN) and runs the full workflow with
# $(JOBS) samples processed concurrently. Equivalent to: make -j$(JOBS) all
batch:
	@echo "Running $(words $(SAMPLES)) samples from $(DESIGN) with $(JOBS) parallel jobs"
	$(MAKE) -j$(JOBS) all

# ---- Design file ---------------------------------------------------------
# Regenerate the design file from the BioProject metadata (first 8 runs).
design:
	$(BIO) search $(BPRP) | grep -E '"run_accession"|"library_name"' \
	| paste - - | sed 's/[",]//g; s/run_accession: //; s/library_name: //' \
	| awk 'NR<=8 { split($$2, a, "-"); g = substr(a[1], 1, 1); \
	  print $$1 "," $$2 "," (g=="N" ? "N" : a[1]) }' \
	| (echo "sample,name,group"; cat) > $(DESIGN)
	@echo "Wrote $(DESIGN):"; cat $(DESIGN)

# ---- Reference genome ----------------------------------------------------
ref: $(REF)

$(REF):
	mkdir -p ref
	$(EFETCH) -db nuccore -id $(REF_ACC) -format fasta > $(REF)
	$(BWA) index $(REF)
	$(SAMTOOLS) faidx $(REF)

# ---- Download FASTQ via SRA toolkit --------------------------------------
# ENA does not mirror this project yet (submitted 2026-10-07), so pull
# directly from NCBI with fasterq-dump. These runs are pre-merged 16S
# amplicon reads (~425 bp), so each run yields ONE FASTQ, not _1/_2 pairs.
fastq: $(addprefix $(FASTQ_DIR)/,$(addsuffix .fastq.gz,$(SAMPLES)))

$(FASTQ_DIR)/%.fastq.gz:
	mkdir -p $(FASTQ_DIR)
	$(FASTERQDUMP) --threads $(THREADS) -O $(FASTQ_DIR) $*
	gzip -f $(FASTQ_DIR)/$*.fastq

# ---- Alignment -----------------------------------------------------------
align: $(addprefix $(BAM_DIR)/,$(addsuffix .bam.bai,$(SAMPLES)))

$(BAM_DIR)/%.bam: $(REF) $(FASTQ_DIR)/%.fastq.gz
	mkdir -p $(BAM_DIR)
	$(BWA) mem -t $(THREADS) $(REF) $(FASTQ_DIR)/$*.fastq.gz \
	| $(SAMTOOLS) sort -@ $(THREADS) -o $(BAM_DIR)/$*.bam -

$(BAM_DIR)/%.bam.bai: $(BAM_DIR)/%.bam
	$(SAMTOOLS) index $<

# ---- Variant calling (per sample) ----------------------------------------
call: $(VCFS)

$(VCF_DIR)/%.vcf.gz: $(BAM_DIR)/%.bam $(REF)
	mkdir -p $(VCF_DIR)
	$(BCFTOOLS) mpileup -O u -f $(REF) $(BAM_DIR)/$*.bam \
	| $(BCFTOOLS) call -mv -O z -o $(VCF_DIR)/$*.vcf.gz -
	$(BCFTOOLS) index $(VCF_DIR)/$*.vcf.gz

# ---- Merge all samples into one VCF --------------------------------------
merge: $(MERGED)

$(MERGED): $(VCFS)
	mkdir -p results
	$(BCFTOOLS) merge -O z -o $(MERGED) $(VCFS)
	$(BCFTOOLS) index $(MERGED)
	@echo "Merged VCF: $(MERGED)"
	$(BCFTOOLS) stats $(MERGED) | head -30

# ---- Housekeeping --------------------------------------------------------
clean:
	rm -rf $(FASTQ_DIR) $(BAM_DIR) $(VCF_DIR) results

# Print sample list (debug).
list:
	@echo "Samples: $(SAMPLES)"
