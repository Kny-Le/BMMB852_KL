# Assignment 13

## Set up

I copied the sample design and gene-level estimated counts from Week 12. I used edgeR and DESeq2 to compare UHR against the HBR reference group (3 replicates in each group)

Make a Makefile:

```bash
touch Makefile
```

run:

```bash
make data
```

## Differential gene expression

The [edgeR results](results/hbr_uhr/edger.csv) include 378 tested genes, 280 with FDR < 0.05; the [DESeq2 results](results/hbr_uhr/deseq2.csv) include 529 tested genes, 260 with FDR < 0.05. The methods used different low-count filters and did not apply transcript-length corrections. The scripts replace unavailable p-values or FDR values with 1 in the output.

## Before running Rscript, install R and the required packages:

```r
install.packages("optparse")
install.packages("BiocManager")
BiocManager::install(c("DESeq2", "edgeR"))
```

From the Week13 directory, run:

```sh
Rscript src/prepare_counts.R
Rscript src/edger.r -c results/hbr_uhr/gene_counts.csv -d design.csv -o results/hbr_uhr/edger.csv
Rscript src/deseq2.r -c results/hbr_uhr/gene_counts.csv -d design.csv -o results/hbr_uhr/deseq2.csv
```

## Airway dataset

A separate airway dataset was analyzed using its own [sample design](results/airway/design.csv) and [gene counts](results/airway/gene_counts.csv). edgeR identified 1,161 significant genes among 12,752 tested, and DESeq2 identified 1,194 among 18,985 tested, at FDR < 0.05. See the [edgeR](results/airway/edger.csv) and [DESeq2](results/airway/deseq2.csv) results.

To perform the airway analysis, run:

```sh
Rscript src/edger.r -d results/airway/design.csv -c results/airway/gene_counts.csv -o results/airway/edger.csv
Rscript src/deseq2.r -d results/airway/design.csv -c results/airway/gene_counts.csv -o results/airway/deseq2.csv
```

Neither the HBR/UHR nor the airway dataset has an identified independent gene-level changed/unchanged truth file. True positive (TP), false positive (FP), true negative (TN), and false negative (FN) therefore cannot be determined for those datasets from these outputs alone.

## Simulated data and known states

A separate dataset was generated with PROPER using seed 84, low dispersion, 10,000 genes, and three replicates per group. Its [count matrix](results/simulation/simulated_counts.csv) contains the simulation's `status` and `filter` columns; its [design](results/simulation/simulated_design.csv) identifies groups A and B. The current simulation script reported 163 changed genes, where 132 passed its total-count filter. The previously provided simulation log reported 99 passing; despite matching the seed and other displayed settings, that older output differs from this run, potentially because of script or package version differences. These results apply to the newly generated data.

Both analyses were run on the simulated counts. The [edgeR results](results/simulation/edger.csv) and [DESeq2 results](results/simulation/deseq2.csv) retain the known `status` and include an `FDR` column. A separate [classification script](src/classify_simulation.R) compares these columns:

| Method | TP | FP | TN | FN | Tested | Changed genes excluded |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| edgeR | 46 | 4 | 2,097 | 54 | 2,201 | 63 |
| DESeq2 | 57 | 18 | 2,654 | 75 | 2,804 | 31 |

These counts cover only genes retained by each method, not all 10,000 simulated genes; the methods use different filters. Genes omitted by filtering are reported separately in the [summary](results/simulation/classification_summary.csv), not counted as TN or FN. The scripts replace unavailable p-values or FDR values with 1 and round FDR values in their exported tables, so classification uses those exported values rather than unrounded statistics. See the [classified edgeR](results/simulation/edger_classified.csv) and [classified DESeq2](results/simulation/deseq2_classified.csv) tables.

### Performance score

The formula below scores combined precision and recall into a single number:

$$
F1 = \frac{2TP}{2TP + FP + FN}
$$

The score ranges from 0 to 1, with higher values indicating better performance. It excludes TN, so the large number of unchanged genes does not dominate the score.

- **edgeR:** $92 / (92 + 4 + 54) = 0.613$
- **DESeq2:** $114 / (114 + 18 + 75) = 0.551$

These scores apply only to genes retained by each method. Because edgeR and DESeq2 filtered different genes, they are not a direct like-for-like comparison.

### Examples of false positives and false negatives

The following examples use normalized counts from the edgeR results, rounded to whole numbers. Each group has three replicates; DESeq2 uses slightly different normalization.

| Gene | Classification | Group A | Group B | Interpretation |
| --- | --- | --- | --- | --- |
| `GENE-7570` | FP in both methods | 303, 327, 373 | 821, 942, 708 | Although labeled unchanged by the simulation, all B replicates have much higher counts. Both methods called the apparent difference significant. |
| `GENE-4246` | FN in both methods | 17, 14, 18 | 6, 2, 5 | The gene was changed, and B has lower counts, but counts are low. After multiple-testing adjustment, FDR was 0.0797 in edgeR and 0.0869 in DESeq2, above the 0.05 cutoff. |
| `GENE-9584` | FN in both methods | 144, 1,220, 83 | 830, 91, 272 | Counts vary greatly among replicates within each group. This makes the group difference difficult to distinguish from variability; FDR was about 0.99 in both methods. |

These patterns help explain the decisions, though the exact p-values also depend on each method's statistical model and normalization. These IDs represent simulated genes, not real gene names.

To reproduce, install PROPER with `BiocManager::install("PROPER")`, then run:

```sh
mkdir -p results/simulation
Rscript src/simulate_counts.r -s 84 -d results/simulation/simulated_design.csv -o results/simulation/simulated_counts.csv
Rscript src/edger.r -c results/simulation/simulated_counts.csv -d results/simulation/simulated_design.csv -o results/simulation/edger.csv
Rscript src/deseq2.r -c results/simulation/simulated_counts.csv -d results/simulation/simulated_design.csv -o results/simulation/deseq2.csv
Rscript src/classify_simulation.R
```


