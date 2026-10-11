# Assignment 7

## Make the Makefile

```bash
touch Makefile
```

paste contents of makefile from this week's file

run:
```bash
make
```

## Run Statistics report

```bash
bcftools stats \
  -F fasta/HPylori_NZ_CADHBV000000000.1.fna \
  -s - \
  vcf/HPylori.KAZ-017.vcf \
  > vcf/HPylori.KAZ-017.stats.txt
```

View summary lines

```bash
grep '^SN' vcf/HPylori.KAZ-017.stats.txt
```

Output:

```bash
SN	0	number of samples:	1
SN	0	number of records:	62132
SN	0	number of no-ALTs:	0
SN	0	number of SNPs:	61379
SN	0	number of MNPs:	0
SN	0	number of indels:	753
SN	0	number of others:	0
SN	0	number of multiallelic sites:	23
SN	0	number of multiallelic SNP sites:	19
```

This means that the VCF contains 62,132 SNPs, 753 insertions/deletions, 0 substituions, 0 alternate alleles, 23 multiallelic sites, 19 muliallelic SNP sites for this one sample.

## Are the calls supported by the alignments?

### read-level check of specific variant

```bash
bcftools view -H vcf/HPylori.KAZ-017.vcf.gz | head
```

output:
```bash
NZ_CADHBV010000001.1	35	.	C	A	196	.	DP=77;VDB=2.79637e-07;SGB=-0.690438;MQSB=0.211072;MQ0F=0.025974;AC=2;AN=2;DP4=0,0,14,3;MQ=52	GT:PL	1/1:226,51,0
NZ_CADHBV010000001.1	37	.	T	A	194	.	DP=79;VDB=3.67298e-08;SGB=-0.692067;MQSB=0.198087;MQ0F=0.0253165;AC=2;AN=2;DP4=0,0,17,3;MQ=54	GT:PL	1/1:224,60,0
NZ_CADHBV010000001.1	47	.	A	G	191	.	DP=92;VDB=1.37431e-07;SGB=-0.693021;MQSB=0;MQ0F=0.0217391;AC=2;AN=2;DP4=0,0,25,2;MQ=55	GT:PL	1/1:221,81,0
NZ_CADHBV010000001.1	67	.	TC	T	214	.	INDEL;IDV=93;IMF=0.958763;DP=97;VDB=2.60724e-12;SGB=-0.693147;MQSB=0.982608;MQ0F=0.0206186;AC=2;AN=2;DP4=11,12,60,14;MQ=58	GT:PL	1/1:241,34,0
NZ_CADHBV010000001.1	149	.	G	C	225	.	DP=119;VDB=4.53062e-07;SGB=-0.693147;MQSB=1;MQ0F=0;AC=2;AN=2;DP4=0,0,55,4;MQ=60	GT:PL	1/1:255,178,0
NZ_CADHBV010000001.1	273	.	T	C	228	.	DP=134;VDB=0.336612;SGB=-0.693147;RPB=1;MQB=1;MQSB=1;BQB=1;MQ0F=0;AC=2;AN=2;DP4=1,0,68,22;MQ=60	GT:PL	1/1:255,254,0
NZ_CADHBV010000001.1	274	.	C	T	228	.	DP=135;VDB=0.283424;SGB=-0.693147;RPB=0.419355;MQB=1;MQSB=1;BQB=0.155914;MQ0F=0;AC=2;AN=2;DP4=1,1,70,23;MQ=60	GT:PL	1/1:255,235,0
NZ_CADHBV010000001.1	276	.	A	G	225	.	DP=138;VDB=0.268804;SGB=-0.693147;MQSB=1;MQ0F=0;AC=2;AN=2;DP4=0,0,69,21;MQ=60	GT:PL	1/1:255,255,0
NZ_CADHBV010000001.1	330	.	T	C	225	.	DP=131;VDB=0.653927;SGB=-0.693147;MQSB=1;MQ0F=0;AC=2;AN=2;DP4=0,0,64,32;MQ=60	GT:PL	1/1:255,255,0
NZ_CADHBV010000001.1	333	.	C	T	225	.	DP=127;VDB=0.468842;SGB=-0.693147;MQSB=1;MQ0F=0;AC=2;AN=2;DP4=0,0,61,35;MQ=60	GT:PL	1/1:255,255,0
```

What this means for the fourth variant shown:

Chromosome: NZ_CADHBV010000001.1
Position: 67
Reference base: TC
Alternative base: T
Quality: 214
Reads covering site (DP): 97


### Pick region from VCF to compare to bam file

I chose position 60 thru 70, so then I used:

```bash
samtools mpileup -f fasta/HPylori_NZ_CADHBV000000000.1.fna \
  bam/HPylori.KAZ-017.sorted.bam \
  -r 'NZ_CADHBV010000001.1:60-70'
```

Output:

```bash
[mpileup] 1 samples in 1 input files
NZ_CADHBV010000001.1	60	A	29	............,,...............	1CG9B2GGGGC9GGGGGGEFG`GGGGG<B
NZ_CADHBV010000001.1	61	G	33	,.............,,...............^].^	BCEFGF<AGGFGEDGGGGG<GGG]GF<GGC<CC
NZ_CADHBV010000001.1	62	C	33	.............,,..................	88FGF@>GFFGA9GGGGGEGCGGPGFFGGC9CC
NZ_CADHBV010000001.1	63	A	33	,.............,,.................	F;CGEE9BFCGGFCGGGGGGEGGXGEFGGGCCC
NZ_CADHBV010000001.1	64	T	33	,............,,..................	A;/GE=01GDGFFECGGGAGFGGNGGFGGGFCC
NZ_CADHBV010000001.1	65	T	32	,...........,,..................	==GF:1GFGFA.BBDGG>G9FGWGGDFGGECC
NZ_CADHBV010000001.1	66	T	29	,........,,..................	5EA2EEEEAA@EEE<ECEENEEBEEECEE
NZ_CADHBV010000001.1	67	T	30	,-1c.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C,$,.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C	D:ED4EDEE@?4EEE;EBEESEEADEEBEE
NZ_CADHBV010000001.1	68	C	31	*******************************	8E7FC=CGAGGACGGGFGFGGPFGEFGCGGG
NZ_CADHBV010000001.1	69	G	33	,...............................^].	8E7FC=CGAGGACGGGFGFGGPFGEFGCGGGC4
NZ_CADHBV010000001.1	70	T	32	,..............................^].	::FF>FGFGGFGGG;F@GGPGGGFGFGGEG0C
```
In the case of position 35, this means:

Chromosome: NZ_CADHBV010000001.1
Position: 67
Reference base: T
Depth: 30
What reads show: -1c.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C,$,.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C.-1C
Base quality: D:ED4EDEE@?4EEE;EBEESEEADEEBEE

### Interpretation

The VCF file tells us that a variant has been called at position 67 and the BAM pileup shows us that the varient exists in the alignment. In the image below, we can see that this variant that has been called can be visualized in IGV. From this analysis it can be concluded that, at least one of the alignments and variant callings appear to be in agreement with each other. Additionally, the variants shown do not have lower read depth, leading me to believe that the variants can largely be trusted and not likely to be errors.

![alt text](<Screenshot 2026-10-11 at 2.17.01 AM.png>)

## IGV

The alignment on IGV appears to be fairly consistent with what appears in the statistics report. There are also clear empty spaces throughout the alignment that show no coverage to the reference genome.

coordinates: NZ_CADHBV010000001.1:16,139-24,250

![alt text](<Screenshot 2026-10-11 at 1.56.40 AM.png>)

Coordinates: NZ_CADHBV010000001.1:48,602-49,108

![alt text](<Screenshot 2026-10-11 at 1.14.39 AM.png>)
