#!/bin/bash
# ============================================================
# STEP 2: Import Paired-End Data
# ============================================================
# Metadata format (tab-separated):
# sample-id    forward-absolute-filepath    reverse-absolute-filepath

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path pe-33-manifest \
  --output-path demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv
