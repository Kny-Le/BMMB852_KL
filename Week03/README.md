# Assignment 3

Hairuo's assignment 2 submission is in this directory under "week02" for your convenience.

## Fork the code:

I am reviewing Hairuo Wang's Week 2 assignment where he visualized the reference genome for Schizosaccharomyces pombe.

```bash
git clone https://github.com/Kny-Le/appbio-KL.git
```

After forking, to check the reproducibility of the make file I removed the existing FASTA and gff files

```bash
rm -f data/fasta/GCF_000002945.2_ASM294v3_genomic.fna
rm -f data/gff/GCF_000002945.2_ASM294v3_genomic.gff
```
Run:

```bash
make
```

Output:

```bash
kenny@MacBook-Pro ~/BMMB852/Week03/week02
$ make
curl --fail --location "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/945/GCF_000002945.2_ASM294v3/GCF_000002945.2_ASM294v3_genomic.fna.gz" \
	| gzip -dc > "data/fasta/GCF_000002945.2_ASM294v3_genomic.fna.tmp"
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100  3.80M 100  3.80M   0      0  7.31M      0                              0
mv "data/fasta/GCF_000002945.2_ASM294v3_genomic.fna.tmp" "data/fasta/GCF_000002945.2_ASM294v3_genomic.fna"
curl --fail --location "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/945/GCF_000002945.2_ASM294v3/GCF_000002945.2_ASM294v3_genomic.gff.gz" \
	| gzip -dc > "data/gff/GCF_000002945.2_ASM294v3_genomic.gff.tmp"
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100  1.42M 100  1.42M   0      0  5.74M      0                              0
mv "data/gff/GCF_000002945.2_ASM294v3_genomic.gff.tmp" "data/gff/GCF_000002945.2_ASM294v3_genomic.gff"
(bioinfo) 
```

## Check reproducibility of the downstream code from the files created by Hairuo's Makefile

### How large is the genome?

Ran code from their "week02" file:

```bash
seqkit stats data/fasta/GCF_000002945.2_ASM294v3_genomic.fna
```

Output (pasted from my terminal):

```bash
file                                             format  type  num_seqs     sum_len  min_len      avg_len    max_len
data/fasta/GCF_000002945.2_ASM294v3_genomic.fna  FASTA   DNA          4  12,591,253   19,433  3,147,813.3  5,579,133
(bioinfo) 
```
### How many chromosomes does it have?

Ran code from their "week02" file:

```bash
grep -c '^>.*chromosome:' data/fasta/GCF_000002945.2_ASM294v3_genomic.fna
```

Output (pasted from my terminal):

```bash
3
```

## Questions from Assignment 3

The code is extremely reproducible. I after cloning Hairuo's forked file from their Github, I was able to achieve the same outputs from their commands. My AI agent (Visual Studio Code) said that their solution is better than mine, because theirs has more validation steps and is cleaner than mine. Although, I have a sneaking suspicion it says that since I have already loaded in Hairuo's code it has a preference for their code. That being said, there is not much I would change, except I would update the file names to be the organism's name instead of just the accession number. The .gff file is also not indexed, so I attached some code to get it indexed and applied it to the pull request (all suggestions made are put below).

### Suggestions to code:

### Command to change file names to include organism name for better readability:

```bash
mv data/fasta/GCF_000002945.2_ASM294v3_genomic.fna data/fasta/SPombe_genomic.fna
mv data/fasta/GCF_000002945.2_ASM294v3_genomic.fna.fai data/fasta/SPombe_genomic.fna.fai
mv data/gff/GCF_000002945.2_ASM294v3_genomic.gff data/gff/SPombe_genomic.gff
```

Resulting file names:

```bash
kenny@MacBook-Pro ~/BMMB852/Week03/week02/data
$ ls fasta
SPombe_genomic.fna     SPombe_genomic.fna.fai
(bioinfo) 

kenny@MacBook-Pro ~/BMMB852/Week03/week02/data
$ ls gff
SPombe_genomic.gff
(bioinfo) 
```

#### Index Files:

Command to index .gff (.gff to gff.gz):

```bash
bgzip -c data/gff/SPombe_genomic.gff > data/gff/SPombe_genomic.gff.gz
```

Output:

```bash
kenny@MacBook-Pro ~/BMMB852/Week03/week02/data/gff
$ ls
SPombe_genomic.gff    SPombe_genomic.gff.gz
(bioinfo) 
```

#### Pull request link

Copy link:

```bash
https://github.com/hairuow622/appbio/pull/1
```
