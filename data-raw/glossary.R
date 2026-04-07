## Script to convert glossary.csv table to rdata for vignette and glossary functions
glossary <- readr::read_csv("data-raw/glossary.csv")
save(glossary, file = "inst/glossary.rdata", compress = TRUE)
