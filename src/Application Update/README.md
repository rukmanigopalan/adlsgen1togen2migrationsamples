Application and Workload Update
================================

## Overview

The purpose of this document is to provide steps and ways to migrate the workloads and applications from **Gen1** to **Gen2** after data copy is completed.
  
## Table of contents

  
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [How to Configure and Update Azure Databricks](#how-to-configure-and-update-azure-databricks)
   * [How to Configure and Update Azure Datafactory](#how-to-configure-and-update-azure-datafactory)
   * [How to Configure and update HDIInsight](#how-to-configure-and-update-hdiinsight)
 <!--te-->
 
 ## Prerequisites
 
 **The migration of data from Gen1 to Gen2 should be completed**
  
 ## How to Configure and Update Azure Databricks
   
 **Before the migration**:
 
 **1. Mount configured to Gen1 path**

 ![image](https://user-images.githubusercontent.com/62353482/79265180-90c91b80-7e4a-11ea-9000-0f86aa7c6ebb.png)

 **2. Set up DataBricks cluster for scheduled job run**
  
 Sample snapshot of working code:
 
 ![image](https://user-images.githubusercontent.com/62353482/79017669-c27a7380-7b26-11ea-8e3e-353b7b18e51c.png)
 
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
 
  **1. Stop the trigger to Gen1**
    
  **2. Modify the existing factory by creating new linked service to point to Gen2 storage**.
  
  Go to **-->** Azure Data Factory **-->** Click on Author **-->** Connections **-->** Linked Service **-->** click on New **-->**   Choose Azure Data Lake Storage Gen2 **-->** Click on Continue button

 ![image](https://user-images.githubusercontent.com/62353482/79276321-a3e4e700-7e5c-11ea-9908-b013e2d1e12b.png)


 Provide the details to create new Linked service to point to Gen2 storage account.


![image](https://user-images.githubusercontent.com/62353482/79276405-cd057780-7e5c-11ea-9c31-95dfd26db5b9.png)

  **3. Modify the existing factory by creating new dataset in Gen2 storage**.
   
   Go to **-->** Azure Data Factory **-->** Click on Author **-->** Click on Pipelines **-->** Select the pipeline **-->** Click on Activity **-->** Click on sink tab **-->** Choose the dataset to point to Gen2 
   
   ![image](https://user-images.githubusercontent.com/62353482/79279985-20c78f00-7e64-11ea-9e04-cdfd770d210f.png)


  **4. Click on Publish all**
   
   ![image](https://user-images.githubusercontent.com/62353482/79280406-21145a00-7e65-11ea-8950-bff27882c4de.png)


  **5. Go to Triggers and activate it**.
   
   ![image](https://user-images.githubusercontent.com/62353482/79280526-66388c00-7e65-11ea-895e-915018092b67.png)


   **6. Check for the new files getting generated at the Gen2 root folder path**
  
  ## How to Configure and update HDIInsight
  
   **Prerequisite**
   
   Two HDInsight clusters to be created for each Gen1 and Gen2 storage.
 
   **Before Migration**
   
   The Hive script is mounted to Gen1 endpoint as shown below:
   
   ![image](https://user-images.githubusercontent.com/62353482/83672012-74b04380-a58a-11ea-89b6-54564aeb52f5.png)
   
   **After Migration**
   
   The Hive script is mounted to Gen2 endpoint as shown below:
   
   ![image](https://user-images.githubusercontent.com/62353482/83672806-b8f01380-a58b-11ea-8c16-ae0c662d7de6.png)


