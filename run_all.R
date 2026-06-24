# run_all.R -- reproduce the whole analysis end to end.
# Usage from the repository root:  Rscript run_all.R
source("R/01_download_data.R")
source("R/02_prepare_data.R")
source("R/03_figures.R")
source("R/04_regressions.R")
message("\nDone. See figures/ and results/.")
