Bi-directional sync pattern Guide: A quick start template
===================================================

## Overview

This manual will introduce [Wandisco](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/preparation/azure_vm_creation) as a recommended tool to set up bi-directional sync between Gen1 and Gen2 using the Replication feature. Below will be covered as part of this guide:
  
  *  Live replication from Gen1 to Gen2
  
  *  Data Consistency Check
  
  *  Application update for ADF, ADB and SQL DWH workloads 

Considerations for using the bi-directional sync pattern:

✔️ Ideal for complex scenarios that involve a large number of pipelines and dependencies where a phased approach might make more sense.

✔️ Migration effort is high, but it provides side-by-side support for Gen1 and Gen2.
  
 :bulb: **Note** : The guide will be focussing on the migration of data from ADLS Gen1 as source to ADLS Gen2 as destination using the Wandisco replication .
 
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
 
 **Click Finish**

## Consistency Check
  
  Once you have created a [replication rule](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/operation/create-rule)
  as per above mentioned steps, run a consistency check to compare the contents between all zones.
  
  On the Rules table, click to View rule.

  1. On the rule page, start consistency check and wait for the Consistency status to update. The more objects contained within the     path, the longer it will take to complete the check.

  2. The Consistency Status will determine the next steps:

       * Consistent - no further action is required.
   
       * Inconsistent - consider migration

  Consistency check before migration:
  
  ![image](https://user-images.githubusercontent.com/62353482/80765875-f418a600-8af8-11ea-9129-0791ccfcba12.png)
  
  To know more refer to :link: [Consistency Check using Wandisco fusion](https://docs.wandisco.com/bigdata/wdfusion/2.12/#consistency-check)
 
## Migration using LivMigrator

Once HCFS replication rule is created, migration activity can be started using the LiveMigrator. This allows migration of data in a single pass while keeping up with all changes to the source storage(ADLS Gen1). The outcome is guaranteed data consistency between source and target. As data is being migrated it is immediately ready to be used, without interruption.

 1. **Get Sample data**
 
 Upload sample data to your ADLS Gen1 storage account, see the [guide](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-get-started-portal#uploaddata) to know more.
 
 2. Place it within the Home Mount Point. 
 
 3. On the Fusion UI dashboard, view the HCFS rule.
 
 ![image](https://user-images.githubusercontent.com/62353482/80547216-8c355480-896c-11ea-8adb-1a58d4e1be6c.png)
 
  The overwrite settings needs to be configured. This determines what happens if the LiveMigrator encounters content in the target  path with the same name and size.

     * **Skip** - If the filesize is identical between the source and target, the file is skipped. If it’s a different size, the whole file is replaced.

     * **Overwrite** - Everything is replaced, even if the file size is identical.
        
 4. Start your migration with the following settings:

    Source Zone = adls1
 
    Target Zone = adls2
 
    Overwrite Settings = Skip

 5. Wait until the migration is complete, and check the contents of your ADLS Gen2 container.
 
 :bulb: **NOTE** : A hidden folder :file_folder: .fusion will be present in the ADLS Gen2 path.

## Managing Replication

   ![image](https://user-images.githubusercontent.com/62353482/80671739-a439d080-8a5f-11ea-8b68-bfee84d8e6af.png)
   
   To know more visit :link: [How to manage replication](https://docs.wandisco.com/bigdata/wdfusion/2.12/#managing-replication)


## Application Update
  
  As part of this, we will [configure services in workloads](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-supported-azure-services) used to point to Gen2 endpoint.
 
:bulb: **Note**: We will be covering below azure services

  Azure Services           |        Related articles                                                     
  -------------            |   -------------------------------------------------------------------       
 Azure Data Factory        |   [Load data into Azure Data Lake Storage Gen2 with Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-data-lake-storage-gen2?toc=%2fazure%2fstorage%2fblobs%2ftoc.json)
 Azure Databricks          |   [Use with Azure Databricks](https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/azure-datalake-gen2) <br> [Quickstart: Analyze data in Azure Data Lake Storage Gen2 by using Azure Databricks](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-quickstart-create-databricks-account) <br>                    [Tutorial: Extract, transform, and load data by using Azure Databricks](https://docs.microsoft.com/en-us/azure/azure-databricks/databricks-extract-load-sql-data-warehouse)
 SQL Data Warehouse        |   [Use with Azure SQL Data Warehouse](https://docs.microsoft.com/en-us/azure/data-factory/load-azure-sql-data-warehouse)
  
  
  
  
  
  
  
  
  
  
## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.
  
  
## References

 * :link: [ Wandisco fusion Installation and set up guide ](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/preparation/azure_vm_creation)     
 
 * :link: [Wandisco LivMigrator](https://www.wandisco.com/products/live-migrator)
