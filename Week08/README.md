# Assignment 8

## Organism

This is Helicobacter pylori. This is a pathogenic bacterium that causes stomach ulcers. It is able to survive in the stomach acidic environment by secreting ammonia to neutralize the area around itself.

### SRX35545862: 16S sequence of human feces:H. pylori infected sample71

https://www.ncbi.nlm.nih.gov/sra/SRX35545862[accn]

PRJNA1538546

SRP742704 

SRR41018109

### 16S sequence of human feces:H. pylori infected sample70

https://www.ncbi.nlm.nih.gov/sra/SRX35545861[accn]

PRJNA1538546

SRP742704

SRR41018110

### 16S sequence of human feces:H. pylori infected sample78

https://www.ncbi.nlm.nih.gov/sra/SRX35545860[accn]

PRJNA1538546

SRP742704

SRR41018111

## Obtaining Files

make Makefile and paste contents of the makefile from this directory:

```bash
touch Makefile
```

Run:

```bash
make all
```

## Visualization via IGV

Miraculously, there were no variants detected in these patient stool samples infected with H. Pylori on any of the contigs...

Contig 1:

![IGV view of contig 1](screenshots/Screenshot%202026-10-15%20at%2012.03.52%E2%80%AFPM.png)

Contig 20:

![IGV view of contig 20](screenshots/Screenshot%202026-10-15%20at%2012.07.40%E2%80%AFPM.png)

Contig 40:

![IGV view of contig 40](screenshots/Screenshot%202026-10-15%20at%2012.09.16%E2%80%AFPM.png)

You get the idea, there was very little variation between patient samples. However on contig 31:

![IGV view of contig 31](screenshots/Screenshot%202026-10-15%20at%2012.10.50%E2%80%AFPM.png)

Sample 1:

![IGV view of sample 1](screenshots/Screenshot%202026-10-15%20at%2012.43.37%E2%80%AFPM.png)

Sample 2:

![IGV view of sample 2](screenshots/Screenshot%202026-10-15%20at%2012.42.57%E2%80%AFPM.png)

Sample 3:

![IGV view of sample 3](screenshots/Screenshot%202026-10-15%20at%2012.41.31%E2%80%AFPM.png)

Additional IGV views:

![Additional IGV view 1](screenshots/Screenshot%202026-10-15%20at%2012.15.58%E2%80%AFPM.png)

![Additional IGV view 2](screenshots/Screenshot%202026-10-15%20at%2012.17.03%E2%80%AFPM.png)

![Additional IGV view 3](screenshots/Screenshot%202026-10-15%20at%2012.17.49%E2%80%AFPM.png)

## Interpretation

Using SnpEff, first go to working folder and paste this into your terminal:

```bash
SNPEFF="$HOME/snpEff/snpEff.jar" &&
java -jar "$SNPEFF" build -c "$PWD/snpeff.config" -gff3 -noCheckCds -noCheckProtein -v HPyloriRef &&
for sample in HPylori1 HPylori2 HPylori3; do
    java -jar "$SNPEFF" ann -c "$PWD/snpeff.config" -v HPyloriRef \
        "vcf/$sample.vcf.gz" > "vcf/$sample.ann.vcf" || exit 1
done &&
java -jar "$SNPEFF" ann -c "$PWD/snpeff.config" -v HPyloriRef \
    vcf/HPylori.merged.vcf.gz > vcf/HPylori.merged.ann.vcf
```

Open summary:

```bash
open snpEff_summary.html
```

Output in snpeff_data.txt folder:

![SnpEff summary screenshot](screenshots/Screenshot%202026-10-15%20at%201.27.15%E2%80%AFPM.png)


These variants mapped to J7I61_RS07895, the 16s ribosomal RNA (16S rRNA) gene, which is a stretch of DNA in the H. pylori genome. Bacteria use this to make 16s rRNA as a structural component of the small subunit of bacterial ribosomes, which make proteins. According to the snpeff summary, there are 51 SNPS.