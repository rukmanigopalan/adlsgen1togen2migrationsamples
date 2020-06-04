Lift and Shift Copy Pattern Guide: A quick start template
=========================================================

## Overview

The purpose of this document is to provide a manual in form of step by step guide for the lift and shift copy pattern from Gen1 to Gen2 storage using Azure Data Factory and PowerShell. As such it provides the directions, references, sample code examples of the PowerShell functions been used. 

This guide covers the following tasks:

   * Set up kit for lift and shift copy pattern from Gen1 to Gen2 

   * Data Validation between Gen1 and Gen2 post migration  
   
   * Application update for the workloads
   
 Considerations for using the lift and shift pattern
 
   ✔️ Cutover from Gen1 to Gen2 for all workloads at the same time.

   ✔️ Expect downtime during the migration and the cutover period.

   ✔️ Ideal for pipelines that can afford downtime and all apps can be upgraded at one time.
  
  
## Table of contents

   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [Limitations](#limitations)
   * [Migration Framework Setup](#migration-framework-setup)
   * [Data Validation](#data-validation)
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

* **Windows PowerShell ISE**.

  **Note** : Run as administrator

 ```powershell
   // Run below code to enable running PS files
      Set-ExecutionPolicy Unrestricted
	
   // Check for the below modules in PowerShell . If not existing, install one by one:
      Install-Module Az.Accounts -AllowClobber -Force 
      Install-Module Az.DataFactory -AllowClobber -Force
      Install-Module Az.KeyVault -AllowClobber -Force    
      Install-Module Az.DataLakeStore -AllowClobber -Force
      Install-Module PowerShellGet –Repository PSGallery –Force
   // Close the PowerShell ISE and Reopen as administrator. Run the below module       
      Install-Module az.storage -RequiredVersion 1.13.3-preview -Repository PSGallery -AllowClobber -AllowPrerelease -Force

  ```

## Limitations

This version of code will have below limitations:

   * Gen1 & Gen2 should be in same subscription
   * Supports only for single Gen1 source and Gen2 destination
   * Code Developed and Supported only in Windows PowerShell ISE
      
## Migration Framework Setup

1. **Download the migration source code from [Github repository](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/src/) to local machine**:

![image](https://user-images.githubusercontent.com/62351942/78950970-50058700-7a85-11ea-9485-9cd605b1e0fe.png)


**Note**: To avoid security warning error --> Right click on the zip folder downloaded --> Go to --> Properties --> General --> Check unblock option under security section. Unzip and extract the folder.

The folder **src/Lift and Shift/** will contain below listed contents:

![image](https://user-images.githubusercontent.com/62353482/83551794-b1623900-a4bd-11ea-9b84-f2885567bc92.png)

* **Application**: This folder will have sample code for Mount path configuration.

* **Configuration**: This folder will have the configuration file [FullLoadConfig.json](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/master/src/Lift%20and%20Shift/Configuration) and all the required details of resource group and subscription along with source and destination path of ADLS Gen1 and Gen2.
     
* **Migration**: Contains the templates to create dynamic data factory pipeline and copy the data from Gen1 to Gen2.
 
* **Validation**: Contains the PowerShell scripts which will read the Gen1 and Gen2 data and write the comparison report post migration.
 
 * **[StartFullLoadMigrationAndValidation](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/master/src/Lift%20and%20Shift)** : Script to invoke the full load Migration and Validation process to compare the data between Gen1 and Gen2 post migration and generate summary report.
  
 
 2. **Set up the Configuration file to connect to azure data factory**:

 **Important Prerequisite**: 

   * Provide Service principal access to configure key vault as below:
   
   ![image](https://user-images.githubusercontent.com/62353482/79594064-3e2d7080-8091-11ea-872e-d69052da0ff7.png)
     
   * Make an entry of Gen2 connection string in the key vault as shown below :

   ![image](https://user-images.githubusercontent.com/62353482/78953831-f1dda180-7a8e-11ea-82e9-07aa66fd2856.png)
     
 ```powershell

   // Below is the code snapshot for setting the configuration file to connect to azure data factory:

	  "gen1SourceRootPath" : "https://<<Enter the Gen1 source root path>>.azuredatalakestore.net/webhdfs/v1", 
	  "gen2DestinationRootPath" : "https://<<Enter the Gen2 destination root path>>.dfs.core.windows.net", 
	  "tenantId" : "<<Enter the tenantId>>", 
	  "subscriptionId" : "<<Enter the subscriptionId>>", 
	  "servicePrincipleId" : "<<Enter the servicePrincipleId>>", 
	  "servicePrincipleSecret" : "<<Enter the servicePrincipleSecret Key>>", 
	  "factoryName" : "<<Enter the factoryName>>", 
	  "resourceGroupName" : "<<Enter the resourceGroupName under which the azure data factory pipeline will be created>>",
	  "location" : "<<Enter the location>>", 
	  "overwrite" : "Enter the value" //  True = It will overwrite the existing data factory ,False = It will skip creating data factory

  ```

  **Setting up the factory pipeline for lift and shift copy pattern**

  ```powershell

	  "pipelineId": "<<Enter the pipeline number. Eg: 1,2"
	  "fullLoad": "true"
	  
          // Activity 1 //
  	  "sourcePath" : "Enter the Gen1 full path. Eg: /path-name",
	  "destinationPath" : "Enter the Gen2 full path.Eg: path-name",
	  "destinationContainer" : "Enter the Gen2 container name"
          // Activity 2 //
   	  "sourcePath" : "Enter the Gen1 full path. Eg: /path-name",
	  "destinationPath" : "Enter the Gen2 full path.Eg: path-name",
	  "destinationContainer" : "Enter the Gen2 container name"
   
   ```
 
  **NOTE**: Please note the **destinationPath** string will not be having Gen2 container name. It will have the file path same as Gen1.  
   Path to [FullLoadConfig.json](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Lift%20and%20Shift/Configuration/FullLoadConfig.json) script for more reference.
 
 3. **Azure data factory pipeline creation and execution**

  Run the script [StartFullLoadMigrationAndValidation.ps1](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Lift%20and%20Shift/StartFullLoadMigrationAndValidation.ps1) to start the full load    migration and validation process.
 
 ![image](https://user-images.githubusercontent.com/62353482/83554216-4adf1a00-a4c1-11ea-9ea4-ae9284e678c0.png)
 
 
 4. **Azure Data factory pipeline monitoring**

  The pipeline will be created in Azure data factory and can be monitored in below way:
 
  ![image](https://user-images.githubusercontent.com/62353482/83555204-c8eff080-a4c2-11ea-8162-a8f86b5e9e9e.png)

 
 ## Data Validation 

  The [script](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Lift%20and%20Shift/StartFullLoadMigrationAndValidation.ps1) will trigger the data  validation between Gen1 and Gen2 once the migration is completed in above step.
  
 ![image](https://user-images.githubusercontent.com/62353482/78954784-01121e80-7a92-11ea-8799-1b075e06b29d.png)
  
     
 ### Data Comparison Report

  Once the Gen1 and Gen2 data is compared and validated, the result is generated in CSV file into the **Output** folder as below:

  ![image](https://user-images.githubusercontent.com/62353482/83555444-26843d00-a4c3-11ea-9fac-5bd0760aca0b.png)

  The CSV file will show the matched and unmatched records with Gen1 and Gen2 file path, Gen1 and Gen2 file size and Ismatching status.

  ![image](https://user-images.githubusercontent.com/62353482/83555536-44ea3880-a4c3-11ea-90d0-ccae337fb531.png)


  **Note**: IsMatching status = Yes (For matched records ) and No ( For Unmatched records)

 ## Application update  

 This step will configure the path in the workloads to Gen2 endpoint. 
 
 Refer to [Application and Workload Update](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/master/src/Application%20Update) on how to plan and migrate workloads and applications to Gen2.
 

 # Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

## References

* [Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)
* [Azure Databricks guide](https://docs.databricks.com/data/data-sources/azure/azure-storage.html)
