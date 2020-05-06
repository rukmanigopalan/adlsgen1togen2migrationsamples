Bi-directional sync pattern Guide: A quick start template
===================================================

## Overview

This manual will introduce [Wandisco](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/preparation/azure_vm_creation) as a recommended tool to set up bi-directional sync between Gen1 and Gen2 using the Replication feature. Below will be covered as part of this guide:
  
  ✔️ Live migration from Gen1 to Gen2
  
  ✔️ Data Consistency Check
  
  ✔️ Application update for ADF, ADB and SQL DWH workloads 

Considerations for using the bi-directional sync pattern:

  ✔️ Ideal for complex scenarios that involve a large number of pipelines and dependencies where a phased approach might make more  sense.

  ✔️ Migration effort is high, but it provides side-by-side support for Gen1 and Gen2.
  
:bulb: **Note** : The guide will be focussing on the migration of data from ADLS Gen1 as source to ADLS Gen2 as destination using the  Wandisco replication mechanism.
 
## Table of contents
   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [Connect to Wandisco UI](#connect-to-wandisco-ui)
   * [Create Replication Rule](#create-replication-rule)
   * [Consistency check](#consistency-check)
   * [Migration using LivMigrator](#migration-using-livmigrator)
   * [Managing Replication](managing-replication)
   * [Application Update](#application-update)
     * [Beginning State](#beginning-state)
     * [Interim State](#interim-state)
     * [Eventual End State](#eventual-end-state)
   * [Reach out to us](#reach-out-to-us)
   * [References](#references)
 <!--te-->
 
## Prerequisites 

   * **Active Azure Subscription**

   * **Azure Data Lake Storage Gen1**

   * **Azure Data Lake Storage Gen2**. For more details please refer to :link: [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 

   * **Licenses for WANdisco Fusion** that accommodate the volume of data that you want to make available to ADLS Gen2

   * **Azure Linux Virtual Machine** .Please refer here to know :link: [How to create Azure VM](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Bi-directional/Wandisco%20Set%20up%20and%20Installation.md)

   * **Windows SSH client** like [Putty](https://www.putty.org/), [Git for Windows](https://gitforwindows.org/), [Cygwin](https://cygwin.com/), [MobaXterm](https://mobaxterm.mobatek.net/)


## Connect to Wandisco UI
 
 1. **Start** the VM in azure portal
 
    ![image](https://user-images.githubusercontent.com/62353482/80544309-9b64d400-8965-11ea-9b28-a4e4daf05a3d.png)

 2. **Start the Fusion**
 
    Go to **SSH Client**. Connect and run below commands:
 
    ```scala
       cd fusion-docker-compose // Change to the repository directory
  
       ./setup-env.sh // set up script
  
       docker-compose up -d // start the fusion
    ```
 3. **Login to Fusion UI**. Set up ADLS Gen1 and Gen2 storage. :link: [Click here](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Bi-directional/Wandisco%20Set%20up%20and%20Installation.md#adls-gen1-and-gen2-configuration) to know more.
 
 URL --> http://{dnsname}:8081
  
## Create Replication Rule

  On the dashboard, create a HCFS rule with the following parameters:

   * Rule Name = <Give the rule a unique name>
  
   * Path for all storages = /
 
   * Default exclusions
 
   * Preserve HCFS Block Size = False
 
 ![image](https://user-images.githubusercontent.com/62353482/80546359-44153280-896a-11ea-9e12-bb85b6ceeafc.png)
 
  To know more click :link: [how to create rule](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/operation/create-rule)
 
  **Click Finish** and wait for the rule to appear on the dashboard.

## Consistency Check
  
  Once you have created a [replication rule](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/operation/create-rule)
  as per above mentioned steps, run a consistency check to compare the contents between both zones.
  
  On the Rules table, click to View rule.

  1. On the rule page, start consistency check and wait for the Consistency status to update. The more objects contained within the     path, the longer it will take to complete the check.
  
  ![image](https://user-images.githubusercontent.com/62353482/80934228-0e15eb00-8d7c-11ea-8a8c-1975e2c0c9ba.png)


  2. The Consistency Status will determine the next steps:

       * Consistent - no action needed
   
       * Inconsistent - migration required

  Consistency check before migration:
  
  ![image](https://user-images.githubusercontent.com/62353482/80765875-f418a600-8af8-11ea-9129-0791ccfcba12.png)
  
  To know more refer to :link: [Consistency Check using Wandisco fusion](https://docs.wandisco.com/bigdata/wdfusion/2.12/#consistency-check)
 
 :bulb: **Note**: **START CONSISTENCY CHECK** is recommended for small set of data volume.
 
## Migration using LivMigrator

Once HCFS replication rule is created, migration activity can be started using the LiveMigrator. This allows migration of data in a single pass while keeping up with all changes to the source storage(ADLS Gen1). As an outcome data consistency is gauranteed between source and target.

**Note**: The Gen2 is synchronized with Gen1 source using consistency checks and scheduled migrations.

 1. **Get Sample data**
 
 Upload sample data to the ADLS Gen1 storage account, see the [guide](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-get-started-portal#uploaddata) to know more.
 
 2. Place it within the home mount point. 
 
 3. On the Fusion UI dashboard, view the HCFS rule.
 
 ![image](https://user-images.githubusercontent.com/62353482/80547216-8c355480-896c-11ea-8adb-1a58d4e1be6c.png)
 
 
  The overwrite settings needs to be configured. This determines what happens if the LiveMigrator encounters content in the target path with the same name and size.

  * **Skip**:     If the filesize is identical between the source and target, the file is skipped. If it’s a different size, the whole file is replaced.

  * **Overwrite**: Everything is replaced, even if the file size is identical.
        
 4. Start your migration with the following settings:

    Source Zone = adls1
 
    Target Zone = adls2
 
    Overwrite Settings = Skip / Overwrite

 5. Wait until the migration is complete, and check the contents in the ADLS Gen2 container.
 
 :bulb: **NOTE** : A hidden folder :file_folder: .fusion will be present in the ADLS Gen2 path.
                   
 :bulb: **Limitation : Client based replication is not supported by Fusion UI , so replication process here is manually driven.
 
## Managing Replication

   ![image](https://user-images.githubusercontent.com/62353482/80843564-7799cc00-8bb9-11ea-89bb-b7009162f6a1.png)
   
   To know more visit :link: [How to manage replication](https://docs.wandisco.com/bigdata/wdfusion/2.12/#managing-replication)


## Application Update
  
  As part of this, we will [configure services in workloads](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-supported-azure-services) used to point to Gen2 endpoint and update the applications to use Gen2 mount.
 
:bulb: **Note**: We will be covering below azure services

  Azure Services           |        Related articles                                                     
  -------------            |   -------------------------------------------------------------------       
 Azure Data Factory        |   [Load data into Azure Data Lake Storage Gen2 with Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-data-lake-storage-gen2?toc=%2fazure%2fstorage%2fblobs%2ftoc.json)
 Azure Databricks          |   [Use with Azure Databricks](https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/azure-datalake-gen2) <br> [Quickstart: Analyze data in Azure Data Lake Storage Gen2 by using Azure Databricks](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-quickstart-create-databricks-account) <br>                    [Tutorial: Extract, transform, and load data by using Azure Databricks](https://docs.microsoft.com/en-us/azure/azure-databricks/databricks-extract-load-sql-data-warehouse)
 SQL Data Warehouse        |   [Use with Azure SQL Data Warehouse](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-sql-data-warehouse)

 This can be achieved by following phased approach where in the migration of data, work loads and applications will be validated incrementally.
 
 ### Beginning State 
 
 (**Before Migration**)-- The data pipeline is on Gen1
 
 In this state the data pipeline is set to Gen1 which will include the data ingestion from ADB, writing the processed data and loading the processed data to SQL DW from Gen1 
 
 ![image](https://user-images.githubusercontent.com/62353482/81105450-c650aa00-8ec8-11ea-917c-619c6909b2c9.png)

 Sample design:
 
 ![image](https://user-images.githubusercontent.com/62353482/81109171-8a204800-8ece-11ea-9ddc-a8c12007e32a.png)

 All the ADB notebooks will be pointing to Gen1 Mounth path in this state and the data will be ingested, processed and loaded to SQL DW from Gen1.
 
 ### Interim State 
 
 The data pipeline on Gen1 and Gen2 partially
 
 In this state we will start with the migration of the existing Gen1 data to Gen2 using Wandisco fusion. The data pipeline will be set to both Gen1 and Gen2 which will include the data ingestion from ADB and writing the processed data still to Gen1 meanwhile loading the processed data to SQL DW at Gen2.
  
 ![image](https://user-images.githubusercontent.com/62353482/81121499-beeaca00-8ee3-11ea-8c4e-dd6832a42dfe.png)

Follow the steps for the [migration](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Bi-directional/README.md#migration-using-livmigrator) of the data from Gen1 to Gen2 for the Raw and Processed data.

**How to change the mount path**

This will show how to configure the mount path for the work load Azure Databricks which will load processed data to SQL DW at Gen2.

![image](https://user-images.githubusercontent.com/62353482/81126936-b4cfc800-8ef1-11ea-86bc-8550b21a8aa3.png)


 ### Eventual End State   
  
 (**After Migration**) -- The data pipeline moved to Gen2

 This state depicts when all the work loads and applications are moved from Gen1 to Gen2 and the bi directional replication is ready to   be turned off.

 ![image](https://user-images.githubusercontent.com/62353482/81124187-ad0c2580-8ee9-11ea-9ca5-f1e2327dc2ab.png)

 Below are the steps to change the mount path from Gen1 to Gen2 for the Azure Databricks notebook.

 ![image](https://user-images.githubusercontent.com/62353482/81138345-929c7100-8f16-11ea-9e0f-3681d7c76cf1.png)

 Run the master pipeline consisting of all the ADB notebooks and check the data. The ingestion and processing of raw data should take place at Gen2 now along with writing to SQL DW.
 
 **Cutover from Gen1 to Gen2**
 After you're confident that your applications and workloads are stable on Gen2, you can begin using Gen2 to satisfy your business    scenarios. Turn off any remaining pipelines that are running on Gen1 and decommission your Gen1 account.
 
 
  
## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.
  
  
## References

 * :link: [ Wandisco fusion Installation and set up guide ](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/preparation/azure_vm_creation)     
 
 * :link: [Wandisco LivMigrator](https://www.wandisco.com/products/live-migrator)
