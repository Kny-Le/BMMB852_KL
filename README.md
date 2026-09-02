# BMMB852_KL
# README.md
# Week's Assignment

## 1 Create a directory and README.md file

### Commands

```bash
mkdir -p ~/assignment1
cd ~/assignment1
touch README.md
```

### What version is your samtools command in the bioinfo environment?

```bash
conda activate bioinfo
samtools --version
```

$ samtools --version
samtools 1.24
Using htslib 1.24
Copyright (C) 2026 Genome Research Ltd.

## Show commands needed to create a nested directory structure.

## Commands

```bash
mkdir -p data/raw results/scripts
```

## Show commands that create files in different directories

## commands

```bash
mkdir -p scripts
touch data/raw/input.txt
touch results/output.txt
touch scrips/analyze.sh
```

### create files with content

```bash
echo "input data" > data/raw/input.txt
echo "results" > results/output.txt
echo '#!bin/bash' > scripts/analyze.sh
```

### verify

'''bash
find . -type f
```

## Accessing these files using relative paths

```bash
cd ~/assignment1
```

### these are relative since they start from my current directory; assignment 1

```bash
cat data/raw/input.txt
cat results/output.txt
cat scripts/analyze.sh
```

### confirm where you are

```bash
pwd
```

### move between directories using relative paths (data for example)

```bash
cd data
cd raw
```

#### go back to README.md

```bash
cd ../..
```

## accessing files using absolute paths

### move up directories 

```bash
cd ../../../..
```

### absolute path

```bash
cat /Users/kenny/BMMB852/assignment1/README.md/data/raw/input.txt
cat /Users/kenny/BMMB852/assignment1/README.md/results/output.txt
cat /Users/kenny/BMMB852/assignment1/README.md/scripts/analyze.sh
```

### check location

```bash
pwd
```
