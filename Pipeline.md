# QIIME2 Amplicon Sequencing Pipeline

Pipeline for **paired-end amplicon sequencing** analysis using **QIIME2**, including preprocessing with **fastp**, denoising with **DADA2 / Deblur**, classifier creation, phylogenetic analysis, taxa visualization, and data export for downstream analysis in R.

---

## 1️⃣ Environment Setup

### 📌 Create QIIME2 Environment
```bash
conda env create -n qiime2-amplicon-2024.5 \
  --file https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py39-Approx-linux-conda.yml
````

### 📌 Activate Environment

```bash
conda activate qiime2-amplicon-2024.5
```


## 2️⃣ Prepare Metadata and Import Data

### 📌 Metadata Format

* Three columns with **tab-separated** values:
  `sample-id    forward-absolute-filepath    reverse-absolute-filepath`

### 📌 Import Paired-End Data

```bash
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path pe-33-manifest-46S-v2 \
  --output-path demux.qza \
  --input-format PairedEndFastqManifestPhred33V2
```

### 📌 Visualize Demultiplexed Sequences

```bash
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
```

---

## 3️⃣ Quality Control

### 📌 Trim and Filter Reads with fastp

```bash
fastp -i R1.fastq.gz -I R2.fastq.gz -o R1_trimmed.fq.gz -O R2_trimmed.fq.gz
```

### 📌 Quality Check with FastQC

```bash
fastqc raw/*fastq.gz -o fastqc_output/
```

---

## 4️⃣ Denoising Sequencing Data

### 📌 Using DADA2

```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left-f 0 --p-trunc-len-f 250 \
  --p-trim-left-r 0 --p-trunc-len-r 250 \
  --o-representative-sequences asv-seqs.qza \
  --o-table asv-table.qza \
  --o-denoising-stats stats.qza
```

> Truncation length (`250`) determined from quality distribution in `demux.qzv`.

### 📌 Using Deblur

```bash
qiime deblur denoise-16S \
  --i-demultiplexed-seqs demux.qza \
  --p-min-reads 1 --p-min-size 1 --p-trim-length 245 \
  --o-representative-sequences deblur/rep-seqs.qza \
  --o-table deblur/table.qza \
  --p-sample-stats --o-stats deblur/deblur-stats.qza
```

### 📌 Visualize Deblur Stats

```bash
qiime deblur visualize-stats \
  --i-deblur-stats deblur/deblur-stats.qza \
  --o-visualization deblur-stats.qzv
```

---

## 5️⃣ Classifier and Taxonomy Assignment

### 📌 Train Amplicon-Specific Classifier

```bash
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ~/Database/silva-138-99-seqs-515-806.qza \
  --i-reference-taxonomy ~/Database/silva-138-99-tax-515-806.qza \
  --o-classifier ~/Database/silva-138-99-515-806-classifier.qza
```

### 📌 Classify Sequences

```bash
qiime feature-classifier classify-sklearn \
  --i-classifier ~/Database/silva-138-99-515-806-classifier.qza \
  --i-reads asv-seqs.qza \
  --o-classification taxonomy.qza
```

---

## 6️⃣ Phylogenetic Analysis

### 📌 Alignment and Tree Construction

```bash
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences asv-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
```

---

## 7️⃣ Visualization

### 📌 Taxa Bar Plot

```bash
qiime taxa barplot \
  --i-table asv-table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file metadata1.tsv \
  --o-visualization taxa-bar-plots.qzv
```

### 📌 Alpha Rarefaction

```bash
qiime diversity alpha-rarefaction \
  --i-table asv-table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 2000 \
  --m-metadata-file metadata1.tsv \
  --o-visualization alpha-rarefaction.qzv
```

### 📌 Core Metrics Phylogenetic

```bash
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table asv-table.qza \
  --p-sampling-depth 2000 \
  --m-metadata-file metadata1.tsv \
  --output-dir core-metrics-results
```

---

## 8️⃣ Export for Downstream Analysis

```bash
qiime tools export --input-path asv-table.qza --output-path exported/
qiime tools export --input-path taxonomy.qza --output-path exported/
qiime tools export --input-path rooted-tree.qza --output-path exported/
biom add-metadata -i feature-table.biom -o table-with-taxonomy.biom \
  --observation-metadata-fp biom-taxonomy.tsv --sc-separated taxonomy
biom convert -i table-with-taxonomy.biom -o table-with-taxonomy.txt --to-tsv --header-key taxonomy
biom convert -i table-with-taxonomy.txt -o table-with-taxonomy_json.biom --table-type="OTU table" --to-json
```



```
```
