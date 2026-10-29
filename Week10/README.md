# Assignment 10

## Organism

This is Helicobacter pylori. This is a pathogenic bacterium that causes stomach ulcers. It is able to survive in the stomach acidic environment by secreting ammonia to neutralize the area around itself.

I used 12 single-end ChIP-seq runs in 6 groups with 2 replicates per group: 1 background group and 5 IP conditions. CP001173.1 (G27 strain of H. pylori) is the reference genome.

The control (background) is input DNA, which is sheared chromatin sequenced without immunoprecipitation: SRR3955466 (input_A) and SRR3955467 (input_B). The same input is used as the background for all five conditions.

The five IP conditions (chromatin pulled down with an antibody against the named protein):

| Group | Replicate A | Replicate B | BioProject |
|---|---|---|---|
| HP1043 | SRR3955468 (HP1043-IP_A) | SRR3955469 (HP1043-IP_B) | PRJNA327549 |
| HSPR (wild type) | SRR6351953 (HSPR_wt_A) | SRR6351952 (HSPR_wt_B) | PRJNA421261 |
| Fur_dipyridyl (wild type, dipyridyl treated) | SRR25905507 (Fur_wt_dipyridyl_A) | SRR25905506 (Fur_wt_dipyridyl_B) | PRJNA313048 |
| Fur_iron (wild type, iron treated) | SRR25905511 (Fur_wt_iron_A) | SRR25905510 (Fur_wt_iron_B) | PRJNA313048 |
| NikR_untreated (wild type, no nickel) | SRR3401659 (NikR_wt_ni-_A) | SRR3401754 (NikR_wt_ni-_B) | PRJNA313048 |

## Create files

create design.csv and Makefiles

```bash
touch design.csv
```

```bash
touch Makefile
```

copy and paste contents from the design.csv and makefile from this directory

Before running, ensure that MACS3 is installed

```bash
micromamba install -n bioinfo -c bioconda macs3
```

run:

```bash
make all
```

## How many peaks were called in each sample?

Run:

```bash
cd /Users/kenny/BMMB852/Week10 && for s in SRR3955468 SRR3955469 SRR6351953 SRR6351952 SRR25905507 SRR25905506 SRR25905511 SRR25905510 SRR3401659 SRR3401754; do ~/micromamba/envs/bioinfo/bin/macs3 callpeak -f BAM -g 1.65e6 --nomodel --extsize 147 -n $s --outdir peaks -t bam/$s.bam -c bam/SRR3955466.bam bam/SRR3955467.bam > /dev/null 2>&1; echo "$s $(wc -l < peaks/${s}_peaks.narrowPeak)"; done
```

output

```bash
SRR3955468     1388
SRR3955469     1311
SRR6351953      577
SRR6351952     1104
SRR25905507     1410
SRR25905506     1403
SRR25905511     1387
SRR25905510     1274
SRR3401659     1435
SRR3401754      994
```

## How consistent are the peak calls within replicates?

Run:

```bash
cd /Users/kenny/BMMB852/Week10 && B=~/micromamba/envs/bioinfo/bin/bedtools && for p in "SRR3955468 SRR3955469" "SRR6351953 SRR6351952" "SRR25905507 SRR25905506" "SRR25905511 SRR25905510" "SRR3401659 SRR3401754"; do set -- $p; a=peaks/$1_peaks.narrowPeak; b=peaks/$2_peaks.narrowPeak; na=$(wc -l < $a | tr -d ' '); nb=$(wc -l < $b | tr -d ' '); sh=$($B intersect -a $a -b $b -u | wc -l | tr -d ' '); echo "$1 vs $2: A=$na B=$nb shared=$sh ($((100*sh/na))% of A, $((100*sh/nb))% of B)"; done
```

Output:

```bash
SRR3955468 vs SRR3955469: A=1388 B=1311 shared=1052 (75% of A, 80% of B)
SRR6351953 vs SRR6351952: A=577 B=1104 shared=395 (68% of A, 35% of B)
SRR25905507 vs SRR25905506: A=1410 B=1403 shared=1303 (92% of A, 92% of B)
SRR25905511 vs SRR25905510: A=1387 B=1274 shared=1187 (85% of A, 93% of B)
SRR3401659 vs SRR3401754: A=1435 B=994 shared=840 (58% of A, 84% of B)
```

### IGV

Load genome:

ref/CP001173.1.fa

Agreement:

Peak calls A's in peak_916 spans roughly 1,140,200 thru 1,140,690 and B's peak_875 spans roughly 1,140,520 thru 1,140,695

Disagreement:

Peak_915 spanning roughly 1,139,850 thru 1,140,020 is only visible in A, but not B

![alt text](<Screenshot 2026-10-29 at 2.46.46 PM.png>)