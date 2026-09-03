ASSEMBLY := GCF_902846105.1
ACCESSION := NZ_CADHBV000000000.1
ARCHIVE := $(ASSEMBLY).zip
FASTA := fasta/HPylori_$(ACCESSION).fna
FASTA_INDEX := $(FASTA).fai
GFF := gff/HPylori_$(ACCESSION).gff
GFF_GZ := $(GFF).gz
GFF_INDEX := $(GFF_GZ).tbi
DATASETS_URL := https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$(ASSEMBLY)/download?include_annotation_type=GENOME_GFF,GENOME_FASTA

.PHONY: all fasta gff clean

all: fasta gff indexes

fasta: $(FASTA)

gff: $(GFF)

indexes: $(FASTA_INDEX) $(GFF_INDEX)

$(ARCHIVE):
	curl --fail --location --silent --show-error --output $@ '$(DATASETS_URL)'

$(FASTA): $(ARCHIVE)
	mkdir -p $(@D)
	unzip -p $< 'ncbi_dataset/data/$(ASSEMBLY)/*.fna' > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

$(GFF): $(ARCHIVE)
	mkdir -p $(@D)
	unzip -p $< 'ncbi_dataset/data/$(ASSEMBLY)/genomic.gff' > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

$(FASTA_INDEX): $(FASTA)
	samtools faidx $<

$(GFF_GZ): $(GFF)
	bgzip --force --keep $<

$(GFF_INDEX): $(GFF_GZ)
	tabix --force --preset gff $<

clean:
	rm -rf fasta gff $(ARCHIVE)