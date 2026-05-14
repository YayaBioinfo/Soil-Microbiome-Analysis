#!/bin/bash
# ============================================================
# STEP 8: Export for Downstream Analysis (R/phyloseq)
# ============================================================

# Export QIIME2 artifacts
qiime tools export --input-path asv-table.qza --output-path exported/
qiime tools export --input-path taxonomy.qza --output-path exported/
qiime tools export --input-path rooted-tree.qza --output-path exported/

# Add taxonomy metadata to BIOM table
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
