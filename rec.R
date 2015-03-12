db = read.csv("rec.csv")
dbr = read.csv("recroad.csv")
colnames(dbr) <- c("biosample_term_name","biosample_type","biosample_term_id")
dbr$project = "roadmap"
db$project = "encode"

db = rbind(db,dbr)

save(db,file="/inst/extdata/db.Rda")
