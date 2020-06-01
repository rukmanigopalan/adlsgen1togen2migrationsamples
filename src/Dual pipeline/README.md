Dual Pipeline pattern Guide: A quick start template
===================================================

## Overview

This purpose of this document is to provide a manual for the Dual pipeline migration pattern from Azure Data Lake Storage 1(Gen1) to Azure Data Lake Storage 2 (Gen2) using Azure data factory. This provides the directions, references and approach how to set up the pipelines and do the migration.

Considerations for using the dual pipeline pattern:

✔️ Gen1 and Gen2 pipelines run side-by-side.

✔️ Supports zero downtime.

✔️ Ideal in situations where your workloads and applications can't afford any downtime, and you can ingest into both storage accounts.

## Table of contents
   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [Data pipeline set up for Gen1 and Gen2](#data-pipeline-set-up-for-gen1-and-gen2)
     * [How to set up Gen1 data pipeline](#how-to-set-up-gen1-data-pipeline)
     * [How to set up Gen2 data pipeline](#how-to-set-up-gen2-data-pipeline)
     * [Creation of HDI clusters for Gen1 and Gen2 in ADF](#creation-of-hdi-clusters-for-gen1-and-gen2-in-adf)
   * [Move data from Gen1 to Gen2](#move-data-from-gen1-to-gen2)
   * [Data ingestion to Gen1 and Gen2](#data-ingestion-to-gen1-and-gen2)
   * [Run workloads at Gen2](#run-workloads-at-gen2)
   * [Application Update](#application-update)
   * [Reach out to us](#reach-out-to-us)
   * [References](#references)
 <!--te-->
 
 ## Prerequisites
 
 ## Data pipeline set up for Gen1 and Gen2
 
 ### How to set up Gen1 data pipeline
 
 ### How to set up Gen2 data pipeline
 
 ### Creation of HDI clusters for Gen1 and Gen2 in ADF
 
 
 ## Move data from Gen1 to Gen2

 ## Data ingestion to Gen1 and Gen2
 
 ## Run workloads at Gen2
 
 ## Reach out to us

**You found a bug or want to propose a feature?**

 File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
 Make sure to remove any credential from your code before sharing it.

## References

* [Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)
