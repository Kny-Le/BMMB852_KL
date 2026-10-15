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

![alt text](<Screenshot 2026-10-15 at 12.03.52 PM.png>)

Contig 20:

![alt text](<Screenshot 2026-10-15 at 12.07.40 PM.png>)

Contig 40:

![alt text](<Screenshot 2026-10-15 at 12.09.16 PM.png>)

You get the idea, there was very little variation between patient samples. However on contig 31:

![alt text](<Screenshot 2026-10-15 at 12.10.50 PM.png>)

Sample 1:

![alt text](<Screenshot 2026-10-15 at 12.43.37 PM.png>)

Sample 2:

![alt text](<Screenshot 2026-10-15 at 12.42.57 PM.png>)

Sample 3:

![alt text](<Screenshot 2026-10-15 at 12.41.31 PM.png>)

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

![alt text](<Screenshot 2026-10-15 at 1.27.15 PM.png>)


These variants mapped to J7I61_RS07895, the 16s ribosomal RNA (16S rRNA) gene, which is a stretch of DNA in the H. pylori genome. Bacteria use this to make 16s rRNA as a structural component of the small subunit of bacterial ribosomes, which make proteins. According to the snpeff summary, there are 51 SNPS.