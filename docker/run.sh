#!/bin/bash

# The arguments to this script are as follows:
# 1: Barcodes file
# 2: Features file
# 3: Matrix file
# 4: Sample name

# This funcion tests whether a file is gzip-compressed.
# If the test fails, it prints to stderr and exits with code 1
# The expected args are the path to the file and a "name" for
# that file so the user knows which file caused the problem.
test_gzip() {
    gzip -t $1 2> /dev/null
    if [ $? -eq 1 ]; then
        echo "The $2 file was not gzip compressed. Please check this." >&2
        exit 1
    fi
}

# If any of these fail, the script will exit
test_gzip $1 barcodes
test_gzip $2 features
test_gzip $3 matrix

# If we arrive here, we can execute the R script:
Rscript /opt/software/ingest_10x.R -b $1 -f $2 -m $3 -s $4