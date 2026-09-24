SAMPLE_NAME := KAZ-017
ORGANISM := HPylori
GENOME_ACCESSION := SAMN62584624
PROJECT_ACCESSION := PRJNA1515477
RUN_ACCESSION := SRR40271341
ASSEMBLY := GCF_902846105.1

REFERENCE := fasta/HPylori_NZ_CADHBV000000000.1.fna
READ1 := fastq/$(RUN_ACCESSION)_1.fastq
READ2 := fastq/$(RUN_ACCESSION)_2.fastq
REFERENCE_ARCHIVE := fasta/$(ASSEMBLY).zip
READ1_GZ := $(READ1).gz
READ2_GZ := $(READ2).gz
DATASETS_URL := https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$(ASSEMBLY)/download?include_annotation_type=GENOME_FASTA
READ1_URL := https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR402/041/$(RUN_ACCESSION)/$(RUN_ACCESSION)_1.fastq.gz
READ2_URL := https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR402/041/$(RUN_ACCESSION)/$(RUN_ACCESSION)_2.fastq.gz
BAM_DIR := bam
BAM := $(BAM_DIR)/$(ORGANISM).$(SAMPLE_NAME).sorted.bam
BAM_INDEX := $(BAM).bai
FLAGSTAT := $(BAM_DIR)/$(ORGANISM).$(SAMPLE_NAME).flagstat.txt

.PHONY: all download align flagstat clean

all: flagstat

download: $(REFERENCE) $(READ1) $(READ2)

align: $(BAM_INDEX)

flagstat: $(FLAGSTAT)

$(FLAGSTAT): $(BAM_INDEX)
	samtools flagstat $(BAM) > $@

$(REFERENCE_ARCHIVE):
	mkdir -p $(@D)
	curl --fail --location --silent --show-error --output $@ '$(DATASETS_URL)'

$(REFERENCE): $(REFERENCE_ARCHIVE)
	mkdir -p $(@D)
	unzip -p $< 'ncbi_dataset/data/$(ASSEMBLY)/*.fna' > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

$(READ1_GZ):
	mkdir -p $(@D)
	curl --fail --location --silent --show-error --output $@ '$(READ1_URL)'

$(READ2_GZ):
	mkdir -p $(@D)
	curl --fail --location --silent --show-error --output $@ '$(READ2_URL)'

$(READ1): $(READ1_GZ)
	gzip --decompress --stdout $< > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

$(READ2): $(READ2_GZ)
	gzip --decompress --stdout $< > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

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
		$(FLAGSTAT) $(READ1) $(READ2) $(READ1_GZ) $(READ2_GZ) \
		$(REFERENCE).amb $(REFERENCE).ann $(REFERENCE).bwt \
		$(REFERENCE).pac $(REFERENCE).sa $(REFERENCE).fai \
		$(REFERENCE_ARCHIVE) $(REFERENCE)
