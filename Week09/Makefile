# Variant calling pipeline for 8 samples from BioProject PRJNA1538546.
#
# NOTE: These samples are 16S amplicon (metagenomic) data, not WGS.
# Aligning them against a single reference (H. pylori 26695) will only
# capture the small fraction of reads originating from that genome.
# Treat the resulting VCF as exploratory.
# For repeatable runs, use the checked-in design.csv. The `design` target
# refreshes it from live NCBI metadata and may change the sample list.

# ---- Configuration -------------------------------------------------------

# BioProject accession and design file.
BPRP    := PRJNA1538546
DESIGN  := design.csv

# Sample (run) accessions parsed from the design file (skip header).
SAMPLES := $(shell tail -n +2 $(DESIGN) | cut -d, -f1)

# Reference genome: Helicobacter pylori 26695.
REF_ACC := NC_000915.1
REF     := $(REF_ACC).fa

# Final merged VCF.
MERGED  := merged.vcf.gz

# Per-sample VCF targets.
VCFS := $(addsuffix .vcf.gz,$(SAMPLES))

# Keep intermediate files (BAMs) instead of auto-deleting them.
.SECONDARY:

# Threads for bwa/samtools.
THREADS := 4

# Number of samples processed in parallel by the batch target.
# Override on the command line: make batch JOBS=8
JOBS ?= 4

.PHONY: all batch design fastq ref align call merge clean list

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
	bio search $(BPRP) | grep -E '"run_accession"|"library_name"' \
	| paste - - | sed 's/[",]//g; s/run_accession: //; s/library_name: //' \
	| awk 'NR<=8 { split($$2, a, "-"); g = substr(a[1], 1, 1); \
	  print $$1 "," $$2 "," (g=="N" ? "N" : a[1]) }' \
	| (echo "sample,name,group"; cat) > $(DESIGN)
	@echo "Wrote $(DESIGN):"; cat $(DESIGN)

# ---- Reference genome ----------------------------------------------------
ref: $(REF)

$(REF):
	efetch -db nuccore -id $(REF_ACC) -format fasta > $(REF)
	bwa index $(REF)
	samtools faidx $(REF)

# ---- Download FASTQ via SRA toolkit --------------------------------------
# ENA does not mirror this project yet (submitted 2026-10-07), so pull
# directly from NCBI with fasterq-dump. These runs are pre-merged 16S
# amplicon reads (~425 bp), so each run yields ONE FASTQ, not _1/_2 pairs.
fastq: $(addsuffix .fastq.gz,$(SAMPLES))

%.fastq.gz:
	fasterq-dump --threads $(THREADS) -O . $*
	gzip -f $*.fastq

# ---- Alignment -----------------------------------------------------------
align: $(addsuffix .bam.bai,$(SAMPLES))

%.bam: $(REF) %.fastq.gz
	bwa mem -t $(THREADS) $(REF) $*.fastq.gz \
	| samtools sort -@ $(THREADS) -o $*.bam -

%.bam.bai: %.bam
	samtools index $<

# ---- Variant calling (per sample) ----------------------------------------
call: $(VCFS)

%.vcf.gz: %.bam $(REF)
	bcftools mpileup -O u -f $(REF) $*.bam \
	| bcftools call -mv -O z -o $*.vcf.gz -
	bcftools index $*.vcf.gz

# ---- Merge all samples into one VCF --------------------------------------
merge: $(MERGED)

$(MERGED): $(VCFS)
	bcftools merge -O z -o $(MERGED) $(VCFS)
	bcftools index $(MERGED)
	@echo "Merged VCF: $(MERGED)"
	bcftools stats $(MERGED) | head -30

# ---- Housekeeping --------------------------------------------------------
clean:
	rm -f $(addsuffix .fastq.gz,$(SAMPLES)) \
	  $(addsuffix .bam,$(SAMPLES)) $(addsuffix .bam.bai,$(SAMPLES)) \
	  $(VCFS) $(addsuffix .vcf.gz.csi,$(SAMPLES)) \
	  $(REF) $(REF).amb $(REF).ann $(REF).bwt $(REF).fai $(REF).pac $(REF).sa \
	  $(MERGED) $(MERGED).csi

# Print sample list (debug).
list:
	@echo "Samples: $(SAMPLES)"
