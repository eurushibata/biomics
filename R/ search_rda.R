library(rols) # olsQuery
library(stringr) # str_match
library(RSQLite)
library(plyr) # create_progress_bar

# TODO: implement graph suggestions
# TODO: implement outputtable
# create a temp file with all mapped terms

biOMICS <- function(keyword, exact=FALSE) {
	load("../inst/extdata/db.Rda")
	# ontologies to be searchable on OLS SOAP service
	ontologies <- c("EFO", "BTO")

	# exclude ontologies nested inside other ontologies
	ontologies.blacklist <- c("CHEBI", "NCBITaxon")

	# check if ontologies are available
	if (!all(ontologies %in% ontologies()$Name)) {
		stop("Ontologies are not available")
	}

	l <- list()

	# initial message
	message(paste("biOMICS+ is searching for:", keyword, "\nSearching... (Mapping all synonyms)"))

	# create progress bar
	progress_bar <- create_progress_bar("text")
	progress_bar$init(1)

	for (i in ontologies) {
		qs <- suppressMessages( olsQuery(
						pattern=keyword,
						ontologyName=i,
						exact=exact))

		if (length(qs) > 0) {
			qs.ontologies <- as.vector(str_match(names(qs), "(.+)[\u003a].+")[,2])
			qs <- qs[!(qs.ontologies %in% ontologies.blacklist)]
		}

		l <- append(l, list(qs))
	}
	names(l) <- ontologies

	l <- unlist(l)

	if (!is.null(l)) {
		# if results > 0

		# build data.frame from the search 
		term <- as.vector(l)
		term.id <- as.vector(str_match(names(l),".+[\u002e](.+)")[,2])
		term.ontology <- as.vector(str_match(names(l),"(.+)[\u002e].+")[,2])
		
		ontology.table.remote <- data.frame(term, term.id, term.ontology)
		
		# count total records found for the first iteration
		total <- nrow(ontology.table.remote)

		# initialize progress bar
		progress_bar$init(total)

	} else {
		# if results = 0

		# initialize progress bar and step
		progress_bar$init(1)
		progress_bar$step()
		
		message(paste("\n\nbiOMICS+ couldn't find any term for:", keyword))
		message("biOMICS+ is quitting...")
		return(0)
	}

	# implement try-catch

	for (i in seq(1:total)) {
		# step progress bar
		progress_bar$step()

		# parse termId and ontologyName
		termId <- as.character(ontology.table.remote[i,]$term.id)
		ontologyName <- as.character(ontology.table.remote[i,]$term.ontology)

		# for each 1st record, get all children
		children <- as.character(map(rols:::getTermChildren(termId = termId, ontologyName= ontologyName, distance= 0, relationTypes=2)))

		# if children found, bind it to the data frame
		if (class(children) == "character") {
			ontology.table.remote <- rbind(ontology.table.remote, data.frame(term=children, term.id=names(children), term.ontology=ontologyName))
			
		}
	}
	cat("\n")

	# filter only ontologies we use
	# TODO: replace database for an sql query on the ontology table
	# database <- c("EFO:0003042", "BTO:0000142", "UBERON:0000955")
	
	# db.path <- file.path("..","inst","extdata","biomics.sqlite")
	# conn <- dbConnect(dbDriver("SQLite"), dbname=db.path)
	
	# sql <- "SELECT * FROM Ontology"

	# database <- dbGetQuery(conn, sql)

	ontology.table.local <- subset(db, db$biosample_term_id %in% as.vector(ontology.table.remote$term.id))

	message(paste0("biOMICS+ found ", nrow(ontology.table.local), " terms related to \"", keyword,"\""))

	if (nrow(ontology.table.local)==0) {
		t.encode <- 0
		t.roadmap <- 0
		t.tcga <- 0
	} else {
		# sql <- paste("SELECT * FROM Experiment_Sample where id in (", paste(ontology.table.local$Experiment_Sample_id, collapse=","), ")")
		# out <- dbGetQuery(conn, sql)
		# out$project <- tolower(out$project) 

		t.encode <- nrow(subset(ontology.table.local, project == "encode"))
		t.roadmap <- nrow(subset(ontology.table.local, project == "roadmap"))
		t.tcga <- nrow(subset(ontology.table.local, project == "tcga"))
		
		
	}

	# print summary of projects
	message(paste0("  ENCODE: ", t.encode))
	message(paste0("  ROADMAP: ", t.roadmap))
	message(paste0("  TCGA: ", t.tcga))


	message("biOMICS+ is quitting...")
	
	if (nrow(ontology.table.local)>0) {
		
		# reshape data.frame with fields we want
	 #  	out.reshape <- data.frame(id=out$id, experiment=out$Experiment_id, sample=out$Sample_id, project=out$project, embargo_date=out$embargo_date)
		# for (i in seq(1:nrow(out.reshape))) {
		# 	sql <- paste("SELECT name FROM Experiment where id=", out.reshape[i,]$experiment)
		# 	qs <- dbGetQuery(conn, sql)
		# 	out.reshape[i,]$experiment <- qs$name
		# 	sql <- paste("SELECT name FROM Sample where id=", out.reshape[i,]$sample)
		# 	qs <- dbGetQuery(conn, sql)
		# 	out.reshape[i,]$sample <- qs$name
		# 	}
		#TODO: CLOSE CONNECTION
		return(ontology.table.local)
	}
}

# b = biOMICS("gbm")
