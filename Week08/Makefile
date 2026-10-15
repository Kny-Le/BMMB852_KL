ORGANISM := HPylori
PROJECT_ACCESSION := PRJNA1538546
ASSEMBLY := GCF_902846105.1
THREADS ?= 4

SAMPLES := HPylori1 HPylori2 HPylori3
RUN_HPylori1 := SRR41018109
RUN_HPylori2 := SRR41018110
RUN_HPylori3 := SRR41018111

FASTA_DIR := fasta
FASTQ_DIR := fastq
BAM_DIR := bam
VCF_DIR := vcf
GFF_DIR := gff
REFERENCE := $(FASTA_DIR)/$(ORGANISM)_$(ASSEMBLY).fna
REFERENCE_ARCHIVE := $(FASTA_DIR)/$(ASSEMBLY).zip
ANNOTATION_ARCHIVE := $(GFF_DIR)/$(ASSEMBLY)_annotation.zip
REFERENCE_GFF := $(GFF_DIR)/$(ASSEMBLY).gff
DATASETS_URL := https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$(ASSEMBLY)/download?include_annotation_type=GENOME_FASTA
ANNOTATION_URL := https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$(ASSEMBLY)/download?include_annotation_type=GENOME_GFF

FASTQ_OUTPUTS := $(foreach sample,$(SAMPLES),$(FASTQ_DIR)/$(sample).fastq $(FASTQ_DIR)/$(sample)_1.fastq $(FASTQ_DIR)/$(sample)_2.fastq)
RAW_FASTQS := $(foreach sample,$(SAMPLES),$(FASTQ_DIR)/$(RUN_$(sample)).fastq $(FASTQ_DIR)/$(RUN_$(sample))_1.fastq $(FASTQ_DIR)/$(RUN_$(sample))_2.fastq)
BAMS := $(addprefix $(BAM_DIR)/,$(addsuffix .sorted.bam,$(SAMPLES)))
VCFS := $(addprefix $(VCF_DIR)/,$(addsuffix .vcf.gz,$(SAMPLES)))
FLAGSTATS := $(addprefix $(BAM_DIR)/,$(addsuffix .flagstat.txt,$(SAMPLES)))
MERGED_VCF := $(VCF_DIR)/$(ORGANISM).merged.vcf.gz
SAMPLE_GFFS := $(addprefix $(GFF_DIR)/,$(addsuffix .gff,$(SAMPLES)))

.PHONY: all download align flagstat variants merge gff clean $(SAMPLES)
.SECONDARY: $(BAMS)

all: flagstat merge gff

download: $(REFERENCE) $(foreach sample,$(SAMPLES),$(FASTQ_DIR)/$(sample).downloaded)

align: $(addsuffix .bai,$(BAMS))

flagstat: $(FLAGSTATS)

variants: $(VCFS)

merge: $(MERGED_VCF)

gff: $(SAMPLE_GFFS)

# Build one sample's FASTQ, BAM, and VCF outputs by its sample label.
$(SAMPLES): %: $(VCF_DIR)/%.vcf.gz $(GFF_DIR)/%.gff

$(REFERENCE_ARCHIVE):
	mkdir -p $(@D)
	curl --fail --location --silent --show-error --output $@ '$(DATASETS_URL)'

$(REFERENCE): $(REFERENCE_ARCHIVE)
	mkdir -p $(@D)
	unzip -p $< 'ncbi_dataset/data/$(ASSEMBLY)/*.fna' > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

$(ANNOTATION_ARCHIVE):
	mkdir -p $(@D)
	curl --fail --location --silent --show-error --output $@ '$(ANNOTATION_URL)'

$(REFERENCE_GFF): $(ANNOTATION_ARCHIVE)
	mkdir -p $(@D)
	unzip -p $< 'ncbi_dataset/data/$(ASSEMBLY)/genomic.gff' > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

$(GFF_DIR)/%.gff: $(REFERENCE_GFF)
	mkdir -p $(@D)
	cp $< $@

$(REFERENCE).bwt: $(REFERENCE)
	bwa index $(REFERENCE)

$(REFERENCE).fai: $(REFERENCE)
	samtools faidx $(REFERENCE)

define SAMPLE_FASTQ_RULE
$(FASTQ_DIR)/$(1).downloaded:
	mkdir -p $(FASTQ_DIR)
	@if ! test -s $(FASTQ_DIR)/$$(RUN_$(1)).fastq && \
	    ! test -s $(FASTQ_DIR)/$$(RUN_$(1))_1.fastq && \
	    ! test -s $(FASTQ_DIR)/$$(RUN_$(1))_2.fastq; then \
		fasterq-dump --split-files --threads $(THREADS) --outdir $(FASTQ_DIR) $$(RUN_$(1)); \
	fi
	@if test -s $(FASTQ_DIR)/$$(RUN_$(1))_1.fastq && test -s $(FASTQ_DIR)/$$(RUN_$(1))_2.fastq; then \
		mv $(FASTQ_DIR)/$$(RUN_$(1))_1.fastq $(FASTQ_DIR)/$(1)_1.fastq; \
		mv $(FASTQ_DIR)/$$(RUN_$(1))_2.fastq $(FASTQ_DIR)/$(1)_2.fastq; \
	elif test -s $(FASTQ_DIR)/$$(RUN_$(1)).fastq; then \
		mv $(FASTQ_DIR)/$$(RUN_$(1)).fastq $(FASTQ_DIR)/$(1).fastq; \
	else \
		echo 'No FASTQ output found for $$(RUN_$(1))' >&2; exit 1; \
	fi
	touch $$@

endef
$(foreach sample,$(SAMPLES),$(eval $(call SAMPLE_FASTQ_RULE,$(sample))))

$(BAM_DIR)/%.sorted.bam: $(REFERENCE).bwt $(REFERENCE).fai $(FASTQ_DIR)/%.downloaded
	mkdir -p $(@D)
	@if test -s $(FASTQ_DIR)/$*_1.fastq && test -s $(FASTQ_DIR)/$*_2.fastq; then \
		bwa mem -t $(THREADS) -R '@RG\tID:$(RUN_$*)\tSM:$*\tLB:$(PROJECT_ACCESSION)\tPU:$(RUN_$*)' \
			$(REFERENCE) $(FASTQ_DIR)/$*_1.fastq $(FASTQ_DIR)/$*_2.fastq \
		| samtools sort -@ $(THREADS) -o $@ -; \
	elif test -s $(FASTQ_DIR)/$*.fastq; then \
		bwa mem -t $(THREADS) -R '@RG\tID:$(RUN_$*)\tSM:$*\tLB:$(PROJECT_ACCESSION)\tPU:$(RUN_$*)' \
			$(REFERENCE) $(FASTQ_DIR)/$*.fastq \
		| samtools sort -@ $(THREADS) -o $@ -; \
	else \
		echo 'No normalized FASTQ found for sample $*' >&2; exit 1; \
	fi

$(BAM_DIR)/%.sorted.bam.bai: $(BAM_DIR)/%.sorted.bam
	samtools index $<

$(BAM_DIR)/%.flagstat.txt: $(BAM_DIR)/%.sorted.bam.bai
	samtools flagstat $(BAM_DIR)/$*.sorted.bam > $@

$(VCF_DIR)/%.vcf.gz: $(BAM_DIR)/%.sorted.bam.bai $(REFERENCE).fai
	mkdir -p $(@D)
	bcftools mpileup -Ou -f $(REFERENCE) $(BAM_DIR)/$*.sorted.bam \
		| bcftools call -mv -Oz -o $@
	bcftools index --tbi $@

$(MERGED_VCF): $(VCFS)
	mkdir -p $(@D)
	bcftools merge --merge all -Oz -o $@ $(VCFS)
	bcftools index --tbi $@

clean:
	rm -f $(BAMS) $(addsuffix .bai,$(BAMS)) $(FLAGSTATS) $(VCFS) \
		$(addsuffix .tbi,$(VCFS)) $(MERGED_VCF) $(MERGED_VCF).tbi \
		$(FASTQ_OUTPUTS) $(RAW_FASTQS) $(foreach sample,$(SAMPLES),$(FASTQ_DIR)/$(sample).downloaded) \
		$(SAMPLE_GFFS) $(REFERENCE_GFF) $(ANNOTATION_ARCHIVE) \
		$(REFERENCE).amb $(REFERENCE).ann $(REFERENCE).bwt \
		$(REFERENCE).pac $(REFERENCE).sa $(REFERENCE).fai \
		$(REFERENCE_ARCHIVE) $(REFERENCE)