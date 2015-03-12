library(rols) # olsQuery
library(stringr) # str_match
library(RSQLite)
library(plyr) # create_progress_bar
library(RCurl)

# TODO: implement graph suggestions
# TODO: implement outputtable
# create a temp file with all mapped terms


experiment <- function(file_type, experiment_type){
	# Start progress bar
	#progress_bar <- create_progress_bar("text")
	# Initiate database connection
	db.path <- file.path("..","inst","extdata","biomics.sqlite")
	print(db.path)
	conn <- dbConnect(dbDriver("SQLite"), dbname=db.path)
	print(conn)

	##############################################################
	## Process list of file formats
	file_type <- unlist(file_type)
	file_type <- paste0("'", file_type, "'", collapse=",")

	## Process list of experiments
	experiment_type <- unlist(experiment_type)
	experiment_type <- paste0("'",experiment_type,"'", collapse=",")

	##############################################################
	# Searching for type of File
	# sql_file <- paste0("SELECT id FROM File WHERE format in (","narrowPeak.gz", ")")
	#sql_file <- paste0("SELECT id FROM File WHERE format in (",file_type, ")")
	#qs_file_id <- dbGetQuery(conn, sql_file)

	# Searching the ids of each experiment
	sql_experiment <- paste0("SELECT id FROM Experiment where name in (", experiment_type, ")")
	qs_experiment_id <- dbGetQuery(conn, sql_experiment)

	##############################################################
	# Searching for Experiment_Sample_id where Experiment_id
	### InnerJoin would be faster here
	sql_experiment_sample_id <- paste0("SELECT id FROM Experiment_Sample WHERE Experiment_id in (", qs_experiment_id, ")")
	qs_experiment_sample_id  <- dbGetQuery(conn, sql_experiment_sample_id)

	##############################################################
	# Getting only files where the experiment and type of file
	# where selected

	sql_final <- paste0("SELECT Experiment_Sample_id, name, path FROM File WHERE format in (",file_type, ")", " AND ", "Experiment_Sample_id in (", as.character(qs_experiment_sample_id[,1]), ")")
	print(sql_final)
	cat("\n") 
	#qs_final  <- dbGetQuery(conn, sql_final)

	#progress_bar$init(nrow(qs))
	#message("")
	
	handle = getCurlHandle(ftp.use.epsv=TRUE)
	for(i in sql_final){
		qs_final  <- dbGetQuery(conn, i)
		print(qs_final)
		f <- CFILE(qs_final$name, mode="wb")
		curlPerform(url=qs_final$path, writedata=f@ref, curl=handle, header=TRUE)
		close(f)
		 #<- getURL(qs[i,]$path, curl = handle)
		#download.file(qs[i,]$path, qs[i,]$name, method="curl")
		#progress_bar$step()
	}

	# for(i in seq(1:nrow(sql_final))){
	# 	qs_final  <- dbGetQuery(conn, i)
		
	# 	f <- CFILE(qs_final[i,]$name, mode="wb")
	# 	curlPerform(url=qs_final[i,]$path, writedata=f@ref, curl=handle, header=TRUE)
	# 	close(f)
	# 	 #<- getURL(qs[i,]$path, curl = handle)
	# 	#download.file(qs[i,]$path, qs[i,]$name, method="curl")
	# 	progress_bar$step()
	# }

	#dbDisconnect(conn) 
	return(qs_final)
}

experiment_Types <- function(){
	db.path <- file.path("..","inst","extdata","biomics.sqlite")
	conn <- dbConnect(dbDriver("SQLite"), dbname=db.path)

	sql <- paste0("SELECT name FROM Experiment")
	qs <- dbGetQuery(conn, sql)
	qs[duplicated(qs),]
	#split(qs, 1:nrow(qs)) 
	final <- unique(qs)
	dbDisconnect(conn) 
	return(final)
	
}

format_Files <- function(){
	db.path <- file.path("..","inst","extdata","biomics.sqlite")
	conn <- dbConnect(dbDriver("SQLite"), dbname=db.path)

	sql <- paste0("SELECT DISTINCT format FROM File")
	qs <- dbGetQuery(conn, sql)
	qs[duplicated(qs),]
	#split(qs, 1:nrow(qs)) 
	final <- unique(qs)
	dbDisconnect(conn) 
	return(final)
	
}