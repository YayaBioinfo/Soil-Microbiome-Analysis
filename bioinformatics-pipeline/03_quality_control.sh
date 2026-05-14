#!/bin/bash
# ============================================================
# STEP 3: Quality Control
# ============================================================

# Trim adapters with fastp
fastp \
  -i R1.fastq.gz -I R2.fastq.gz \
  -o R1_trimmed.fq.gz -O R2_trimmed.fq.gz

# Quality assessment with FastQC
fastqc raw/*.fastq.gz -o fastqc_output/
