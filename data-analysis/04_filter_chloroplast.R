# ============================================================
# STEP 4: Chloroplast Filtering
# ============================================================
# Rhizosphere samples commonly contain chloroplast-derived 16S
# sequences from plant plastids. These must be removed before
# any diversity or community composition analysis.

library(phyloseq)
library(stringr)
library(dplyr)

# Inspect chloroplast taxa
physeqfull_chloroplast <- subset_taxa(physeqfull, Rank4 == "o__Chloroplast")
tax_table(physeqfull_chloroplast)

# Remove chloroplast taxa
physeqfull_no_chloroplast <- subset_taxa(
  physeqfull,
  Rank4 != "o__Chloroplast" | is.na(Rank4)
)

# Remove taxa with zero counts after filtering
physeqfull_no_chloroplast2 <- prune_taxa(
  taxa_sums(physeqfull_no_chloroplast) > 0,
  physeqfull_no_chloroplast
)

# Compare taxa counts before and after pruning
summary(taxa_sums(physeqfull_no_chloroplast))
summary(taxa_sums(physeqfull_no_chloroplast2))

# physeqfull_no_chloroplast2 is the clean object for downstream analysis
