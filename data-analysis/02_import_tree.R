# ============================================================
# STEP 2: Import Phylogenetic Tree
# ============================================================

library(ape)

# Import Newick tree exported from QIIME2
tree <- read_tree("tree.nwk")

# Verify tree is rooted (required for UniFrac metrics)
is.rooted(phy_tree(tree))

# Summary
summary(tree)
