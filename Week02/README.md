# Assignment 2
        
## Genome used:

https://www.ncbi.nlm.nih.gov/nuccore/NZ_CADHBV000000000.1

This is Helicobacter Pylori

## Make a Makefile

Open working folder

```bash
touch Makefile
```

## Make a FASTA and GIFF (paste into makefile):
    
```bash
ASSEMBLY := GCF_902846105.1
ARCHIVE := $(ASSEMBLY).zip

FASTA := fasta/$(ASSEMBLY).fna
GFF := gff/$(ASSEMBLY).gff

DATASETS_URL := https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$(ASSEMBLY)/download?include_annotation_type=GENOME_GFF,GENOME_FASTA

.PHONY: all fasta gff clean

all: fasta gff

fasta: $(FASTA)

gff: $(GFF)

$(ARCHIVE):
    curl --fail --location --silent --show-error \
        --output $@ '$(DATASETS_URL)'

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

clean:
    rm -rf fasta gff $(ARCHIVE)
```

From same folder as the Makefile, run:

```bash
make all
```
    
Output:

fasta/GCF_902846105.1.fna

gff/GCF_902846105.1.gff
        
## rename folders
    
```bash
mv fasta/GCF_902846105.1.fna \
   fasta/HPylori_NZ_CADHBV000000000.1.fna

mv gff/GCF_902846105.1.gff \
   gff/HPylori_NZ_CADHBV000000000.1.gff
``` 
## Make Indexes (paste into terminal)

```bash
cd /Users/kenny/BMMB852/Week02/Makefile

PATH=/tmp/hts-tools/bin:$PATH

samtools faidx \
fasta/HPylori_NZ_CADHBV000000000.1.fna

bgzip --force --keep \
gff/HPylori_NZ_CADHBV000000000.1.gff

tabix --force --preset gff \
gff/HPylori_NZ_CADHBV000000000.1.gff.gz
```

Output:

```bash
fasta/HPylori_NZ_CADHBV000000000.1.fna.fai
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

<img width="1712" height="286" alt="image" src="https://github.com/user-attachments/assets/bd21b832-cee2-4d13-a687-1eb58b3da28c" />

