Dual Pipeline pattern Guide: A quick start template
===================================================

## Overview

This purpose of this document is to provide a manual for the Dual pipeline migration pattern from Azure Data Lake Storage 1(Gen1) to Azure Data Lake Storage 2 (Gen2) using Azure data factory. This provides the directions, references and approach how to set up the dual pipeline and set up the workloads.

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
 
 * **Active Azure Subscription**

 * **Azure Data Lake Storage Gen1**

 * **Azure Data Lake Storage Gen2**. For more details please refer to [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 

 * **Azure Key Vault**. Required keys and secrets to be configured here.

 * **Service principal** with read, write and execute permission to the resource group, key vault, data lake store Gen1 and data lake store Gen2. 
 To learn more, see [create service principal account](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and to provide SPN access to Gen1 refer to [SPN access to Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory)

 
## Data pipeline set up for Gen1 and Gen2

 Sample data pipeline set up for Gen1 using Azure Databricks for data ingestion, HDInsight for data processing and Azure SQL DW for    storing the processed data for analytics. 
 
 ![image](https://user-images.githubusercontent.com/62353482/83429980-c2417a80-a3e9-11ea-9ab6-4d08b02b51b1.png)
 
 ![image](https://user-images.githubusercontent.com/62353482/83435523-477c5d80-a3f1-11ea-9288-a6f9063d81ec.png)

 
 Here ADF is used for orchestrating data-processing pipelines supporting data ingestion, copying data from and to different storage types (Gen1 and Gen2) in azure, loading the processed data to datawarehouse and executing transformation logic.
 
 ![image](https://user-images.githubusercontent.com/62353482/83435632-6b3fa380-a3f1-11ea-8639-dba1e217e044.png)


### How to set up Gen1 data pipeline

**Prerequisite**

 * Create **HDInsight cluster** for Gen1. Refer [here](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-hdinsight-hadoop-use-portal) for more details.
 
 * Create **HDInsight cluster** for Gen2. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-use-data-lake-storage-gen2) for more details.
 
 * Permission should be set up for the managed identity for Gen2 storage account. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-use-data-lake-storage-gen2#set-up-permissions-for-the-managed-identity-on-the-data-lake-storage-gen2-account) for more details.
 
 * Additional blob storage should be created for Gen1 to support HDInsight linked service in ADF. Refer [here](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-create-account-block-blob?tabs=azure-portal) for more details.
 
 * Create a **linked service** in ADF for **ADB**. Refer [How to create linked service for ADB in ADF](https://docs.microsoft.com/en-us/azure/data-factory/transform-data-using-databricks-notebook#create-an-azure-databricks-linked-service)

 * Create a **linked service** in ADF for **HDInsight**. Refer [How to create linked service for HDInsight in ADF](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-adf#create-an-azure-storage-linked-service)

 * Create a **linked service** in ADF for **stored procedure**. Refer [How to create linked service for Azure synapse analytics](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-sql-data-warehouse#load-data-into-azure-synapse-analytics)
 
**Raw data ingestion using ADB script in ADF**

Create a pipeline for data ingestion process using ADB activity.. Refer [here](https://docs.microsoft.com/en-us/azure/data-factory/transform-data-using-databricks-notebook#create-a-pipeline) for more details.

![image](https://user-images.githubusercontent.com/62353482/83448158-63d6c500-a406-11ea-8a29-a1cdd514509c.png)

**Data processing using HDInsight in ADF**

Create a pipeline for data processing using HDInsight activity. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-adf#create-a-pipeline) for more details.

![image](https://user-images.githubusercontent.com/62353482/83450714-a6020580-a40a-11ea-8c99-55c2c9a96104.png)

**Loading to Azure synapse analytics (SQL DW) using stored procedure in ADF**

Create a pipeline for loading the processed data to SQL DW using stored procedure activity. 

![image](https://user-images.githubusercontent.com/62353482/83453396-48bc8300-a40f-11ea-8c7d-886097bbc323.png)

Stored procedure Settings:

![image](https://user-images.githubusercontent.com/62353482/83456907-73a9d580-a415-11ea-8515-ce9e57718c04.png)

### How to set up Gen2 data pipeline
 
**Raw data ingestion using ADB script in ADF**

Create a pipeline for data ingestion process using ADB activity. Refer [here](https://docs.microsoft.com/en-us/azure/data-factory/transform-data-using-databricks-notebook#create-a-pipeline) for more details.

![image](https://user-images.githubusercontent.com/62353482/83466106-ebcec600-a42a-11ea-875a-120cb4e2a821.png)

**Data processing using HDInsight in ADF**

Create a pipeline for data processing using HDInsight activity. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-adf#create-a-pipeline) for more details.

![image](https://user-images.githubusercontent.com/62353482/83466207-39e3c980-a42b-11ea-9ed6-d056b1c1cf0f.png)

**Loading to Azure synapse analytics (SQL DW) using stored procedure in ADF**

Create a pipeline for loading the processed data to SQL DW using stored procedure activity. 

![image](https://user-images.githubusercontent.com/62353482/83466549-43216600-a42c-11ea-9306-e62ad0d6fc67.png)

Stored procedure Settings:

![image](https://user-images.githubusercontent.com/62353482/83466582-60563480-a42c-11ea-937a-1f21a6d10fa3.png)

### Creation of HDInsight linked service for Gen1 and Gen2 in ADF
 
**How to create HDInsight linked service for Gen1(Blob storage)**

Go to **Linked Services** --> **click** on **+ New** --> **New linked service** --> **Compute** --> **Azure HDInsight** --> **Continue**

![image](https://user-images.githubusercontent.com/62353482/83468627-356edf00-a432-11ea-9375-0594ab25b975.png)


 
 ## Move data from Gen1 to Gen2

 ## Data ingestion to Gen1 and Gen2
 
 ## Run workloads at Gen2
 
 ## Reach out to us

**You found a bug or want to propose a feature?**

 File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
 Make sure to remove any credential from your code before sharing it.

## References

* [Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)
