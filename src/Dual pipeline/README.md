Dual Pipeline pattern Guide: A quick start template
===================================================

## Overview

The purpose of this document is to provide a manual for the Dual pipeline migration pattern from Azure Data Lake Storage 1(Gen1) to Azure Data Lake Storage 2 (Gen2) using Azure data factory. This provides the directions, references and approach how to set up the dual pipeline, do migration of existing data from Gen1 to Gen2 and set up the workloads to run at Gen2 endpoint.

Considerations for using the dual pipeline pattern:

✔️ Gen1 and Gen2 pipelines run side-by-side.

✔️ Supports zero downtime.

✔️ Ideal in situations where your workloads and applications can't afford any downtime, and you can ingest into both storage accounts.

## Table of contents
   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [Data pipeline set up for Gen1 and Gen2](#data-pipeline-set-up-for-gen1-and-gen2)
     * [Creation of HDI clusters for Gen1 and Gen2 in ADF](#creation-of-hdi-clusters-for-gen1-and-gen2-in-adf)
     * [How to set up Gen1 data pipeline](#how-to-set-up-gen1-data-pipeline)
     * [How to set up Gen2 data pipeline](#how-to-set-up-gen2-data-pipeline)
   * [Migrate data from Gen1 to Gen2](#migrate-data-from-gen1-to-gen2)
   * [Data ingestion to Gen1 and Gen2](#data-ingestion-to-gen1-and-gen2)
   * [Run workloads at Gen2](#run-workloads-at-gen2)
   * [Cutover from Gen1 to Gen2](#cutover-from-gen1-to-gen2)
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

  To set up the data pipeline in ADF, two separate HDInsight clusters should be created each for Gen1 and Gen2.

  **Prerequisite**

  * Create **HDInsight cluster** for Gen1. Refer [here](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-hdinsight-hadoop-use-portal) for more details.
 
  * Create **HDInsight cluster** for Gen2. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-use-data-lake-storage-gen2) for more details.
 
  * Create  **user assigned managed identity**. Refer [here](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-manage-ua-identity-portal#create-a-user-assigned-managed-identity) to know more.
 
  * Permission should be set up for the managed identity for Gen2 storage account. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-use-data-lake-storage-gen2#set-up-permissions-for-the-managed-identity-on-the-data-lake-storage-gen2-account) for more details.
 
 * Additional blob storage should be created for Gen1 to support HDInsight linked service in ADF. Refer [here](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-create-account-block-blob?tabs=azure-portal) for more details.


 Sample data pipeline set up for Gen1 and Gen2 using Azure Databricks for data ingestion, HDInsight for data processing and Azure SQL DW for storing the processed data for analytics. 
 
 ![image](https://user-images.githubusercontent.com/62353482/83429980-c2417a80-a3e9-11ea-9ab6-4d08b02b51b1.png)
 
 ![image](https://user-images.githubusercontent.com/62353482/83563507-16bf2580-a4d0-11ea-9707-ae659f87eb3d.png)

 
 Here ADF is used for orchestrating data-processing pipelines supporting data ingestion, copying data from and to different storage types (Gen1 and Gen2) in azure, loading the processed data to datawarehouse and executing transformation logic.
 
 ![image](https://user-images.githubusercontent.com/62353482/83435632-6b3fa380-a3f1-11ea-8639-dba1e217e044.png)


### Creation of HDI clusters for Gen1 and Gen2 in ADF
  
   1. Create **[ADB linked service](https://docs.microsoft.com/en-us/azure/data-factory/transform-data-using-databricks-notebook#create-an-azure-databricks-linked-service)** in ADF.

   2. Create **[HDInsight linked service](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-adf#create-an-azure-storage-linked-service)** in ADF.

   3. Create **[Stored procedure linked service](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-sql-data-warehouse#load-data-into-azure-synapse-analytics)** in ADF.
 
### How to set up Gen1 data pipeline

   1. **Raw data ingestion using ADB script**

   Create a pipeline for data ingestion process using ADB activity. Refer [here](https://docs.microsoft.com/en-us/azure/data-factory/transform-data-using-databricks-notebook#create-a-pipeline) for more details.

   ![image](https://user-images.githubusercontent.com/62353482/83448158-63d6c500-a406-11ea-8a29-a1cdd514509c.png)

   2. **Data processing using HDInsight**

   Create a pipeline for data processing using HDInsight activity. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-adf#create-a-pipeline) for more details.

   ![image](https://user-images.githubusercontent.com/62353482/83450714-a6020580-a40a-11ea-8c99-55c2c9a96104.png)

   3. **Loading to Azure synapse analytics (SQL DW) using stored procedure**

   Create a pipeline for loading the processed data to SQL DW using stored procedure activity. 

   ![image](https://user-images.githubusercontent.com/62353482/83453396-48bc8300-a40f-11ea-8c7d-886097bbc323.png)

  **Stored procedure Settings**:

  ![image](https://user-images.githubusercontent.com/62353482/83456907-73a9d580-a415-11ea-8515-ce9e57718c04.png)

### How to set up Gen2 data pipeline
 
   1. **Raw data ingestion using ADB script**

   Create a pipeline for data ingestion process using ADB activity. Refer [here](https://docs.microsoft.com/en-us/azure/data-factory/transform-data-using-databricks-notebook#create-a-pipeline) for more details.

  ![image](https://user-images.githubusercontent.com/62353482/83466106-ebcec600-a42a-11ea-875a-120cb4e2a821.png)

   2. **Data processing using HDInsight**

   Create a pipeline for data processing using HDInsight activity. Refer [here](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-adf#create-a-pipeline) for more details.

   ![image](https://user-images.githubusercontent.com/62353482/83466207-39e3c980-a42b-11ea-9ed6-d056b1c1cf0f.png)

   3. **Loading to Azure synapse analytics (SQL DW) using stored procedure**

   Create a pipeline for loading the processed data to SQL DW using stored procedure activity. 

   ![image](https://user-images.githubusercontent.com/62353482/83466549-43216600-a42c-11ea-9306-e62ad0d6fc67.png)

   **Stored procedure Settings**:

   ![image](https://user-images.githubusercontent.com/62353482/83466582-60563480-a42c-11ea-937a-1f21a6d10fa3.png)

### Creation of HDInsight linked service for Gen1 and Gen2 in ADF
 
   **How to create HDInsight linked service for Gen1(Blob storage)**

   1. Go to **Linked Services** --> **click** on **+ New** --> **New linked service** --> **Compute** --> **Azure HDInsight** --> **Continue**

   ![image](https://user-images.githubusercontent.com/62353482/83468627-356edf00-a432-11ea-9375-0594ab25b975.png)

   2. Provide the details from Azure subscription with respect to each field and choose **Blob Storage** under **Azure Storage linked service**

   ![image](https://user-images.githubusercontent.com/62353482/83469679-335a4f80-a435-11ea-91c3-2d844be17cbe.png)

   3. Provide the user name and password details.

   4. Click on **Create** button.

   **How to create HDInsight linked service for Gen2**

   1. Go to **Linked Services** --> **click** on **+ New** --> **New linked service** --> **Compute** --> **Azure HDInsight** --> **Continue**

   ![image](https://user-images.githubusercontent.com/62353482/83468627-356edf00-a432-11ea-9375-0594ab25b975.png)

   2. Provide the details from Azure subscription with respect to each field and choose **ADLS Gen 2** under **Azure Storage linked service**

   ![image](https://user-images.githubusercontent.com/62353482/83479945-d79cc000-a44e-11ea-8940-3884606cec7b.png)

   3. Provide the storage container name in the **File system** field. Give the user name and password. 

   4. Click on **Create** button.

## Migrate data from Gen1 to Gen2

   To migrate the existing data from Gen1 to Gen2, please refer to [lift and shift](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/master/src/Lift%20and%20Shift) pattern.
 
## Data ingestion to Gen1 and Gen2

  This step will ingest new data to both Gen1 and Gen2. 
  
  1. Create a pipeline in ADF to execute both data ingestion acitvity for Gen1 and Gen2.

![image](https://user-images.githubusercontent.com/62353482/83543532-63473880-a4b1-11ea-8267-ee267f4845a9.png)

  2. Check the storage path at Gen1 and Gen2 for the new data.
  
## Run workloads at Gen2

  This step make sure the workloads are run at Gen2 endpoint. 
  
  1. Create a pipeline in ADF to execute the workloads for Gen2. Run the pipeline.
  
  ![image](https://user-images.githubusercontent.com/62353482/83572596-b8e60a00-a4de-11ea-84ff-a4a178fa7575.png)

  2. Check the storage path and SQL DW at Gen2 for new processed data.
  
## Cutover from Gen1 to Gen2 

   After you're confident that your applications and workloads are stable on Gen2, you can begin using Gen2 to satisfy your business   scenarios. Turn off any remaining pipelines that are running on Gen1 and decommission your Gen1 account.
  
## Reach out to us

  **You found a bug or want to propose a feature?**

  File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
 

## References

   * [Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)
