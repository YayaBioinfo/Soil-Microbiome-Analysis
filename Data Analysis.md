Pipeline for **microbiome analysis whith phyloseq**, including data import from QIIME2, tree import, rarefaction curves with iNEXT, and chloroplast filtering.

---

## 1️⃣ Import Biom Table

```r
# Load libraries
library(phyloseq)
library(ape)

# Parse taxonomy from biom
parse_taxonomy_qiime <- function(char.vec) {
  parse_taxonomy_default(strsplit(char.vec, ";", TRUE)[[1]])
}

# Import biom table from QIIME2
Biom_table <- import_biom(
  "table-with-taxonomy_json.biom",
  refseqArgs = NULL,
  parseFunction = parse_taxonomy_qiime,
  parallel = FALSE
)

# Check data
class(Biom_table)
str(Biom_table)

# View headers
Biom_table@otu_table[1:5,]
Biom_table@tax_table[1:5,]

sample_names(Biom_table)
````

---

## 2️⃣ Import Phylogenetic Tree

```r
# Import tree
tree <- read_tree("tree.nwk")

# Check if tree is rooted
is.rooted(phy_tree(tree))

# Summary
summary(tree)
```

---

## 3️⃣ Rarefaction Curves

```r
# Extract OTU table
otu <- as(otu_table(physeqfull), "matrix")
if (!taxa_are_rows(physeqfull)) otu <- t(otu)

# Extract sample metadata
metadata <- data.frame(sample_data(physeqfull))

# Define group variable
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

# Prepare iNEXT input
otu_list <- lapply(1:ncol(otu_grouped), function(i) as.numeric(otu_grouped[, i]))
names(otu_list) <- colnames(otu_grouped)

# Run iNEXT
library(iNEXT)
out <- iNEXT(otu_list, q = 0, datatype = "abundance")

# Plot rarefaction curves
p1 <- ggiNEXT(out, type = 1)
```

---

## 4️⃣ Filter Chloroplast

```r
library(stringr)
library(dplyr)
library(phyloseq)

# Subset chloroplast taxa
physeqfull_chloroplast <- subset_taxa(physeqfull, Rank4 == "o__Chloroplast")
tax_table(physeqfull_chloroplast)

# Remove chloroplast taxa
physeqfull_no_chloroplast <- subset_taxa(
  physeqfull, Rank4 != "o__Chloroplast" | is.na(Rank4)
)
physeqfull_no_chloroplast2 <- prune_taxa(
  taxa_sums(physeqfull_no_chloroplast) > 0,
  physeqfull_no_chloroplast
)

# Taxa summary
summary(taxa_sums(physeqfull_no_chloroplast))
summary(taxa_sums(physeqfull_no_chloroplast2))
```



Apakah mau aku buatkan versi itu juga?
```
