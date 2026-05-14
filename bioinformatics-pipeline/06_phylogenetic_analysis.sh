#!/bin/bash
# ============================================================
# STEP 6: Phylogenetic Analysis
# ============================================================

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences asv-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
