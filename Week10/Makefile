# ChIP-seq pipeline for H. pylori G27 HP1043 (BioProjects PRJNA327549, PRJNA421261, PRJNA313048).
# Groups in design.csv: "input" (background) plus 4 IP conditions, 2 replicates each.
# All runs are single-end Illumina reads.
#
#   make background            fastq -> bam for the background samples
#   make peaks                 call peaks for CONDITION vs the background
#   make peaks CONDITION=HP1043
#   make all                   peaks for every non-background group

SHELL := /bin/zsh
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

# Tools from the bioinfo micromamba environment.
# macs3 must be installed there: micromamba install -n bioinfo -c bioconda macs3
ENV         := $(HOME)/micromamba/envs/bioinfo/bin
EFETCH      := $(ENV)/efetch
BWA         := $(ENV)/bwa
SAMTOOLS    := $(ENV)/samtools
FASTERQDUMP := $(ENV)/fasterq-dump
MACS3       := $(ENV)/macs3

# ---- Configuration -------------------------------------------------------

BPRP   := PRJNA327549 PRJNA421261 PRJNA313048
DESIGN := design.csv

# Group name of the background (input) samples and the condition to analyze.
BACKGROUND_GROUP := input
CONDITION        ?= HP1043

# Run accessions per group, parsed from the design file (columns: sample,name,group).
SAMPLES    := $(shell tail -n +2 $(DESIGN) | cut -d, -f1)
BG_SAMPLES := $(shell tail -n +2 $(DESIGN) | awk -F, '$$3=="$(BACKGROUND_GROUP)" {print $$1}')
CONDITIONS := $(shell tail -n +2 $(DESIGN) | cut -d, -f3 | sort -u | grep -vx '$(BACKGROUND_GROUP)')
IP_SAMPLES := $(shell tail -n +2 $(DESIGN) | awk -F, '$$3=="$(CONDITION)" {print $$1}')

# Reference genome: Helicobacter pylori G27.
REF_ACC := CP001173.1
REF     := ref/$(REF_ACC).fa

# Approximate genome size for MACS (~1.65 Mb).
GSIZE := 1.65e6

FASTQ_DIR := fastq
BAM_DIR   := bam
PEAK_DIR  := peaks

THREADS := 4
JOBS    ?= 4

.SECONDARY:

.PHONY: all batch fastq ref align background peaks clean list

# Call peaks for every condition in the design file.
all:
	for c in $(CONDITIONS); do $(MAKE) peaks CONDITION=$$c; done

# Run everything with $(JOBS) samples in parallel.
batch:
	@echo "Running $(words $(SAMPLES)) samples from $(DESIGN) with $(JOBS) parallel jobs"
	$(MAKE) -j$(JOBS) all

# ---- Reference genome ----------------------------------------------------
ref: $(REF)

$(REF):
	mkdir -p ref
	$(EFETCH) -db nuccore -id $(REF_ACC) -format fasta > $(REF)
	$(BWA) index $(REF)
	$(SAMTOOLS) faidx $(REF)

# ---- Download FASTQ (single-end) -----------------------------------------
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
	| $(SAMTOOLS) view -b -F 4 - \
	| $(SAMTOOLS) sort -@ $(THREADS) -o $(BAM_DIR)/$*.bam -

$(BAM_DIR)/%.bam.bai: $(BAM_DIR)/%.bam
	$(SAMTOOLS) index $<

# ---- Background workflow: download, align, index the input samples --------
background: $(addprefix $(BAM_DIR)/,$(addsuffix .bam.bai,$(BG_SAMPLES)))
	@echo "Background samples ready: $(BG_SAMPLES)"

# ---- Peak calling: CONDITION replicates vs pooled background -------------
PEAKS := $(PEAK_DIR)/$(CONDITION)_peaks.narrowPeak

peaks: $(PEAKS)

$(PEAKS): $(addprefix $(BAM_DIR)/,$(addsuffix .bam.bai,$(IP_SAMPLES) $(BG_SAMPLES)))
	@test -n "$(IP_SAMPLES)" || { echo "No samples in group $(CONDITION)"; exit 1; }
	mkdir -p $(PEAK_DIR)
	$(MACS3) callpeak -f BAM -g $(GSIZE) --nomodel --extsize 147 -n $(CONDITION) --outdir $(PEAK_DIR) \
	  -t $(addprefix $(BAM_DIR)/,$(addsuffix .bam,$(IP_SAMPLES))) \
	  -c $(addprefix $(BAM_DIR)/,$(addsuffix .bam,$(BG_SAMPLES)))
	@echo "Peaks: $(PEAKS) ($$(wc -l < $(PEAKS)) peaks)"

# ---- Housekeeping --------------------------------------------------------
clean:
	rm -rf $(FASTQ_DIR) $(BAM_DIR) $(PEAK_DIR)

list:
	@echo "Samples: $(SAMPLES)"
	@echo "Background: $(BG_SAMPLES)"
	@echo "Conditions: $(CONDITIONS)"
	@echo "$(CONDITION): $(IP_SAMPLES)"
