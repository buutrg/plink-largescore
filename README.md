What this updates: https://zzz.bwh.harvard.edu/plink/

Main methods paper: https://academic.oup.com/gigascience/article/4/1/s13742-015-0047-8/2707533

PLINK 1.9 and 2.0 user documentation: https://www.cog-genomics.org/plink/1.9/ , https://www.cog-genomics.org/plink/2.0/

Technical support forum: https://groups.google.com/g/plink2-users

The 1.9/ implementation can typically be used as a drop-in replacement for PLINK 1.07 that scales to much larger datasets.  It's technically still a beta version because there are a few rarely-used but possibly-worthwhile PLINK 1.07 commands that are still absent, but active feature development for it ended in 2016.

The 2.0/ implementation is designed to handle VCF files and dosage data, and is under active development.  Most basic features other than non-concatenating merge are now in place.  See its README.md for more details.

## Sparse Matrix Scoring Feature

This repository includes an enhanced version of PLINK2 with **sparse matrix scoring** capability for efficient polygenic risk score (PRS) calculation. This feature allows scoring using Matrix Market format sparse matrices, dramatically reducing memory usage and file sizes when most SNP effect sizes are zero.

### Key Features

- **Sparse Matrix Format**: Uses Matrix Market coordinate format to store only non-zero effect sizes
- **Index-Based Storage**: In-memory index representation (no temporary files)
- **Direct Sparse Multiplication**: Efficient sparse matrix operations during scoring
- **Massive Performance Gains**: Up to 36× faster runtime and 19-22× file size reduction for large-scale PRS

### Quick Start

Build the sparse matrix-enabled executable:

```bash
cd 2.0
make plinkSparse
```

Use sparse matrix scoring:

```bash
plinkSparse --bfile <data> \
            --score <scores.mm> sparse-matrix \
            --score-snp-map <snp_map.txt> \
            --score-score-map <score_map.txt> \
            --out <output>
```

### Documentation

For detailed documentation, examples, and benchmark results, see:
- [Sparse Matrix Scoring README](examples/test_sparse_matrix/README.md)

### Benchmark Results

Large-scale benchmark (2M SNPs, 500K non-zero effects, 10 scores):
- **Runtime**: 36× faster than traditional method (17s vs 617s)
- **File Size**: 19.6× smaller (8.13 MB vs 159.35 MB)
- **Memory**: 2.28 GB (27% overhead, acceptable given speedup)

### File Formats

- **Matrix Market (.mm)**: Sparse matrix with non-zero effect sizes
- **SNP Map**: Maps row indices to variant IDs and alleles
- **Score Map**: Maps column indices to score names

See the [documentation](examples/test_sparse_matrix/README.md) for detailed format specifications and examples.
