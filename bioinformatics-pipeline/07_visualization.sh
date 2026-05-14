#!/bin/bash
# ============================================================
# STEP 7: Visualization & Diversity Analysis
# ============================================================
# Set --p-sampling-depth based on minimum sample read depth
# Samples below this threshold will be excluded

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

# Core metrics (phylogenetic)
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table asv-table.qza \
  --p-sampling-depth 2000 \
  --m-metadata-file metadata.tsv \
  --output-dir core-metrics-results
