# Assignment 11

## Obtaining files

ran:

```bash
# Example Makefile
curl -fsSL https://data.biostarhandbook.com/make/rnaseq.hisat.2026.mk > Makefile
```

```bash
make batch
```

## Load into IGV

Load reference genome (fasta/chr22.genome.fa)

Load in coverage files (bw/HBR_1.bw, HBR_2.bw, HBR_3.bw, UHR_1.bw, UHR_2.bw, UHR_3.bw)

Load in gtf/chr22.gtf

## Questions

### 1. Look at a wide region (millions of bases wide). How are the two sample types different?

In general, the two samples have peaks around the same areas as each other, but varies in coverage. The HBR samples have coverages ranging from 22 - 31x while the UHR samples range from 31 - 60x coverage. Overall, the pattern of peaks is the same and height differs.

![alt text](<screenshots/Screenshot 2026-11-05 at 9.27.26 AM.png>)

### 2. Navigate across the genome. How consistent are the replicates?

I see that, between replicates, the main outlier is UHR_3 and has 1.5-2x more coverage than UHR_1 and UHR_2. The UHR samples also seem to have random peaks throughout the intronic region, but this may be unspliced pre-mRNA. However, the HBR samples appear to be more consistent across replicates.

![alt text](<screenshots/Screenshot 2026-11-05 at 9.35.24 AM.png>)

### 3. Find a gene that is not expressed in any of the samples.

TUBA3GP shows no visible coverage in any of the samples. Although this is a pseudogene, meaning it resembles a segment of DNA that structurally resembles a known functional gene, so its expression may be difficult to assess from read coverage alone.

![alt text](<screenshots/Screenshot 2026-11-05 at 9.36.58 AM.png>)

### 4. Find a gene that is very strongly expressed in all samples. What is its coverage?

RPL3 is highly expressed in all samples and has a coverage of 97 - 103x for the HBR samples and 303 - 564x for the UHR samples.

![alt text](<screenshots/Screenshot 2026-11-05 at 9.43.49 AM-1.png>)

### 5. Can you identify the transcripts that are expressed? Sometimes you can only exclude some candidates.

The transcripts that are expressed have read coverage over their exons. Regions with no coverage are not detected as expressed, so transcripts with no reads on their unique exons can be excluded.

### 6. Can you find a gene/transcript where the expression is clearly different between the two sample types? What is the fold change?

YWHAH is differentially expressed between HBR and UHR with 109 - 157x and 26 - 45x coverage (~3-4x higher in HBR) respectively despite the UHR sample coverage being overall higher than HBR

![alt text](<screenshots/Screenshot 2026-11-05 at 9.48.45 AM.png>)

### 7. Is the transcript upregulated or downregulated?

Depending on what the samples are, the YWHAH transcript can be upregulated or downregulated. For example, if the HBR samples are the control, then the UHR YWHAH transcript is downregulated, but if the UHR is the control, then the HBR samples are upregulated.

### 8. How certain are you that it is not a random fluctuation? Why?

I believe this is not due to random fluctuation since the replicates are fairly similar to one another. To be more certain of this, statistical tests need to be conducted by using tools such as DESeq2.