SRA_ACCESSION := SRR40271341
DATA_DIR := data
SRA_DIR := $(DATA_DIR)/sra
FASTQ_DIR := $(DATA_DIR)/fastq
QC_DIR := $(DATA_DIR)/qc
SRA_FILE := $(SRA_DIR)/$(SRA_ACCESSION)/$(SRA_ACCESSION).sra
READS_STAMP := $(FASTQ_DIR)/.$(SRA_ACCESSION).done
QC_STAMP := $(QC_DIR)/.$(SRA_ACCESSION).done

.PHONY: all reads qc clean

all: reads qc

reads: $(READS_STAMP)

qc: $(QC_STAMP)

$(SRA_FILE):
	mkdir -p $(SRA_DIR)
	prefetch --output-directory $(SRA_DIR) $(SRA_ACCESSION)

$(READS_STAMP): $(SRA_FILE)
	mkdir -p $(FASTQ_DIR)
	fasterq-dump --split-files --outdir $(FASTQ_DIR) $(SRA_FILE)
	gzip -f $(FASTQ_DIR)/*.fastq
	touch $@

$(QC_STAMP): $(READS_STAMP)
	mkdir -p $(QC_DIR)
	fastp \
		-i $(FASTQ_DIR)/$(SRA_ACCESSION)_1.fastq.gz \
		-I $(FASTQ_DIR)/$(SRA_ACCESSION)_2.fastq.gz \
		-o $(QC_DIR)/$(SRA_ACCESSION)_1.trimmed.fastq.gz \
		-O $(QC_DIR)/$(SRA_ACCESSION)_2.trimmed.fastq.gz \
		-h $(QC_DIR)/$(SRA_ACCESSION).html \
		-j $(QC_DIR)/$(SRA_ACCESSION).json
	touch $@

clean:
	rm -rf $(DATA_DIR)
