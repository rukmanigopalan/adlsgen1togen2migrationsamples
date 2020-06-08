Application and Workload Update
================================

## Overview

The purpose of this document is to provide steps and ways to migrate the workloads and applications from **Gen1** to **Gen2** after data copy is completed.

This can be applicable for below migration patterns:

1. Incremental Copy pattern

2. Lift and Shift copy pattern

3. Dual Pipeline pattern

 As part of this, we will [configure services in workloads](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-supported-azure-services) used and update the applications to point to Gen2 mount.
 
:bulb: **Note**: We will be covering below azure services

  Azure Services           |        Related articles                                                     
  -------------            |   -------------------------------------------------------------------       
 Azure Data Factory        |   [Load data into Azure Data Lake Storage Gen2 with Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-data-lake-storage-gen2?toc=%2fazure%2fstorage%2fblobs%2ftoc.json)
 Azure Databricks          |   [Use with Azure Databricks](https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/azure-datalake-gen2) <br> [Quickstart: Analyze data in Azure Data Lake Storage Gen2 by using Azure Databricks](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-quickstart-create-databricks-account) <br>                    [Tutorial: Extract, transform, and load data by using Azure Databricks](https://docs.microsoft.com/en-us/azure/azure-databricks/databricks-extract-load-sql-data-warehouse)
 SQL Data Warehouse        |   [Use with Azure SQL Data Warehouse](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-sql-data-warehouse)
 HDInsight                 |   [Use Azure Data Lake Storage Gen2 with Azure HDInsight clusters](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-use-data-lake-storage-gen2?toc=/azure/storage/blobs/toc.json) <br>  [Tutorial: Extract, transform, and load data by using Azure HDInsight](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-tutorial-extract-transform-load-hive)

  
## Table of contents

  
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [How to Configure and Update Azure Databricks](#how-to-configure-and-update-azure-databricks)
   * [How to Configure and Update Azure Datafactory](#how-to-configure-and-update-azure-datafactory)
   * [How to Configure and update HDInsight](#how-to-configure-and-update-hdinsight)
   * [How to configure and update Azure Synapse Analytics](#how-to-configure-and-update-azure-synapse-analytics)
   * [Cutover from Gen1 to Gen2](#Cutover-from-Gen1-to-Gen2)
 <!--te-->
 
## Prerequisites
 
 **The migration of data from Gen1 to Gen2 should be completed**
  
## How to Configure and Update Azure Databricks
 
 Applies where Databricks is used for data ingestion to ADLS Gen1.
   
 **Before the migration**:
 
 **1. Mount configured to Gen1 path**
 
 Sample code showing mount path configured for ADLS Gen1 using service principle:

 ![image](https://user-images.githubusercontent.com/62353482/79265180-90c91b80-7e4a-11ea-9000-0f86aa7c6ebb.png)

 **2. Set up DataBricks cluster for scheduled job run**
  
 Sample snapshot of working code:
 
 ![image](https://user-images.githubusercontent.com/62353482/83693292-ac2ee800-a5aa-11ea-878e-e8f6d72daf72.png)

  **Note**: Refer to [IncrementalSampleLoad](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Incremental/Application/IncrementSampleLoad.py) script for more details.
 
 **After the migration**:
  
 **1. Change the mount configuration to Gen2 container**
  
  ![image](https://user-images.githubusercontent.com/62353482/79016042-dfad4300-7b22-11ea-97c2-274e533a37e7.png)

  **Note**: **Stop** the job scheduler and change the mount configuration to point to Gen2 with the same mount name.

 ![image](https://user-images.githubusercontent.com/62353482/79009824-49beeb80-7b15-11ea-8d14-ce444f7fd4b8.png)

  **Note**: Refer to [mountconfiguration](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Incremental/Application/MountConfiguration.py) script for more details.
  
 **2. Reschedule the job scheduler**

 **3. Check for the new files getting generated at the Gen2 root folder path**
 

## How to Configure and Update Azure Datafactory
 
   Once the data migration using ADF is completed from ADLS Gen1 to Gen2, follow the below steps:
 
  **1. Stop the trigger to Gen1** used as part of Incremental copy pattern.
    
  **2. Modify the existing factory by creating new linked service to point to Gen2 storage**.
  
  Go to --> **Azure Data Factory** --> **Click on Author** --> **Connections** --> **Linked Service** --> **click on New*** --> **Choose Azure Data Lake Storage Gen2** --> **Click on Continue button**

 ![image](https://user-images.githubusercontent.com/62353482/79276321-a3e4e700-7e5c-11ea-9908-b013e2d1e12b.png)


  Provide the details to create new Linked service to point to Gen2 storage account.

![image](https://user-images.githubusercontent.com/62353482/79276405-cd057780-7e5c-11ea-9c31-95dfd26db5b9.png)

  **3. Modify the existing factory by creating new dataset in Gen2 storage**.
   
   Go to --> **Azure Data Factory** --> **Click on Author** --> **Click on Pipelines** --> **Select the pipeline** --> **Click on Activity** --> **Click on sink tab** --> Choose the dataset to point to Gen2 
   
   ![image](https://user-images.githubusercontent.com/62353482/83690089-eeedc180-a5a4-11ea-8a57-28a22822a595.png)


  **4. Click on Publish all**
   
   ![image](https://user-images.githubusercontent.com/62353482/79280406-21145a00-7e65-11ea-8950-bff27882c4de.png)


  **5. Go to Triggers and activate it**.
   
   ![image](https://user-images.githubusercontent.com/62353482/79280526-66388c00-7e65-11ea-895e-915018092b67.png)


   **6. Check for the new files getting generated at the Gen2 root folder path**
  
 ## How to Configure and update HDInsight
  
   Applies where HDInsight is used as workload to process the Raw data and execute the transformations. Below is the step by step process used as part of [Dual pipeline pattern](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/master/src/Dual%20pipeline#how-to-set-up-gen1-data-pipeline).
  
   **Prerequisite**
   
   Two HDInsight clusters to be created for each Gen1 and Gen2 storage.
 
   **Before Migration**
   
   The Hive script is mounted to Gen1 endpoint as shown below:
   
   ![image](https://user-images.githubusercontent.com/62353482/83672012-74b04380-a58a-11ea-89b6-54564aeb52f5.png)
   
   **After Migration**
   
   The Hive script is mounted to Gen2 endpoint as shown below:
   
   ![image](https://user-images.githubusercontent.com/62353482/83672806-b8f01380-a58b-11ea-8c16-ae0c662d7de6.png)
   
   Once all the existing data is moved from Gen1 to Gen2, Start running the worloads at Gen2 endpoint.
   
  ## How to configure and update Azure Synapse Analytics (Azure SQL DW)
  
   Applies to the data pipelines having Azure SQL DW as one of the workloads. Below is the step by step process used as part of [Dual pipeline pattern](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/master/src/Dual%20pipeline#how-to-set-up-gen1-data-pipeline) :
   
   **Before Migration**
   
   The stored procedure activity is pointed to Gen1 mount path.
   
   ![image](https://user-images.githubusercontent.com/62353482/84082011-eece3700-a993-11ea-8ba0-f4efab65c0e9.png)

   **After Migration**
   
   The stored procedure activity is pointed to Gen2 endpoint.
   
   ![image](https://user-images.githubusercontent.com/62353482/84082177-42408500-a994-11ea-84ba-d575ba1e3611.png)

   
   **Run the trigger**
   
   ![image](https://user-images.githubusercontent.com/62353482/84082352-8f245b80-a994-11ea-9132-45e335429145.png)

   **Check the SQL table in the Data warehouse for new data load**.
      
 ## Cutover from Gen1 to Gen2
   
   After you're confident that your applications and workloads are stable on Gen2, you can begin using Gen2 to satisfy your business scenarios. Turn off any remaining pipelines that are running on Gen1 and decommission your Gen1 account.
  
   
   

