# Assignment 2
        
## Genome used:

https://www.ncbi.nlm.nih.gov/nuccore/NZ_CADHBV000000000.1

This is Helicobacter Pylori. This is a pathogenic bacterium that causes stomach ulcers. It is able to survive in the 
stomach's acidic environment by secreting ammonia to neutralize the area around itself.

## Make a Makefile

Open working folder

```bash
touch Makefile
```

## Download FASTA and GFF Files:

Use the following Makefile code to download FASTA and GFF files, unzip, rename and make indices.
    
```bash
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
``` 

Output:

```bash
fasta/HPylori_NZ_CADHBV000000000.1.fna
fasta/HPylori_NZ_CADHBV000000000.1.fna.fai
gff/HPylori_NZ_CADHBV000000000.1.gff  
gff/HPylori_NZ_CADHBV000000000.1.gff.gz
gff/HPylori_NZ_CADHBV000000000.1.gff.gz.tbi
```

## Load onto IGV

Load in reference genome:

HPylori_NZ_CADHBV000000000.1.fna

Then annotation track:

HPylori_NZ_CADHBV000000000.1.gff.gz

## Questions

### How large is the genome? How many chromosomes does it have?

#### Assembly check to count lines

```bash
grep -v '^#' fasta/HPylori_NZ_CADHBV000000000.1.fna | wc -l
```
#### count contigs

```bash
grep '^>' fasta/HPylori_NZ_CADHBV000000000.1.fna | wc -l
```

Calculate total genome size:

```bash
awk '
/^>/ {
    if (length(sequence) > 0) total += length(sequence)
    sequence = ""
    contigs++
    next
}
{
    sequence = sequence $0
}
END {
    total += length(sequence)
    print "Contigs:", contigs
    print "Total bp:", total
    print "Total Mb:", total / 1000000
}' fasta/HPylori_NZ_CADHBV000000000.1.fna
```

Output:

```bash
Contigs: 49
Total bp: 1657706
Total Mb: 1.65771
```

The genome of Helicobacter pylori is roughly 1657706 bp, 1657.706 Kb, or 1.657706 Mb.
This bacterium has a singluar circular chromosome that is separated into 49 different contigs.

### How many annotations are in the annotation file?

To find how many annotations are in the annotation file, I used:
zgrep = searches  inside compressed .gz files
-v = excludes lines matching the pattern
'^#' = matches lines beginning with #, which are GFF headers and comments
| = sends remaining lines to next command
wc -l = counts the remaining lines

```bash
zgrep -v '^#' gff/HPylori_NZ_CADHBV000000000.1.gff.gz | wc -l
```
Output: 

kenny@MacBook-Pro ~/BMMB852/Week02/Makefile
$ zgrep -v '^#' gff/HPylori_NZ_CADHBV000000000.1.gff.gz | wc -l
    3347
(bioinfo) 

#### There are 3347 annotations in the .gff.gz file

### How complete is the genomic build in your opinion

I would say that this genome is mostly complete since the reported genome size of H. pylori is about 1.6 - 1.7 Mb
according to Dawson et. al. 2019, where as I observed ~1.65 Mb

#### Determine completness using the Busco tool

Install busco

```bash
conda install -c conda-forge -c bioconda busco
```

Verify
```
busco --version
```

Run busco command
```bash
busco \
  -i fasta/HPylori_NZ_CADHBV000000000.1.fna \
  -l bacteria_odb10 \
  -m genome \
  -o hpylori_busco
```

Output:

    ---------------------------------------------------
    
    |Results from dataset bacteria_odb10               |
    
    ---------------------------------------------------
    
    |C:84.7%[S:84.7%,D:0.0%],F:4.8%,M:10.5%,n:124      |
    
    |105    Complete BUSCOs (C)                        |
    
    |105    Complete and single-copy BUSCOs (S)        |
    
    |0    Complete and duplicated BUSCOs (D)           |
    
    |6    Fragmented BUSCOs (F)                        |
    
    |13    Missing BUSCOs (M)                          |
    
    |124    Total BUSCO groups searched                |
    
    ---------------------------------------------------

This means:

105 complete genes: 84.7%

105 complete single copy genes: 84.7%

0 duplicate genes: 0%

6 fragmented genes: 4.8%

13 missing genes: 10.5%

### How tightly packed are the genes in this genome? Estimate the gene-to-gene distance via the browser.

The genes are fairly packed together with a range of around 50-150bp distance between genes

### Pick a coordinate on the chromosome and visually inspect the sequence regions around it.

#### Describe all six reading frames (codons) that the coordinate could be part of.

Coordinates:

NZ_CADHBV010000001.1:153,146-153,240

<img width="1705" height="269" alt="image" src="https://github.com/user-attachments/assets/d1b3138e-c16e-4c4d-964d-476e1f3f7123" />


<img width="1710" height="277" alt="image" src="https://github.com/user-attachments/assets/dcc78cd9-6e60-494c-b50b-51a91a031eb6" />


Forward:

R N * G S T L K L L S T S N G * G V I M L V K G N E I L L K A H

G T K E A R * N C Y Q Q V M D E V L S C * L K A M K S Y * K P I

E L R K H A K I V I N K * W M R C Y H V S * R Q * N L I E S P *

Reverse:

P V L S A R * F Q * * C T I S S T N D H * N F A I F D * Q F G M

F * P L V S F N N D V L L P H P T I M N T L P L S I K N F A W

S S L F C A L I T L L Y H I L H * * T L * L C H F R I S L G Y

### Identify the type of feature displayed as a data track.

My  gff.gz file is displayed as the annotated data from the track and my fna.fai file is the reference

### Color features by their strand orientation

I color coded the introns orange in the forward direction

<img width="1712" height="286" alt="image" src="https://github.com/user-attachments/assets/bd21b832-cee2-4d13-a687-1eb58b3da28c" />

