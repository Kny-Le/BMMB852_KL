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
REF     := ref/$(if $(strip $(REF_ACC)),$(REF_ACC),REFERENCE).fa

# Effective genome size and extension size used by MACS.
GSIZE ?= 1.65e6
EXTSIZE ?= 147

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
	mkdir -p ref
	efetch -db nuccore -id $(REF_ACC) -format fasta > $(REF)
	bwa index $(REF)
	samtools faidx $(REF)

# ---- Download FASTQ (single-end) -----------------------------------------
fastq: $(addprefix fastq/,$(addsuffix .fastq.gz,$(SAMPLES)))

fastq/%.fastq.gz:
	@test -n "$(THREADS)" || { echo "Set THREADS for fasterq-dump"; exit 1; }
	mkdir -p fastq
	fasterq-dump --threads $(THREADS) -O fastq $*
	gzip -f fastq/$*.fastq

# ---- Alignment -----------------------------------------------------------
align: $(addprefix bam/,$(addsuffix .bam.bai,$(SAMPLES)))

bam/%.bam: $(REF) fastq/%.fastq.gz
	@test -n "$(THREADS)" || { echo "Set THREADS for BWA and samtools"; exit 1; }
	mkdir -p bam
	bwa mem -t $(THREADS) $(REF) fastq/$*.fastq.gz \
	| samtools view -b -F 4 - \
	| samtools sort -@ $(THREADS) -o bam/$*.bam -

bam/%.bam.bai: bam/%.bam
	samtools index $<

# ---- Background workflow: download, align, and index control samples ------
background: $(addprefix bam/,$(addsuffix .bam.bai,$(BG_SAMPLES)))
	@echo "Background samples ready: $(BG_SAMPLES)"

# ---- Peak calling: CONDITION replicates vs pooled background -------------
PEAKS := peaks/$(CONDITION)_peaks.narrowPeak

peaks: $(PEAKS)

$(PEAKS): $(addprefix bam/,$(addsuffix .bam.bai,$(IP_SAMPLES) $(BG_SAMPLES)))
	@test -n "$(BACKGROUND_GROUP)" || { echo "Set BACKGROUND_GROUP to the control group in $(DESIGN)"; exit 1; }
	@test -n "$(BG_SAMPLES)" || { echo "No samples in background group $(BACKGROUND_GROUP)"; exit 1; }
	@test -n "$(IP_SAMPLES)" || { echo "No samples in group $(CONDITION)"; exit 1; }
	@test -n "$(GSIZE)" || { echo "Set GSIZE to the effective genome size for MACS3"; exit 1; }
	@test -n "$(EXTSIZE)" || { echo "Set EXTSIZE for MACS3"; exit 1; }
	mkdir -p peaks
	macs3 callpeak -f BAM -g $(GSIZE) --nomodel --extsize $(EXTSIZE) -n $(CONDITION) --outdir peaks \
	  -t $(addprefix bam/,$(addsuffix .bam,$(IP_SAMPLES))) \
	  -c $(addprefix bam/,$(addsuffix .bam,$(BG_SAMPLES)))
	@echo "Peaks: $(PEAKS) ($$(wc -l < $(PEAKS)) peaks)"

# ---- Housekeeping --------------------------------------------------------
clean:
	rm -rf fastq bam peaks

list:
	@echo "Samples: $(SAMPLES)"
	@echo "Background: $(BG_SAMPLES)"
	@echo "Conditions: $(CONDITIONS)"
	@echo "$(CONDITION): $(IP_SAMPLES)"
