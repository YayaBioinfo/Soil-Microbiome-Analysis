# Soil-Microbiome-Profiling

End-to-end pipeline for **16S rRNA amplicon-based microbiome analysis** of rhizosphere soil, from raw sequencing reads through community ecology analysis in R.

---

## Project Overview

This pipeline characterizes the **rhizosphere microbiome diversity and composition** of wild banana using paired-end 16S amplicon sequencing. The workflow is divided into two parts:

- **Part 1 (QIIME2):** Quality control, denoising, taxonomy assignment, and phylogenetic tree construction
- **Part 2 (R/phyloseq):** Data import, rarefaction analysis, chloroplast filtering, and community analysis

```
Raw FASTQ reads
      │
      ▼
[fastp / FastQC]         ← Quality control & trimming
      │
      ▼
[QIIME2 — DADA2/Deblur] ← Denoising → ASV table
      │
      ▼
[SILVA 138 classifier]   ← Taxonomy assignment
      │
      ▼
[MAFFT + FastTree]       ← Phylogenetic tree
      │
      ▼
[Export: BIOM + Newick]
      │
      ▼
[R — phyloseq / iNEXT]   ← Diversity & community analysis
```

---

## Part 1: QIIME2 Amplicon Pipeline

### Requirements

```bash
conda env create -n qiime2-amplicon-2024.5 \
  --file https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py39-Approx-linux-conda.yml

conda activate qiime2-amplicon-2024.5
```

Additional tools: `fastp`, `fastqc`

---

### Step 1 — Import Data

**Metadata manifest format** (tab-separated):

```
sample-id    forward-absolute-filepath    reverse-absolute-filepath
```

```bash
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path pe-33-manifest \
  --output-path demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv
```

---

### Step 2 — Quality Control

```bash
# Adapter trimming
fastp \
  -i R1.fastq.gz -I R2.fastq.gz \
  -o R1_trimmed.fq.gz -O R2_trimmed.fq.gz

# Quality assessment
fastqc raw/*.fastq.gz -o fastqc_output/
```

---

### Step 3 — Denoising

Two options are supported. Choose based on your data:

**Option A — DADA2** (recommended for most datasets):

```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left-f 0 \
  --p-trunc-len-f 250 \
  --p-trim-left-r 0 \
  --p-trunc-len-r 250 \
  --o-representative-sequences asv-seqs.qza \
  --o-table asv-table.qza \
  --o-denoising-stats stats.qza
```

> Set `--p-trunc-len` based on quality drop visible in `demux.qzv`.

**Option B — Deblur:**

```bash
qiime deblur denoise-16S \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-length 245 \
  --p-min-reads 1 \
  --p-min-size 1 \
  --p-sample-stats \
  --o-representative-sequences deblur/rep-seqs.qza \
  --o-table deblur/table.qza \
  --o-stats deblur/deblur-stats.qza

qiime deblur visualize-stats \
  --i-deblur-stats deblur/deblur-stats.qza \
  --o-visualization deblur-stats.qzv
```

---

### Step 4 — Taxonomy Assignment

**Train amplicon-specific classifier** from SILVA 138 (region 515F–806R):

```bash
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ~/Database/silva-138-99-seqs-515-806.qza \
  --i-reference-taxonomy ~/Database/silva-138-99-tax-515-806.qza \
  --o-classifier ~/Database/silva-138-99-515-806-classifier.qza
```

> Pre-trained classifiers for common primer sets are available at https://resources.qiime2.org

**Classify ASV sequences:**

```bash
qiime feature-classifier classify-sklearn \
  --i-classifier ~/Database/silva-138-99-515-806-classifier.qza \
  --i-reads asv-seqs.qza \
  --o-classification taxonomy.qza
```

---

### Step 5 — Phylogenetic Analysis

```bash
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences asv-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
```

---

### Step 6 — Diversity & Visualization

```bash
# Taxa bar plot
qiime taxa barplot \
  --i-table asv-table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization taxa-bar-plots.qzv

# Alpha rarefaction
qiime diversity alpha-rarefaction \
  --i-table asv-table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 2000 \
  --m-metadata-file metadata.tsv \
  --o-visualization alpha-rarefaction.qzv

# Core metrics
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table asv-table.qza \
  --p-sampling-depth 2000 \
  --m-metadata-file metadata.tsv \
  --output-dir core-metrics-results
```

> Set `--p-sampling-depth` based on minimum sample read depth. Samples below this threshold will be excluded.

---

### Step 7 — Export for R

```bash
# Export artifacts
qiime tools export --input-path asv-table.qza --output-path exported/
qiime tools export --input-path taxonomy.qza --output-path exported/
qiime tools export --input-path rooted-tree.qza --output-path exported/

# Add taxonomy to BIOM
biom add-metadata \
  -i exported/feature-table.biom \
  -o exported/table-with-taxonomy.biom \
  --observation-metadata-fp exported/taxonomy.tsv \
  --sc-separated taxonomy

# Convert to TSV
biom convert \
  -i exported/table-with-taxonomy.biom \
  -o exported/table-with-taxonomy.txt \
  --to-tsv --header-key taxonomy

# Convert to JSON BIOM (phyloseq-compatible)
biom convert \
  -i exported/table-with-taxonomy.txt \
  -o exported/table-with-taxonomy_json.biom \
  --table-type="OTU table" --to-json
```

**Files needed for R (next section):**

| File | Description |
|------|-------------|
| `table-with-taxonomy_json.biom` | ASV table with taxonomy |
| `tree.nwk` | Exported rooted phylogenetic tree |
| `metadata.tsv` | Sample metadata |

---

## Part 2: R — Community Analysis (phyloseq)

### Requirements

```r
install.packages(c("phyloseq", "ape", "iNEXT", "ggplot2", "stringr", "dplyr"))
```

---

### Step 1 — Import BIOM Table

```r
library(phyloseq)
library(ape)

# Custom taxonomy parser for QIIME2 format
parse_taxonomy_qiime <- function(char.vec) {
  parse_taxonomy_default(strsplit(char.vec, ";", TRUE)[[1]])
}

# Import BIOM table
Biom_table <- import_biom(
  "table-with-taxonomy_json.biom",
  refseqArgs = NULL,
  parseFunction = parse_taxonomy_qiime,
  parallel = FALSE
)

# Inspect data
class(Biom_table)
Biom_table@otu_table[1:5, ]
Biom_table@tax_table[1:5, ]
sample_names(Biom_table)
```

---

### Step 2 — Import Phylogenetic Tree

```r
# Import Newick tree exported from QIIME2
tree <- read_tree("tree.nwk")

# Verify tree is rooted (required for UniFrac metrics)
is.rooted(phy_tree(tree))

summary(tree)
```

---

### Step 3 — Rarefaction Curves (iNEXT)

Rarefaction curves are used to assess whether sequencing depth is sufficient to capture the rhizosphere microbial diversity in each sample.

```r
library(iNEXT)
library(ggplot2)

# Extract OTU table
otu <- as(otu_table(physeqfull), "matrix")
if (!taxa_are_rows(physeqfull)) otu <- t(otu)

# Extract sample metadata
metadata <- data.frame(sample_data(physeqfull))

# Define grouping variable
group_var <- metadata$sample_id
names(group_var) <- rownames(metadata)

# Aggregate OTUs by group
otu <- otu[, rownames(metadata)]
group_names <- unique(group_var)

otu_grouped <- sapply(group_names, function(g) {
  samples_in_group <- names(group_var)[group_var == g]
  if (length(samples_in_group) == 1) {
    otu[, samples_in_group]
  } else {
    rowSums(otu[, samples_in_group])
  }
})
otu_grouped <- as.matrix(otu_grouped)

# Prepare iNEXT input list
otu_list <- lapply(1:ncol(otu_grouped), function(i) as.numeric(otu_grouped[, i]))
names(otu_list) <- colnames(otu_grouped)

# Run iNEXT rarefaction
out <- iNEXT(otu_list, q = 0, datatype = "abundance")

# Plot
p1 <- ggiNEXT(out, type = 1)
p1
```

---

### Step 4 — Chloroplast Filtering

Rhizosphere samples from plant roots commonly contain **chloroplast-derived 16S sequences** (plant plastid contamination). These must be removed before microbial community analysis.

```r
library(stringr)
library(dplyr)
library(phyloseq)

# Inspect chloroplast taxa
physeqfull_chloroplast <- subset_taxa(physeqfull, Rank4 == "o__Chloroplast")
tax_table(physeqfull_chloroplast)

# Remove chloroplast taxa
physeqfull_no_chloroplast <- subset_taxa(
  physeqfull,
  Rank4 != "o__Chloroplast" | is.na(Rank4)
)

# Remove taxa with zero counts after filtering
physeqfull_no_chloroplast2 <- prune_taxa(
  taxa_sums(physeqfull_no_chloroplast) > 0,
  physeqfull_no_chloroplast
)

# Compare taxa counts before and after pruning
summary(taxa_sums(physeqfull_no_chloroplast))
summary(taxa_sums(physeqfull_no_chloroplast2))
```

> `physeqfull_no_chloroplast2` is the **clean phyloseq object** to use for all downstream analyses (diversity, ordination, differential abundance, etc.).

---

## Output Summary

| File / Object | Format | Description |
|------|--------|-------------|
| `asv-table.qza` | QIIME2 artifact | Raw ASV feature table |
| `taxonomy.qza` | QIIME2 artifact | SILVA taxonomic classifications |
| `rooted-tree.qza` | QIIME2 artifact | Rooted phylogenetic tree |
| `table-with-taxonomy_json.biom` | BIOM JSON | ASV table with taxonomy for R |
| `core-metrics-results/` | Directory | Alpha & beta diversity outputs |
| `physeqfull` | R object (phyloseq) | Merged phyloseq object |
| `physeqfull_no_chloroplast2` | R object (phyloseq) | Filtered phyloseq object (analysis-ready) |

---

## Citation

If you use this pipeline, please cite:

- **QIIME2**: Bolyen et al. *Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2.* Nature Biotechnology, 2019. https://doi.org/10.1038/s41587-019-0209-9
- **DADA2**: Callahan et al. *DADA2: High-resolution sample inference from Illumina amplicon data.* Nature Methods, 2016. https://doi.org/10.1038/nmeth.3869
- **Deblur**: Amir et al. *Deblur Rapidly Resolves Single-Nucleotide Community Sequence Patterns.* mSystems, 2017. https://doi.org/10.1128/mSystems.00191-16
- **phyloseq**: McMurdie & Holmes. *phyloseq: An R Package for Reproducible Interactive Analysis and Graphics of Microbiome Census Data.* PLoS ONE, 2013. https://doi.org/10.1371/journal.pone.0061217
- **iNEXT**: Hsieh et al. *iNEXT: an R package for rarefaction and extrapolation of species diversity (Hill numbers).* Methods in Ecology and Evolution, 2016. https://doi.org/10.1111/2041-210X.12613
- **SILVA**: Quast et al. *The SILVA ribosomal RNA gene database project.* Nucleic Acids Research, 2013. https://doi.org/10.1093/nar/gks1219
- **fastp**: Chen et al. *fastp: an ultra-fast all-in-one FASTQ preprocessor.* Bioinformatics, 2018. https://doi.org/10.1093/bioinformatics/bty560

---

## License

MIT License. See `LICENSE` for details.
