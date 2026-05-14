# 16S Amplicon Rhizobiome Pipeline

End-to-end pipeline for **16S rRNA amplicon-based rhizobiome analysis** of rhizosphere soil, from raw sequencing reads through community ecology analysis in R.

---

## Overview

This pipeline characterizes the rhizosphere microbiome diversity and composition of wild banana using paired-end 16S amplicon sequencing. The workflow is divided into two parts:

| Part | Tools | Description |
|------|-------|-------------|
| Bioinformatics | QIIME2, DADA2/Deblur, SILVA 138 | Quality control, denoising, taxonomy, phylogeny |
| Data Analysis | phyloseq, iNEXT | Community analysis, diversity, visualization |

```
Raw FASTQ reads
      │
      ▼
[fastp / FastQC]              ← Quality control & trimming
      │
      ▼
[QIIME2 — DADA2 / Deblur]    ← Denoising → ASV table
      │
      ▼
[SILVA 138 classifier]        ← Taxonomy assignment
      │
      ▼
[MAFFT + FastTree]            ← Phylogenetic tree construction
      │
      ▼
[Export: BIOM + Newick]
      │
      ▼
[R — phyloseq / iNEXT]        ← Diversity & community analysis
```

---

## Repository Structure

```
Soil-Microbiome-Analysis/
├── bioinformatics-pipeline/
│   ├── 01_setup_environment.sh
│   ├── 02_import_data.sh
│   ├── 03_quality_control.sh
│   ├── 04_denoising.sh
│   ├── 05_taxonomy_assignment.sh
│   ├── 06_phylogenetic_analysis.sh
│   ├── 07_visualization.sh
│   └── 08_export.sh
├── data-analysis/
│   ├── 01_import_biom.R
│   ├── 02_import_tree.R
│   ├── 03_rarefaction_curves.R
│   └── 04_filter_chloroplast.R
└── README.md
```

---

## Part 1: Bioinformatics Pipeline

Scripts located in `bioinformatics-pipeline/`. Run scripts sequentially from `01` to `08`.

### Requirements

```bash
conda env create -n qiime2-amplicon-2024.5 \
  --file https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py39-Approx-linux-conda.yml

conda activate qiime2-amplicon-2024.5
```

Additional tools: `fastp`, `fastqc`

### Steps

| Script | Step | Description |
|--------|------|-------------|
| `01_setup_environment.sh` | Environment | Create and activate QIIME2 conda environment |
| `02_import_data.sh` | Import | Import paired-end reads via manifest file |
| `03_quality_control.sh` | QC | Adapter trimming (fastp) and quality assessment (FastQC) |
| `04_denoising.sh` | Denoising | ASV generation via DADA2 (default) or Deblur |
| `05_taxonomy_assignment.sh` | Taxonomy | Train SILVA 138 classifier and assign taxonomy |
| `06_phylogenetic_analysis.sh` | Phylogeny | Multiple alignment (MAFFT) and tree construction (FastTree) |
| `07_visualization.sh` | Visualization | Taxa bar plots, alpha rarefaction, core diversity metrics |
| `08_export.sh` | Export | Export BIOM table, taxonomy, and tree for R |

> **Note:** Truncation lengths in `04_denoising.sh` should be adjusted based on the quality distribution visible in `demux.qzv`. Sampling depth in `07_visualization.sh` should be set based on minimum sample read depth.

> **Taxonomy classifier:** Pre-trained classifiers for common primer sets are available at https://resources.qiime2.org

---

## Part 2: Data Analysis (R)

Scripts located in `data-analysis/`. Requires output files from Part 1: `table-with-taxonomy_json.biom`, `tree.nwk`, and `metadata.tsv`.

### Requirements

```r
install.packages(c("phyloseq", "ape", "iNEXT", "ggplot2", "stringr", "dplyr"))
```

### Steps

| Script | Step | Description |
|--------|------|-------------|
| `01_import_biom.R` | Import | Load BIOM table with QIIME2 taxonomy into phyloseq |
| `02_import_tree.R` | Tree | Import rooted Newick tree; verify rooting for UniFrac |
| `03_rarefaction_curves.R` | Rarefaction | Assess sequencing depth adequacy per sample using iNEXT |
| `04_filter_chloroplast.R` | Filtering | Remove chloroplast-derived 16S sequences (plant plastid contamination) |

> **Note:** `physeqfull_no_chloroplast2` (output of `04_filter_chloroplast.R`) is the clean phyloseq object for all downstream analyses.

---

## Output Summary

| File / Object | Format | Description |
|------|--------|-------------|
| `asv-table.qza` | QIIME2 artifact | Raw ASV feature table |
| `taxonomy.qza` | QIIME2 artifact | SILVA taxonomic classifications |
| `rooted-tree.qza` | QIIME2 artifact | Rooted phylogenetic tree |
| `table-with-taxonomy_json.biom` | BIOM JSON | ASV table with taxonomy for R |
| `core-metrics-results/` | Directory | Alpha & beta diversity outputs |
| `physeqfull` | R object | Merged phyloseq object |
| `physeqfull_no_chloroplast2` | R object | Filtered phyloseq object (analysis-ready) |

---

## Citation

- **QIIME2**: Bolyen et al. Nature Biotechnology, 2019. https://doi.org/10.1038/s41587-019-0209-9
- **DADA2**: Callahan et al. Nature Methods, 2016. https://doi.org/10.1038/nmeth.3869
- **Deblur**: Amir et al. mSystems, 2017. https://doi.org/10.1128/mSystems.00191-16
- **phyloseq**: McMurdie & Holmes. PLoS ONE, 2013. https://doi.org/10.1371/journal.pone.0061217
- **iNEXT**: Hsieh et al. Methods in Ecology and Evolution, 2016. https://doi.org/10.1111/2041-210X.12613
- **SILVA**: Quast et al. Nucleic Acids Research, 2013. https://doi.org/10.1093/nar/gks1219
- **fastp**: Chen et al. Bioinformatics, 2018. https://doi.org/10.1093/bioinformatics/bty560

---

## License

MIT License. See `LICENSE` for details.
