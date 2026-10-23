# Assignment 9

## CPU Count

run command:

```bash
sysctl -n hw.ncpu
```

Output:

```bash
10
```

## Make files

Make Makefile:

```bash
touch Makefile
```

Make design.csv

```bash
touch design.csv
```

run

```bash
make batch JOBS=8 THREADS=1
```

## check to see if this worked

verify files

```bash
ls
```

output:

```bash
Makefile   README.md  bam        design.csv fastq      ref        results    vcf
```

verify:

```bash
cd results
ls
```

output:

```bash
merged.vcf.gz     merged.vcf.gz.csi
```

## Visualization on IGV

load in ref/NC_000915.fa.fai to genome

From files, upload results/merged.vcf.gz

![alt text](<screenshots/Screenshot 2026-10-22 at 7.28.18 PM.png>)

There is one SNP variant in position 1,208,526 (SNP G>T) that appears inconsistently across samples:

![alt text](<screenshots/Screenshot 2026-10-22 at 7.32.00 PM.png>)

![alt text](<screenshots/Screenshot 2026-10-22 at 7.33.36 PM.png>)

![alt text](<screenshots/Screenshot 2026-10-22 at 7.34.30 PM.png>)

![alt text](<screenshots/Screenshot 2026-10-22 at 7.35.25 PM.png>)

![alt text](<screenshots/Screenshot 2026-10-22 at 7.36.11 PM.png>)

![alt text](<screenshots/Screenshot 2026-10-22 at 7.36.58 PM.png>)

![alt text](<screenshots/Screenshot 2026-10-22 at 7.38.25 PM.png>)

![alt text](<screenshots/Screenshot 2026-10-22 at 7.39.14 PM.png>)

There is also a cluster of variants that were called:

![alt text](<screenshots/Screenshot 2026-10-23 at 7.01.02 PM.png>)