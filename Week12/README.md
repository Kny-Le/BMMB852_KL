# Assignment 12

## Obtain necessary files

Install salmon

```bash
conda create -n rnaseq -c conda-forge -c bioconda --strict-channel-priority salmon parallel
conda activate rnaseq
salmon --version
```

obtain make file

```bash
curl -fsSL https://data.biostarhandbook.com/make/rnaseq.salmon.2026.mk > Makefile
```

Generate files

```bash
make batch
```

```bash
make data
```

```bash
make index
```

## making the R script

Make a directory for the counts

```bash
mkdir src
```

I prompted my AI, VS Code, with the following"

```bash
Please combine the individual transcript counts into a single transcript-level count matrix then into another gene level count matrix. Ensure that both matricies have gene names associated with each row. Then put this into my src folder.
```

I then opened the script in R studio and ran with command + a, and command + return on mac

in your terminal paste:

```bash
open counts/gene_group_summary.tsv
```

The count matrices support the visual observations from last week's assignment. TUBA3GP has zero CPM in both groups, while RPL3 has high CPM. YWHAH has a higher mean CPM in HBR than UHR (25,944.9 versus 4,714.3; log2 fold change UHR/HBR is about -2.46), consistent with the observed group difference. These group averages are descriptive and do not by themselves establish statistical differential expression.

Column 1: Gene ID

Column 2: Gene Name

Column 3: HBR Mean CPM

Column 4: UHR Mean CPM

Column 5: log2FC (UHR/HBR)

![Gene count summary showing TUBA3GP](<screenshots/Screenshot 2026-11-12 at 1.01.40 PM.png>)

![Gene count summary showing RPL3](<screenshots/Screenshot 2026-11-12 at 1.06.19 PM.png>)

![Gene count summary showing YWHAH](<screenshots/Screenshot 2026-11-12 at 3.10.16 PM.png>)

My experience working the the AI on this has been interesting since I have only used R to process data and make graphs from data points and/or RNA-seq. I have never used R to calculate counts of different genes for me before. What I have done in the past is just process the sequencing files separately and then in R organize and plot it.