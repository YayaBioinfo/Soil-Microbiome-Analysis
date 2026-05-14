# ============================================================
# STEP 3: Rarefaction Curves (iNEXT)
# ============================================================

library(phyloseq)
library(iNEXT)
library(ggplot2)

# Extract OTU table
otu <- as(otu_table(physeqfull), "matrix")
if (!taxa_are_rows(physeqfull)) otu <- t(otu)

# Extract sample metadata
metadata <- data.frame(sample_data(physeqfull))

# Define grouping variable
group_var <- metadata$sample_id
names(group_var) <- rownames(metadata)

# Aggregate OTUs by group
otu <- otu[, rownames(metadata)]
group_names <- unique(group_var)

otu_grouped <- sapply(group_names, function(g) {
  samples_in_group <- names(group_var)[group_var == g]
  if (length(samples_in_group) == 1) {
    otu[, samples_in_group]
  } else {
    rowSums(otu[, samples_in_group])
  }
})
otu_grouped <- as.matrix(otu_grouped)

# Prepare iNEXT input list
otu_list <- lapply(1:ncol(otu_grouped), function(i) as.numeric(otu_grouped[, i]))
names(otu_list) <- colnames(otu_grouped)

# Run iNEXT rarefaction
out <- iNEXT(otu_list, q = 0, datatype = "abundance")

# Plot rarefaction curves
p1 <- ggiNEXT(out, type = 1)
p1
