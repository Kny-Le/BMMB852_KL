# Assignment 5

## Organism

https://www.ncbi.nlm.nih.gov/sra/SRX35013314[accn]

This is Helicobacter pylori. This is a pathogenic bacterium that causes stomach ulcers. It is able to survive in the stom$ acidic environment by secreting ammonia to neutralize the area around itself.

PRJNA1515477

SRP728672

SRR40271341

## Makefile

### Pool data

I copied my FASTA and FASTQ files from my Week02 and Week04 assignments onto this Week05 file

```bash
cp Week02/Makefile/fasta/*.fna Week05/fasta/
cp Week04/data/fastq/*.fastq Week05/fastq/
cp Week04/data/fastq/*.fastq.gz Week05/fastq/
```

Confirm:

```bash
kenny@MacBook-Pro ~/BMMB852/Week05/fasta
$ ls
HPylori_NZ_CADHBV000000000.1.fna
(bioinfo) 

kenny@MacBook-Pro ~/BMMB852/Week05/fastq
$ ls
SRR40271341_1.fastq    SRR40271341_1.fastq.gz SRR40271341_2.fastq    SRR40271341_2.fastq.gz
(bioinfo) 
```

### Generate the Makefile to conduct the alignment

make makefile in directory containing FASTA and FASTQ files

```bash
touch Makefile
```

Paste into Makefile

```bash
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
```

Run Makefile

```bash
make
```
Confirm

```
kenny@MacBook-Pro ~/BMMB852/Week05/bam
$ ls
HPylori.KAZ-017.flagstat.txt   HPylori.KAZ-017.sorted.bam     HPylori.KAZ-017.sorted.bam.bai
(bioinfo)
```

Output from my statistics report (flagstat.txt) file

```bash
786338 + 0 in total (QC-passed reads + QC-failed reads)
773074 + 0 primary
0 + 0 secondary
13264 + 0 supplementary
0 + 0 duplicates
0 + 0 primary duplicates
755109 + 0 mapped (96.03% : N/A)
741845 + 0 primary mapped (95.96% : N/A)
773074 + 0 paired in sequencing
386537 + 0 read1
386537 + 0 read2
727216 + 0 properly paired (94.07% : N/A)
735384 + 0 with itself and mate mapped
6461 + 0 singletons (0.84% : N/A)
6250 + 0 with mate mapped to a different chr
6087 + 0 with mate mapped to a different chr (mapQ>=5)
```

96.03% of all alignment records mapped to the reference and 95.96% of the primary alignments mapped.
 
### Check coverage

Run:

```bash
samtools coverage bam/HPylori.KAZ-017.sorted.bam
```

Output:

```bash
#rname	startpos	endpos	numreads	covbases	coverage	meandepth	meanbaseq	meanmapq
NZ_CADHBV010000001.1	1	472566	212105	428992	90.7793	119.775	32.2	59.6
NZ_CADHBV010000002.1	1	145492	66297	139624	95.9668	118.766	32.2	59.4
NZ_CADHBV010000003.1	1	100610	48728	92169	91.6102	128.836	32	59.7
NZ_CADHBV010000004.1	1	96009	44590	93684	97.5784	123.067	32.1	59.5
NZ_CADHBV010000005.1	1	91255	44235	84908	93.0448	129.517	32.1	59.4
NZ_CADHBV010000006.1	1	84364	37968	81003	96.0161	122.65	32.2	59.7
NZ_CADHBV010000007.1	1	77641	42213	67122	86.4517	145.569	32.3	59.5
NZ_CADHBV010000008.1	1	60906	29612	60441	99.2365	133.152	32.1	59.7
NZ_CADHBV010000009.1	1	59887	27797	59041	98.5873	124.543	32.2	59.6
NZ_CADHBV010000010.1	1	57884	28157	56848	98.2102	131.692	32.2	59.7
NZ_CADHBV010000011.1	1	52325	24268	52079	99.5299	126.563	32.1	59.7
NZ_CADHBV010000012.1	1	47406	22306	46994	99.1309	127.016	32.1	59.7
NZ_CADHBV010000013.1	1	41532	20141	40952	98.6035	128.615	32.2	59.2
NZ_CADHBV010000014.1	1	39459	17660	37788	95.7652	114.646	32.2	58.3
NZ_CADHBV010000015.1	1	34142	9879	18301	53.6026	73.3221	32.2	58.7
NZ_CADHBV010000016.1	1	33021	15609	32745	99.1642	125.636	32.1	59.6
NZ_CADHBV010000017.1	1	27772	11646	24191	87.1057	113.424	32.2	59.4
NZ_CADHBV010000018.1	1	23688	11971	23089	97.4713	129.579	32.3	58.7
NZ_CADHBV010000019.1	1	18503	9420	18501	99.9892	139.486	32.3	59.7
NZ_CADHBV010000020.1	1	17803	1151	1004	5.6395	13.0719	32.8	59.4
NZ_CADHBV010000021.1	1	13703	4873	10404	75.925	92.2694	32.2	58.4
NZ_CADHBV010000022.1	1	8365	3860	8330	99.5816	116.971	32.3	57.4
NZ_CADHBV010000023.1	1	8175	22	21	0.256881	0.0565138	35.6	47.8
NZ_CADHBV010000024.1	1	5489	1901	4100	74.6948	86.6947	32.1	56.9
NZ_CADHBV010000025.1	1	5463	2	383	7.0108	0.102691	31.7	60
NZ_CADHBV010000026.1	1	4935	2424	3757	76.1297	99.0077	32.7	58.2
NZ_CADHBV010000027.1	1	4475	4353	4174	93.2737	236.526	32.3	58.3
NZ_CADHBV010000030.1	1	2686	2582	2564	95.4579	198.624	33.3	54.1
NZ_CADHBV010000031.1	1	2120	2542	2120	100	323.713	32.6	59.7
NZ_CADHBV010000032.1	1	1916	1138	1851	96.6075	110.946	32.3	52.8
NZ_CADHBV010000034.1	1	1682	2275	1358	80.7372	313.638	32.5	57.8
NZ_CADHBV010000035.1	1	1485	715	1476	99.3939	132.997	32.9	59.9
NZ_CADHBV010000036.1	1	1068	955	1068	100	228.883	33	59
NZ_CADHBV010000037.1	1	966	984	874	90.4762	192.997	33.1	55.3
NZ_CADHBV010000038.1	1	530	470	530	100	217.079	32.4	56.7
NZ_CADHBV010000039.1	1	475	9	101	21.2632	0.850526	31.9	8.89
NZ_CADHBV010000041.1	1	331	116	173	52.2659	20.9396	33.8	54.2
NZ_CADHBV010000043.1	1	302	135	40	13.245	17.5993	23.3	56.4
NZ_CADHBV010000028.1	1	3859	0	0	0	0	0	0
NZ_CADHBV010000029.1	1	3279	0	0	0	0	0	0
NZ_CADHBV010000033.1	1	1838	0	0	0	0	0	0
NZ_CADHBV010000040.1	1	360	0	0	0	0	0	0
NZ_CADHBV010000042.1	1	305	0	0	0	0	0	0
NZ_CADHBV010000044.1	1	289	0	0	0	0	0	0
NZ_CADHBV010000045.1	1	288	0	0	0	0	0	0
NZ_CADHBV010000046.1	1	281	0	0	0	0	0	0
NZ_CADHBV010000047.1	1	280	0	0	0	0	0	0
NZ_CADHBV010000048.1	1	251	0	0	0	0	0	0
NZ_CADHBV010000049.1	1	245	0	0	0	0	0	0
```

#### Mean covereage across entire genome

command:

```bash
samtools depth -aa bam/HPylori.KAZ-017.sorted.bam |
awk '{sum += $3; bases++} END {print "Mean coverage:", sum/bases "x"}'
```

output:

```bash
Mean coverage: 120.947x
```

#### Mean coverage only across covered bases

command:
```bash
samtools depth bam/HPylori.KAZ-017.sorted.bam |
awk '{sum += $3; bases++} END {print "Mean depth over covered bases:", sum/bases "x"}'
```

Output:

```bash
Mean depth over covered bases: 133.248x
```

## IVG Visualization

Coordinates (on contig 1): NZ_CADHBV010000001.1:241,995-242,247

![IGV alignment view](<screenshots/Screenshot 2026-09-23 at 12.57.52 PM.png>)

![IGV alignment detail](<screenshots/Screenshot 2026-09-23 at 1.06.06 PM.png>)

![IGV coverage view](<screenshots/Screenshot 2026-09-23 at 1.06.49 PM.png>)

## Summary

Overall, the alignments looks generally strong, with ~ 96% of the primary reads aligning to the H. pylory reference genome and ~94% of the reads being properly paired with over a 120x covereage. However, despite the coverage being high across most major contigs, it is very uneven across the entire assembly since there are several small contigs that have low or no coverage.
In IGV, the colored regions represent areas that are different from the reference genome, with there being some consistent varations repeated across multiple reads, reflecting true genetic variation. However there are some isolated colored bases found only on a few bases, suggesting some sequencing errors or alignment artifacts.