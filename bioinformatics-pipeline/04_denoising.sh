#!/bin/bash
# ============================================================
# STEP 4: Denoising
# ============================================================
# Choose ONE method: DADA2 (recommended) or Deblur
# Set truncation lengths based on quality distribution in demux.qzv

# --- Option A: DADA2 ---
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left-f 0 \
  --p-trunc-len-f 250 \
  --p-trim-left-r 0 \
  --p-trunc-len-r 250 \
  --o-representative-sequences asv-seqs.qza \
  --o-table asv-table.qza \
  --o-denoising-stats stats.qza

# --- Option B: Deblur ---
# qiime deblur denoise-16S \
#   --i-demultiplexed-seqs demux.qza \
#   --p-trim-length 245 \
#   --p-min-reads 1 \
#   --p-min-size 1 \
#   --p-sample-stats \
#   --o-representative-sequences deblur/rep-seqs.qza \
#   --o-table deblur/table.qza \
#   --o-stats deblur/deblur-stats.qza

# qiime deblur visualize-stats \
#   --i-deblur-stats deblur/deblur-stats.qza \
#   --o-visualization deblur-stats.qzv
