# mev-sctk-importcellranger

This is a WebMeV-compatible Docker-based process for converting the canonical output files produced by 10X genomics' CellRanger process (single-cell RNA-seq) into an integer count matrix. 

The original data formats (see below) are convenient for storage and transfer due to the sparse nature of scRNA-seq (e.g. many genes are not expressed in a given cell). However, many analysis/processing pipelines require a full count matrix. This process creates the matrix given the original sparse representations.

The resulting matrix can be used with other WebMeV single-cell analyses.

The input files are typical outputs from CellRanger, as might be created by a sequencing facility. These include:
- *barcodes.tsv.gz:* The file of barcodes marking the cell/droplets.
- *features.tsv.gz:* The file of genomic features the reads are annotated with.
- *matrix.mtx.gz:* The abundance matrix

We expect that the files are gzip-compressed, which is consistent with CellRanger outputs. Also note that the files do not need to be named exactly as given above, as long as the file contents are consistent with the expected format.
