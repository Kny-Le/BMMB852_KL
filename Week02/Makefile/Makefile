# =========================================================
# Makefile: Download, extract, and index H. pylori genome
# Source: NCBI Datasets API
# =========================================================

# --- Variables ---------------------------------------------------------

ASSEMBLY := GCF_902846105.1                  # NCBI RefSeq assembly accession to download
ACCESSION := NZ_CADHBV000000000.1            # Genome accession, used to build human-readable file names
ARCHIVE := $(ASSEMBLY).zip                   # Name of the zip archive downloaded from NCBI

FASTA := fasta/HPylori_$(ACCESSION).fna      # Final path for the extracted, renamed FASTA file
FASTA_INDEX := $(FASTA).fai                  # samtools faidx index for the FASTA file

GFF := gff/HPylori_$(ACCESSION).gff          # Final path for the extracted, renamed GFF annotation file
GFF_GZ := $(GFF).gz                          # Bgzip-compressed version of the GFF (required for tabix)
GFF_INDEX := $(GFF_GZ).tbi                   # Tabix index for the bgzipped GFF

# NCBI Datasets v2 API URL to download both genome FASTA and GFF annotation for the given assembly
DATASETS_URL := https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$(ASSEMBLY)/download?include_annotation_type=GENOME_GFF,GENOME_FASTA

# Extract directly to the organism-specific names; no manual mv is needed.

# --- Special targets -----------------------------------------------------

.PHONY: all fasta gff indexes clean   # These targets are not real files, always run when called
.DELETE_ON_ERROR:                     # If a recipe fails partway, delete its target so make doesn't think it's up to date

# --- Top-level targets ---------------------------------------------------

all: fasta gff indexes                # Default target: build FASTA, GFF, and all indexes

fasta: $(FASTA)                       # Shortcut to build just the FASTA file

gff: $(GFF)                           # Shortcut to build just the GFF file

indexes: $(FASTA_INDEX) $(GFF_INDEX)  # Shortcut to build both the FASTA index and GFF index

# --- Download ---------------------------------------------------------

$(ARCHIVE):
	# Download the genome+annotation zip archive from NCBI
	# --fail: exit with error on HTTP failure instead of saving an error page
	# --location: follow redirects
	# --silent --show-error: suppress progress bar but still print real errors
	curl --fail --location --silent --show-error --output $@ '$(DATASETS_URL)'

# --- Extraction ---------------------------------------------------------

$(FASTA): $(ARCHIVE)
	mkdir -p $(@D)                                              # Create the fasta/ directory if it doesn't exist
	unzip -p $< 'ncbi_dataset/data/$(ASSEMBLY)/*.fna' > $@.tmp  # Extract FASTA from zip to a temp file
	test -s $@.tmp                                              # Fail here if the extracted file is empty
	mv $@.tmp $@                                                # Only rename to final name once verified non-empty

$(GFF): $(ARCHIVE)
	mkdir -p $(@D)                                                  # Create the gff/ directory if it doesn't exist
	unzip -p $< 'ncbi_dataset/data/$(ASSEMBLY)/genomic.gff' > $@.tmp  # Extract GFF from zip to a temp file
	test -s $@.tmp                                                  # Fail here if the extracted file is empty
	mv $@.tmp $@                                                    # Only rename to final name once verified non-empty

# --- Indexing ---------------------------------------------------------

$(FASTA_INDEX): $(FASTA)
	samtools faidx $<              # Generate a .fai index so IGV/samtools can randomly access sequence regions

$(GFF_GZ): $(GFF)
	bgzip -c $< > $@.tmp            # Compress the GFF with bgzip (block-gzip, required by tabix) to a temp file
	test -s $@.tmp                  # Fail here if the compressed file is empty
	mv $@.tmp $@                    # Only rename to final name once verified non-empty

$(GFF_INDEX): $(GFF_GZ)
	tabix --force --preset gff $<   # Build a tabix index on the bgzipped GFF for fast region queries in IGV

# --- Cleanup ---------------------------------------------------------

clean:
	rm -rf fasta gff $(ARCHIVE)     # Remove all generated files and directories to start fresh
