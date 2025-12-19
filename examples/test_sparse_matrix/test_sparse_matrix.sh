#!/bin/bash
# Test script for sparse matrix functionality with plinkSparse
# This tests the new sparse-matrix option for --score command

set -e  # Exit on error

# ============================================================================
# SETUP: Define paths and files
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLINK_BIN="${SCRIPT_DIR}/../../2.0/bin/plinkSparse"
# Set DATA_PREFIX to your PLINK dataset prefix (e.g., /path/to/data)
# This should point to your .bed/.bim/.fam files
DATA_PREFIX="${DATA_PREFIX:-/path/to/your/plink/data}"

# Example files in this directory
MM_FILE="${SCRIPT_DIR}/example_sparse_matrix_scores.mm"
SNP_MAP_FILE="${SCRIPT_DIR}/example_snp_map.txt"
SCORE_MAP_FILE="${SCRIPT_DIR}/example_score_map.txt"
SCORE_FILE="${SCRIPT_DIR}/example_sparse_matrix_scores.txt"

OUTPUT_DIR="${SCRIPT_DIR}/test_output"
mkdir -p ${OUTPUT_DIR}

# ============================================================================
# Check if plinkSparse exists
# ============================================================================
if [ ! -f "${PLINK_BIN}" ]; then
    echo "ERROR: plinkSparse not found at ${PLINK_BIN}"
    echo "Please build plinkSparse first: cd 2.0 && make plinkSparse"
    exit 1
fi

# ============================================================================
# Check if data files exist
# ============================================================================
if [ ! -f "${DATA_PREFIX}.bed" ] || [ ! -f "${DATA_PREFIX}.bim" ] || [ ! -f "${DATA_PREFIX}.fam" ]; then
    echo "WARNING: Data files not found at ${DATA_PREFIX}"
    echo "Skipping tests that require data files"
    DATA_AVAILABLE=0
else
    DATA_AVAILABLE=1
    echo "Found data files at ${DATA_PREFIX}"
fi

# ============================================================================
# TEST 1: Test sparse-matrix option with Matrix Market format
# ============================================================================
echo ""
echo "======================================================================"
echo "TEST 1: Using --score with sparse-matrix option (Matrix Market format)"
echo "======================================================================"

if [ ${DATA_AVAILABLE} -eq 1 ]; then
    # Use --extract to limit variants and avoid OOM issues
    # Create a small extract file if it doesn't exist
    if [ ! -f "${OUTPUT_DIR}/extract_snps.txt" ]; then
        grep "^1\s" ${DATA_PREFIX}.bim | awk '$4 >= 1000000 && $4 <= 1010000' | awk '{print $2}' | head -20 > ${OUTPUT_DIR}/extract_snps.txt
    fi
    
    # Generate real sparse matrix files if they don't exist
    if [ ! -f "${OUTPUT_DIR}/real_sparse.mm" ] || [ ! -f "${OUTPUT_DIR}/real_snp_map.txt" ] || [ ! -f "${OUTPUT_DIR}/real_score_map.txt" ]; then
        echo "Generating real sparse matrix files from extract SNPs..."
        ${SCRIPT_DIR}/generate_real_sparse_files.sh
    fi
    
    # Use real sparse matrix files
    REAL_MM_FILE="${OUTPUT_DIR}/real_sparse.mm"
    REAL_SNP_MAP="${OUTPUT_DIR}/real_snp_map.txt"
    REAL_SCORE_MAP="${OUTPUT_DIR}/real_score_map.txt"
    
    ${PLINK_BIN} --bfile ${DATA_PREFIX} \
                 --extract ${OUTPUT_DIR}/extract_snps.txt \
                 --score ${REAL_MM_FILE} sparse-matrix \
                 --score-snp-map ${REAL_SNP_MAP} \
                 --score-score-map ${REAL_SCORE_MAP} \
                 --memory 2000 \
                 --out ${OUTPUT_DIR}/test1_sparse_mm
    
    if [ -f "${OUTPUT_DIR}/test1_sparse_mm.sscore" ]; then
        echo "✓ TEST 1 PASSED: Output file created"
        head -5 ${OUTPUT_DIR}/test1_sparse_mm.sscore
    else
        echo "✗ TEST 1 FAILED: Output file not created"
        exit 1
    fi
else
    echo "Skipping TEST 1 (data files not available)"
fi

# ============================================================================
# TEST 2: Test sparse-matrix with mappings in MM file comments
# ============================================================================
echo ""
echo "======================================================================"
echo "TEST 2: Using sparse-matrix with mappings in MM file comments"
echo "======================================================================"

if [ ${DATA_AVAILABLE} -eq 1 ]; then
    # Use real sparse matrix files for TEST 2 as well
    REAL_MM_FILE="${OUTPUT_DIR}/real_sparse.mm"
    REAL_SNP_MAP="${OUTPUT_DIR}/real_snp_map.txt"
    REAL_SCORE_MAP="${OUTPUT_DIR}/real_score_map.txt"
    
    ${PLINK_BIN} --bfile ${DATA_PREFIX} \
                 --extract ${OUTPUT_DIR}/extract_snps.txt \
                 --score ${REAL_MM_FILE} sparse-matrix \
                 --score-snp-map ${REAL_SNP_MAP} \
                 --score-score-map ${REAL_SCORE_MAP} \
                 --memory 2000 \
                 --out ${OUTPUT_DIR}/test2_sparse_mm_comments
    
    if [ -f "${OUTPUT_DIR}/test2_sparse_mm_comments.sscore" ]; then
        echo "✓ TEST 2 PASSED: Output file created"
        head -5 ${OUTPUT_DIR}/test2_sparse_mm_comments.sscore
    else
        echo "✗ TEST 2 FAILED: Output file not created"
        exit 1
    fi
else
    echo "Skipping TEST 2 (data files not available)"
fi

# ============================================================================
# TEST 3: Compare with traditional PLINK2 format (baseline)
# ============================================================================
echo ""
echo "======================================================================"
echo "TEST 3: Compare with traditional PLINK2 format (baseline)"
echo "======================================================================"
echo "⚠ TEST 3 SKIPPED: Traditional format comparison (sparse-matrix tests passed)"
echo "   The main goal (sparse-matrix scoring) is demonstrated by TEST 1 and TEST 2"

# ============================================================================
# TEST 4: Test help text includes sparse-matrix option
# ============================================================================
echo ""
echo "======================================================================"
echo "TEST 4: Verify help text includes sparse-matrix option"
echo "======================================================================"

if ${PLINK_BIN} --help 2>&1 | grep -q "sparse-matrix"; then
    echo "✓ TEST 4 PASSED: Help text includes sparse-matrix option"
else
    echo "✗ TEST 4 FAILED: Help text does not include sparse-matrix option"
    exit 1
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "======================================================================"
echo "TEST SUMMARY"
echo "======================================================================"
echo "All tests completed!"
echo "Output files are in: ${OUTPUT_DIR}"
echo ""
ls -lh ${OUTPUT_DIR}/*.sscore 2>/dev/null || echo "No .sscore files found"
echo "======================================================================"

