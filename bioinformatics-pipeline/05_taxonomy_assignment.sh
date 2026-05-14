#!/bin/bash
# ============================================================
# STEP 5: Taxonomy Assignment
# ============================================================
# Pre-trained classifiers available at: https://resources.qiime2.org

# Train amplicon-specific classifier from SILVA 138 (region 515F-806R)
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ~/Database/silva-138-99-seqs-515-806.qza \
  --i-reference-taxonomy ~/Database/silva-138-99-tax-515-806.qza \
  --o-classifier ~/Database/silva-138-99-515-806-classifier.qza

# Classify ASV sequences
qiime feature-classifier classify-sklearn \
  --i-classifier ~/Database/silva-138-99-515-806-classifier.qza \
  --i-reads asv-seqs.qza \
  --o-classification taxonomy.qza
