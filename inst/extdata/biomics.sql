-- Creator:       MySQL Workbench 5.2.47/ExportSQLite plugin 2009.12.02
-- Author:        biOMICs Team
-- Caption:       biOMICs
-- Project:       Name of the project
-- Changed:       2013-09-03 18:01
-- Created:       2013-07-18 15:44
PRAGMA foreign_keys = ON;

-- Schema: mydb
BEGIN;
CREATE TABLE "Sample"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "name" VARCHAR(45) NOT NULL,
  "encode_tier" INTEGER,
  "lineage" VARCHAR(45),
  "description" TEXT,
  "disease" VARCHAR(45),
  "molecule" VARCHAR(45),
  "tissue" VARCHAR(45),
  "type" VARCHAR(45),
  "vendor" VARCHAR(45),
  "vendor_id" VARCHAR(45),
  CONSTRAINT "all_unique"
    UNIQUE("name","molecule","type","vendor_id","vendor","tissue","disease","description","lineage","encode_tier")
);
CREATE TABLE "Experiment"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "name" VARCHAR(45) NOT NULL,
  "antigen" VARCHAR(45),
  "library_strategy" VARCHAR(45),
  CONSTRAINT "all_unique"
    UNIQUE("name","antigen","library_strategy")
);
CREATE TABLE "Platform"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "name" VARCHAR(45) NOT NULL,
  "code" VARCHAR(45),
  CONSTRAINT "all_unique"
    UNIQUE("name","code")
);
CREATE TABLE "Experiment_Sample"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "Experiment_id" INTEGER NOT NULL,
  "Sample_id" INTEGER NOT NULL,
  "Platform_id" INTEGER NOT NULL,
  "project" VARCHAR(10) NOT NULL,
  "geo_accession" VARCHAR(45),
  "dcc_accession" VARCHAR(45),
  "sra_accession" VARCHAR(45),
  "embargo_date" DATETIME,
  CONSTRAINT "all_unique"
    UNIQUE("project","dcc_accession","sra_accession","embargo_date","Platform_id","Experiment_id","Sample_id","geo_accession"),
  CONSTRAINT "fk_Experiment_has_Sample_Experiment"
    FOREIGN KEY("Experiment_id")
    REFERENCES "Experiment"("id"),
  CONSTRAINT "fk_Experiment_has_Sample_Sample1"
    FOREIGN KEY("Sample_id")
    REFERENCES "Sample"("id"),
  CONSTRAINT "fk_Experiment_Sample_Platform1"
    FOREIGN KEY("Platform_id")
    REFERENCES "Platform"("id")
);
CREATE INDEX "Experiment_Sample.fk_Experiment_has_Sample_Sample1_idx" ON "Experiment_Sample"("Sample_id");
CREATE INDEX "Experiment_Sample.fk_Experiment_has_Sample_Experiment_idx" ON "Experiment_Sample"("Experiment_id");
CREATE INDEX "Experiment_Sample.fk_Experiment_Sample_Platform1_idx" ON "Experiment_Sample"("Platform_id");
CREATE TABLE "Ontology"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "Experiment_Sample_id" INTEGER NOT NULL,
  "ontology" VARCHAR(45),
  "term_id" VARCHAR(45) NOT NULL,
  CONSTRAINT "fk_Ontology_Experiment_Sample1"
    FOREIGN KEY("Experiment_Sample_id")
    REFERENCES "Experiment_Sample"("id")
);
CREATE INDEX "Ontology.fk_Ontology_Experiment_Sample1_idx" ON "Ontology"("Experiment_Sample_id");
CREATE INDEX "Ontology.all_unique" ON "Ontology"("id","Experiment_Sample_id","term_id");
CREATE TABLE "File"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "Experiment_Sample_id" INTEGER NOT NULL,
  "name" VARCHAR(45) NOT NULL,
  "path" TEXT NOT NULL,
  "format" VARCHAR(45) NOT NULL,
  "size" FLOAT,
  "checksum" TEXT,
  "tcga_level" INTEGER,
  "version" INTEGER,
  "batch" INTEGER,
  -- CONSTRAINT "all_unique"
  --   UNIQUE("name","path","format","size","checksum","tcga_level","version","batch","Experiment_Sample_id"),
  CONSTRAINT "notnull_unique"
    UNIQUE("name","path","format"),
  CONSTRAINT "fk_File_Experiment_Sample1"
    FOREIGN KEY("Experiment_Sample_id")
    REFERENCES "Experiment_Sample"("id")
);
CREATE INDEX "File.fk_File_Experiment_Sample1_idx" ON "File"("Experiment_Sample_id");
COMMIT;
