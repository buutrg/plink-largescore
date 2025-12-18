# Sparse Matrix Score Testing

This directory contains test scripts and example files for testing the sparse matrix functionality in plinkSparse.

## Files

- `test_sparse_matrix.sh` - Main test script
- `example_sparse_matrix_scores.mm` - Matrix Market format sparse matrix
- `example_sparse_matrix_scores.txt` - PLINK2 format sparse matrix (for comparison)
- `example_snp_map.txt` - SNP mapping file (row index -> variant_id allele)
- `example_score_map.txt` - Score mapping file (col index -> score_name)
- `mm_to_plink_score.py` - Converter script (for reference)

## Building plinkSparse

Before running tests, you need to build plinkSparse:

```bash
cd ../../2.0
make plinkSparse
```

**Note:** The build may require:
- zlib development headers
- BLAS/LAPACK libraries (openblas, lapack, etc.)
- Compatible GLIBC version

If you encounter linking issues, try:
- Using system libraries instead of conda libraries
- Installing required development packages
- Building in a different environment

## Running Tests

### Basic Test (requires data files)

```bash
./test_sparse_matrix.sh
```

The script will:
1. Test sparse-matrix option with Matrix Market format
2. Test sparse-matrix with mappings in MM file comments
3. Compare results with traditional PLINK2 format
4. Verify help text includes sparse-matrix option

### Test with 1000 Genomes Data

The test script is configured to use data at:
```
/n/holylfs05/LABS/liang_lab/Lab/btruong/Tools/g1000_eur
```

If your data is at a different location, edit `test_sparse_matrix.sh` and update the `DATA_PREFIX` variable.

## Expected Output

The test will create output files in `test_output/`:
- `test1_sparse_mm.sscore` - Results from sparse-matrix with separate mapping files
- `test2_sparse_mm_comments.sscore` - Results from sparse-matrix with mappings in comments
- `test3_traditional.sscore` - Results from traditional PLINK2 format (for comparison)

## Example Usage

### Using sparse-matrix with separate mapping files:

```bash
plinkSparse --bfile data \
            --score scores.mm sparse-matrix \
            --score-snp-map snp_map.txt \
            --score-score-map score_map.txt \
            --score-col-nums 3-6 \
            header-read \
            --out output
```

### Using sparse-matrix with mappings in MM file comments:

```bash
plinkSparse --bfile data \
            --score scores.mm sparse-matrix \
            --score-col-nums 3-6 \
            header-read \
            --out output
```

## Troubleshooting

1. **Build fails with zlib errors**: Try using system zlib or installing zlib-devel
2. **Build fails with BLAS/LAPACK errors**: Install openblas-devel and lapack-devel
3. **GLIBC version errors**: Build in an environment with compatible GLIBC version
4. **Test fails with "data files not found"**: Update DATA_PREFIX in test script

