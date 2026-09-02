[README.md](https://github.com/user-attachments/files/31747533/README.md)
# BMMB852 Assignment 1

## Samtools versions

```bash
conda activate bioinfo
samtools --version
```

kenny@MacBook-Pro ~/BMMB852/assignment1/README.md
$ samtools --version
samtools 1.24
Using htslib 1.24

## nested directory

### check where you are

```bash
ls
```

### make directory

```bash
mkdir BMMB852
```
### directory in a directory (nested)

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

### create files with content

```bash
echo "input data" > data/raw/input.txt
echo "results" > results/output.txt
echo '#!bin/bash' > scripts/analyze.sh
```

### verify

```bash
find . -type f
```

## accessing these files using relative paths

```bash
cd ~/assignment1
```

### these are relative since they start from my current directory; assignment 1

```bash
cat data/raw/input.txt
cat results/output.txt
cat scripts/analyze.sh
```

###confirm where you are

```bash
pwd
```
###move between directories using relative paths (data for example)

```bash
cd data
cd raw
#### go back to README.md
cd ../..
```

##accessing files using absolute paths

### move up directories

```bash
cd ../../../..
```
### absolute path

'''bash
cat /Users/kenny/BMMB852/assignment1/README.md/data/raw/input.txt
cat /Users/kenny/BMMB852/assignment1/README.md/results/output.txt
cat /Users/kenny/BMMB852/assignment1/README.md/scripts/analyze.sh
```

### check location

```bash
pwd
```
