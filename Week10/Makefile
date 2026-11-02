# ChIP-seq pipeline driven by the sample groups in design.csv.
# The design contains one background group and multiple IP conditions.
# All runs are single-end Illumina reads.
#
#   make background            fastq -> bam for the background samples
#   make peaks                 call peaks for CONDITION vs the background
#   make peaks CONDITION=<group>
#   make all                   peaks for every non-background group

.ONESHELL:
.SHELLFLAGS := -eu -c

# Required tools must be available on PATH.

# ---- Configuration -------------------------------------------------------

DESIGN ?= design.csv

# Dataset configuration. Edit these values for a different experiment.
BACKGROUND_GROUP ?= input
CONDITION        ?= $(firstword $(CONDITIONS))

# Run accessions per group, parsed from the design file (columns: sample,name,group).
SAMPLES    := $(shell tail -n +2 $(DESIGN) | cut -d, -f1)
BG_SAMPLES := $(shell tail -n +2 $(DESIGN) | awk -F, '$$3=="$(BACKGROUND_GROUP)" {print $$1}')
CONDITIONS := $(shell tail -n +2 $(DESIGN) | cut -d, -f3 | sort -u | grep -vx '$(BACKGROUND_GROUP)')
IP_SAMPLES := $(shell tail -n +2 $(DESIGN) | awk -F, '$$3=="$(CONDITION)" {print $$1}')

# Reference and MACS settings for this dataset; override on the make command line if needed.
REF_ACC ?= CP001173.1
REF_DIR ?= ref
REF     := $(REF_DIR)/$(if $(strip $(REF_ACC)),$(REF_ACC),REFERENCE).fa

# Effective genome size and extension size used by MACS.
GSIZE ?= 1.65e6
EXTSIZE ?= 147

FASTQ_DIR ?= fastq
BAM_DIR   ?= bam
PEAK_DIR  ?= peaks

THREADS ?= 4
JOBS    ?=

.SECONDARY:

.PHONY: all batch fastq ref align background peaks install-tools clean list

# Install optional analysis tools into the currently activated environment.
install-tools:
	@test -n "$$CONDA_PREFIX" || { echo "Activate the target environment before installing tools"; exit 1; }
	micromamba install -p "$$CONDA_PREFIX" -c bioconda macs3 bedtools

# Call peaks for every condition in the design file.
all:
	for c in $(CONDITIONS); do $(MAKE) peaks CONDITION=$$c; done

# Run everything with $(JOBS) samples in parallel.
batch:
	@test -n "$(JOBS)" || { echo "Set JOBS to the number of parallel make jobs"; exit 1; }
	@echo "Running $(words $(SAMPLES)) samples from $(DESIGN) with $(JOBS) parallel jobs"
	$(MAKE) -j$(JOBS) all

# ---- Reference genome ----------------------------------------------------
ref: $(REF)

$(REF):
	@test -n "$(REF_ACC)" || { echo "Set REF_ACC, e.g. make ref REF_ACC=<accession>"; exit 1; }
	mkdir -p $(REF_DIR)
	efetch -db nuccore -id $(REF_ACC) -format fasta > $(REF)
	bwa index $(REF)
	samtools faidx $(REF)

# ---- Download FASTQ (single-end) -----------------------------------------
fastq: $(addprefix $(FASTQ_DIR)/,$(addsuffix .fastq.gz,$(SAMPLES)))

$(FASTQ_DIR)/%.fastq.gz:
	@test -n "$(THREADS)" || { echo "Set THREADS for fasterq-dump"; exit 1; }
	mkdir -p $(FASTQ_DIR)
	fasterq-dump --threads $(THREADS) -O $(FASTQ_DIR) $*
	gzip -f $(FASTQ_DIR)/$*.fastq

# ---- Alignment -----------------------------------------------------------
align: $(addprefix $(BAM_DIR)/,$(addsuffix .bam.bai,$(SAMPLES)))

$(BAM_DIR)/%.bam: $(REF) $(FASTQ_DIR)/%.fastq.gz
	@test -n "$(THREADS)" || { echo "Set THREADS for BWA and samtools"; exit 1; }
	mkdir -p $(BAM_DIR)
	bwa mem -t $(THREADS) $(REF) $(FASTQ_DIR)/$*.fastq.gz \
	| samtools view -b -F 4 - \
	| samtools sort -@ $(THREADS) -o $(BAM_DIR)/$*.bam -

$(BAM_DIR)/%.bam.bai: $(BAM_DIR)/%.bam
	samtools index $<

# ---- Background workflow: download, align, and index control samples ------
background: $(addprefix $(BAM_DIR)/,$(addsuffix .bam.bai,$(BG_SAMPLES)))
	@echo "Background samples ready: $(BG_SAMPLES)"

# ---- Peak calling: CONDITION replicates vs pooled background -------------
PEAKS := $(PEAK_DIR)/$(CONDITION)_peaks.narrowPeak

peaks: $(PEAKS)

$(PEAKS): $(addprefix $(BAM_DIR)/,$(addsuffix .bam.bai,$(IP_SAMPLES) $(BG_SAMPLES)))
	@test -n "$(BACKGROUND_GROUP)" || { echo "Set BACKGROUND_GROUP to the control group in $(DESIGN)"; exit 1; }
	@test -n "$(BG_SAMPLES)" || { echo "No samples in background group $(BACKGROUND_GROUP)"; exit 1; }
	@test -n "$(IP_SAMPLES)" || { echo "No samples in group $(CONDITION)"; exit 1; }
	@test -n "$(GSIZE)" || { echo "Set GSIZE to the effective genome size for MACS3"; exit 1; }
	@test -n "$(EXTSIZE)" || { echo "Set EXTSIZE for MACS3"; exit 1; }
	mkdir -p $(PEAK_DIR)
	macs3 callpeak -f BAM -g $(GSIZE) --nomodel --extsize $(EXTSIZE) -n $(CONDITION) --outdir $(PEAK_DIR) \
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
