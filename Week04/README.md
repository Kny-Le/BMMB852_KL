# Assignment 3

## Genome used:

https://www.ncbi.nlm.nih.gov/sra/SRX35013314[accn]

This is Helicobacter pylori. This is a pathogenic bacterium that causes stomach ulcers. It is able to survive in the stom$
acidic environment by secreting ammonia to neutralize the area around itself.

PRJNA1515477

SRP728672 

SRR40271341

## Make a Makefile

Open working folder

```bash
touch Makefile
```

### Paste into Makefile

```bash
SRA_ACCESSION := SRR40271341
DATA_DIR := data
SRA_DIR := $(DATA_DIR)/sra
FASTQ_DIR := $(DATA_DIR)/fastq
SRA_FILE := $(SRA_DIR)/$(SRA_ACCESSION)/$(SRA_ACCESSION).sra
READS_STAMP := $(FASTQ_DIR)/.$(SRA_ACCESSION).done

.PHONY: all reads clean

all: reads

reads: $(READS_STAMP)

$(SRA_FILE):
	mkdir -p $(SRA_DIR)
	prefetch --output-directory $(SRA_DIR) $(SRA_ACCESSION)

$(READS_STAMP): $(SRA_FILE)
	mkdir -p $(FASTQ_DIR)
	fasterq-dump --split-files --outdir $(FASTQ_DIR) $(SRA_FILE)
	gzip -f $(FASTQ_DIR)/*.fastq
	touch $@

clean:
	rm -rf $(DATA_DIR)
```

### Run

```bash
make
```

Output (this creates a directory that contains folders called "sra" and "fastq"):

```bash
kenny@MacBook-Pro ~/BMMB852/Week04/data/fastq
$ ls
SRR40271341_1.fastq.gz SRR40271341_2.fastq.gz
(bioinfo) 
```

```bash
kenny@MacBook-Pro ~/BMMB852/Week04/data/sra
$ ls
SRR40271341
(bioinfo) 
```

## Look at the metadata

### run:

```bash
bio search SRR40271341
```

### Output:

```bash
[
    {
        "run_accession": "SRR40271341",
        "sample_accession": "SAMN62584624",
        "sample_alias": "",
        "sample_description": "",
        "first_public": "2026-08-22",
        "country": "",
        "scientific_name": "",
        "fastq_bytes": "94060901;103094388",
        "base_count": "231922200",
        "read_count": "386537",
        "library_name": "KAZ-017",
        "library_strategy": "WGS",
        "library_source": "GENOMIC",
        "library_layout": "PAIRED",
        "instrument_platform": "ILLUMINA",
        "instrument_model": "Illumina MiSeq",
        "study_title": "Whole-genome sequencing of Helicobacter pylori isolates from Kazakhstan",
        "fastq_url": [
            "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR402/041/SRR40271341/SRR40271341_1.fastq.gz",
            "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR402/041/SRR40271341/SRR40271341_2.fastq.gz"
        ],
        "info": "94 MB, 103 MB files; 0.4 million reads; 231.9 million sequenced bases"
    }
]
```

### Quality Control

run in directory with your fastq file

```bash
cd data
fastq-dump -X 1000 -F --outdir fastq --split-files SRR40271341
seqkit stats fastq/SRR40271341*.fastq
fastqc fastq/SRR40271341*.fastq
```

Output:

```bash
null
null
Started analysis of SRR40271341_1.fastq
Approx 100% complete for SRR40271341_1.fastq
Analysis complete for SRR40271341_1.fastq
Started analysis of SRR40271341_2.fastq
Approx 100% complete for SRR40271341_2.fastq
Analysis complete for SRR40271341_2.fastq
```

Open Quality Check
```bash
open fastq/SRR40271341_1_fastqc.html
```

#### Output:

![alt text](<screenshots/Screenshot 2026-09-16 at 6.43.00 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-16 at 6.45.51 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-16 at 6.46.37 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-16 at 6.47.20 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-16 at 6.48.44 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-16 at 6.49.15 PM.png>)

### Using fastp

#### Make new qc files and trim

Update Makefile:

```bash
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
```

Run in directory with Makefile:

```bash
make qc
```

Output:

```bash
kenny@MacBook-Pro ~/BMMB852/Week04/data/qc
$ ls
SRR40271341.html               SRR40271341_1.trimmed.fastq.gz
SRR40271341.json               SRR40271341_2.trimmed.fastq.gz
(bioinfo) 
```

#### Open Quality Check Report

Open Report:

```bash
open data/qc/SRR40271341.html
```

Images:

![alt text](<screenshots/Screenshot 2026-09-17 at 2.22.19 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-17 at 2.23.13 PM.png>)

<img width="1287" height="648" alt="Screenshot 2026-09-17 at 2 23 45 PM" src="https://github.com/user-attachments/assets/80d0c35e-e319-4196-8d5e-fc920efddc3a" />

![alt text](<screenshots/Screenshot 2026-09-17 at 2.24.32 PM.png>)

Alternatively you can run FastQC on the downloaded reads

```bash
fastqc data/fastq/SRR40271341_*.fastq.gz
open data/fastq/SRR40271341_1_fastqc.html
```

Images:

![alt text](<screenshots/Screenshot 2026-09-17 at 2.25.16 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-17 at 2.26.10 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-17 at 2.27.04 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-17 at 2.27.47 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-17 at 2.28.26 PM.png>)

![alt text](<screenshots/Screenshot 2026-09-17 at 2.29.21 PM.png>)

### Questions

#### How "popular" is this genome? How many datasets are available?

This H. Pylori genome contains 86 publicly available whole-genome sequencing datasets, representing different clinical H. Pylori isolates from Kazakhstan. The assession I selected, SSR40271341, is one of the 86 datasets and represents KAZ-017. This project has a relatively large collection of datasets.

#### What is the breakdown by sequencing strategy and platform (or some other attribute)?

The sequencing strategy used is whole-genome sequencing (WGS) generated on Illumina MiSeq, using paired-end sequencing. This project contains approximately 25 GB of sequencing data.

#### What do you find interesting or surprising?

Personally, what I found interesting what how perfect the sequence was before using fastp as it there are very minimal differences before and after using the tool.
