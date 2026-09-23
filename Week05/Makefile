SAMPLE_NAME := KAZ-017
ORGANISM := HPylori
GENOME_ACCESSION := SAMN62584624
PROJECT_ACCESSION := PRJNA1515477
RUN_ACCESSION := SRR40271341

REFERENCE := fasta/HPylori_NZ_CADHBV000000000.1.fna
READ1 := fastq/$(RUN_ACCESSION)_1.fastq
READ2 := fastq/$(RUN_ACCESSION)_2.fastq
BAM_DIR := bam
BAM := $(BAM_DIR)/$(ORGANISM).$(SAMPLE_NAME).sorted.bam
BAM_INDEX := $(BAM).bai
FLAGSTAT := $(BAM_DIR)/$(ORGANISM).$(SAMPLE_NAME).flagstat.txt

.PHONY: all align flagstat clean

all: flagstat

align: $(BAM_INDEX)

flagstat: $(FLAGSTAT)

$(FLAGSTAT): $(BAM_INDEX)
	samtools flagstat $(BAM) > $@

$(BAM_INDEX): $(BAM)
	samtools index $(BAM)

$(BAM): $(REFERENCE).bwt $(REFERENCE).fai $(READ1) $(READ2)
	mkdir -p $(BAM_DIR)
	bwa mem -R '@RG\tID:$(RUN_ACCESSION)\tSM:$(SAMPLE_NAME)\tLB:$(PROJECT_ACCESSION)\tPU:$(GENOME_ACCESSION)' \
		$(REFERENCE) $(READ1) $(READ2) \
		| samtools sort -o $@ -

$(REFERENCE).bwt: $(REFERENCE)
	bwa index $(REFERENCE)

$(REFERENCE).fai: $(REFERENCE)
	samtools faidx $(REFERENCE)

clean:
	rm -f $(BAM) $(BAM_INDEX) \
		$(REFERENCE).amb $(REFERENCE).ann $(REFERENCE).bwt \
		$(REFERENCE).pac $(REFERENCE).sa $(REFERENCE).fai
