# BMMB852 Assignment 1

I used VSC

## Samtools versions

### Commands

```bash
conda activate bioinfo
samtools --version
```
#### Output:

kenny@MacBook-Pro ~/BMMB852/assignment1/README.md
$ samtools --version
samtools 1.24
Using htslib 1.24

## Nested Directory

Check where you are

```bash
ls
```

### make directory

```bash
mkdir BMMB852
```
### Directory in a directory (nested)

```bash
cd BMMB852
mkdir assignment1
cd assignment1
mkdir README.md
cd README.md
```

## making files in different directories
### commands to create empty files

```bash
cd ~/assignment1
mkdir -p data/raw results scripts
touch data/raw/input.txt
touch results/output.txt
touch scriptsanalyze.sh
```
   
### Commands to create files with content

```bash
echo "input data" > data/raw/input.txt
echo "results" > results/output.txt
echo '#!bin/bash' > scripts/analyze.sh
```

### Verify files

```bash
find . -type f
```

Output:
kenny@MacBook-Pro ~/BMMB852/assignment1/README.md
$ find . -type f
./README.md
./results/output.txt
./scripts/analyze.sh
./README.txt


## Accessing these files using relative paths

```bash
cd ~/assignment1
```
   
### These are relative since they start from my current directory; assignment 1

```bash
cat data/raw/input.txt
cat results/output.txt
cat scripts/analyze.sh
```

Confirm where you are

```bash
pwd
```
Move between directories using relative paths (data for example)

```bash
cd data
cd raw
```

#### go back to README.md

```bash
cd ../..
```

## Accessing files using absolute paths

Move up directories
   
```bash
cd ../../../..
```
### Absolute path

```bash
cat /Users/kenny/BMMB852/assignment1/README.md/data/raw/input.txt
cat /Users/kenny/BMMB852/assignment1/README.md/results/output.txt
cat /Users/kenny/BMMB852/assignment1/README.md/scripts/analyze.sh
```

Check location

```bash
pwd
```
