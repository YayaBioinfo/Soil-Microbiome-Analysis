#!/bin/bash
# ============================================================
# STEP 1: Environment Setup
# ============================================================

conda env create -n qiime2-amplicon-2024.5 \
  --file https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py39-Approx-linux-conda.yml

conda activate qiime2-amplicon-2024.5
