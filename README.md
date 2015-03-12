# biomics
biologically integrating OMICS data from ENCODE | ROADMAP | TCGA

export data from mongo and import into rda element

mongoexport --host localhost --db encode --collection experiment --csv --out rec.csv --fields biosample_term_name,biosample_type,biosample_term_id ; mongoexport --host localhost --db biomics --collection roadmap --csv --out recroad.csv --fields "Sample Name","Experiment","# GEO Accession"; Rscript rec.R
