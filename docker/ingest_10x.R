suppressMessages(suppressWarnings(library("singleCellTK")))
suppressMessages(suppressWarnings(library("Matrix")))
suppressMessages(suppressWarnings(library("optparse")))

# args from command line
args <- commandArgs(TRUE)

option_list <- list(
    make_option(
        c("-b", "--barcodes"),
        help="CellRanger barcodes.tsv.gz"
    ),
    make_option(
        c("-f", "--features"),
        help="CellRanger features.tsv.gz"
    ),
    make_option(
        c("-m", "--matrix"),
        help="CellRanger matrix.mtx.gz"
    ),
    make_option(
        c("-s", "--sample_name"),
        help="Sample name"
    )
)

opt <- parse_args(OptionParser(option_list=option_list))

# set the dummy parent folder
parent_dir = "webmev_cellranger_import"

# Check that the file was provided:
if (is.null(opt$barcodes)){
    message(
        'Need to provide a barcodes.tsv.gz file with the -b/--barcodes arg.'
    )
    quit(status=1)
}
if (is.null(opt$features)){
    message(
        'Need to provide a features.tsv.gz file with the -f/--features arg.'
    )
    quit(status=1)
}
if (is.null(opt$matrix)){
    message(
        'Need to provide a matrix.mtx.gz file with the -m/--matrix arg.'
    )
    quit(status=1)
}

# change the working directory to co-locate with one of the 3 input files:
working_dir <- dirname(opt$barcodes)
setwd(working_dir)

# Dummy out the CellRanger file structure
cellranger_path = paste(
    ".",
    parent_dir,
    opt$sample_name,
    "outs/filtered_feature_bc_matrix",
    sep="/"
)
dir.create(cellranger_path, recursive=T)

# Fills downstream folder with data
dest_files <- c(
    paste(cellranger_path, 'barcodes.tsv.gz', sep='/'),
    paste(cellranger_path, 'features.tsv.gz', sep='/'),
    paste(cellranger_path, 'matrix.mtx.gz', sep='/')
)

# don't need, but otherwise it prints booleans to 
# the output
copy_status <- file.copy(
    c(opt$barcodes, opt$features, opt$matrix),
    dest_files
)

# import CellRanger
# It does not matter if filtered or not, 
# as we made a dummy CellRanger directory
sce <- tryCatch(
  {    
     importCellRanger(
        cellRangerDirs = parent_dir,
        sampleDirs = opt$sample_name,
        sampleNames = NULL,
        dataType = "filtered"
    )
  },
  error=function(err){
    message('There was an error when reading the files. This can happen if the files become mixed up. Please check that your input files were correctly entered.')
    quit(status=1)
  }
)

# Convert sce counts to non-sparse matrix
counts <- as.matrix(counts(sce))

output_file = paste(
    working_dir,
    paste0(opt$sample_name, '.tsv'),
    sep='/'
)

# Export counts to TSV
write.table(
    counts,
    file = output_file,
    sep = "\t",
    quote = F
)

# for WebMEV compatability, need to create an outputs.json file.
json_str = paste0(
       '{"output_matrix":"', output_file, '"}'
)
output_json <- paste(working_dir, 'outputs.json', sep='/')
write(json_str, output_json)
