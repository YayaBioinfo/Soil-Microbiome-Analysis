# ============================================================
# STEP 1: Import BIOM Table from QIIME2
# ============================================================

library(phyloseq)
library(ape)

# Parse taxonomy from QIIME2 BIOM format
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
str(Biom_table)

# View headers
Biom_table@otu_table[1:5, ]
Biom_table@tax_table[1:5, ]
sample_names(Biom_table)
