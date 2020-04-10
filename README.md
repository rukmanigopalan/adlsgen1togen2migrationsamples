Incremental Copy Pattern Guide : A quick start template
===================================================

### Overview

The purpose of this document is to provide a manual for the Incremental copy pattern from Azure Data Lake Storage 1 (Gen1) to Azure Data Lake Storage 2 (Gen2) using Azure Data Factory and Powershell. As such it provides the directions, references, sample code examples of the PowerShell functions been used. It is intended to be used in form of steps to follow to implement the solution from local machine.
This guide covers the following tasks:

   * Set up kit for Incremental copy pattern from Gen1 to Gen2 

   * Data Validation between Gen1 and Gen2 post migration  
   
 
### Prerequisites 

* **Azure Data Lake Storage Gen1**

* **Azure Data Lake Storage Gen2**. For more details please refer to [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 

* **Azure Key Vault** 

* **Service principal** with read,write and execute permission to the resource group,key vault,data lake store Gen1 and data lake store Gen2 . 
To learn more see [create service principal account](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and to provide SPN access to Gen1 refer to [SPN access to Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory)

* **Windows Powershell ISE**.

  **Note** : Run as administrator

 ```powershell
   // Run below code to enable running PS files
      Set-ExecutionPolicy Unrestricted
	
   // Check for the below modules in PS . If not existing,Install one by one :
      Install-Module Az.Accounts -AllowClobber -Force 
      Install-Module Az.DataFactory -AllowClobber -Force
      Install-Module Az.KeyVault -AllowClobber -Force    
      Install-Module Az.DataLakeStore -AllowClobber -Force
      Install-Module PowerShellGet –Repository PSGallery –Force
      Install-Module az.storage -RequiredVersion 1.13.3-preview -Repository PSGallery -AllowClobber -AllowPrerelease -Force

  ```

### Migration Framework Setup

1. **Download the migration source code from [Github repository](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples) to local machine** :

![image](https://user-images.githubusercontent.com/62351942/78950970-50058700-7a85-11ea-9485-9cd605b1e0fe.png)


**Note** : To avoid security warning error --> Right click on the zip folder downloaded --> Goto properties --> General --> Check unblock option under security section.

The downloaded zip folder will contain below listed contents under src :

![image](https://user-images.githubusercontent.com/62351942/78948773-4debfa00-7a7e-11ea-952a-52071e5924c4.png)



* **Configuration** : This folder will have the configuration file [IncrementalLoadConfig.json](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Configuration/IncrementalLoadConfig.json) and all the details of resource group and subscription along with source and destination path of ADLS Gen1 and Gen2.
     
* **Migration** : Contains the json files , templates to create dynamic data factory pipeline and copy the data from Gen1 to Gen2.
 
* **Validation** : Contains the powershell scripts which will read the Gen1 and Gen2 data and validate it post migration to generate migration report.
 
* **[StartIncrementalLoadMigration](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/StartIncrementalLoadMigration.ps1)** : Script to invoke the migration activity by creating increment pipeline in the data factory.
 
* **[StartIncrementalLoadValidation](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/StartIncrementalLoadValidation.ps1)** : The script to invoke the Validation process to compare the data between Gen1 and Gen2 post migration to generate logs in the output folder under Validation.
   
 **Note** : DataSimulation folder contains the sample data generation scripts used to simulate the data for testing the framework. The  [Full load Migration and Validation](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/StartFullLoadMigrationAndValidation.ps1) script is to migrate the full data load from Gen1 to Gen2.
  
 
 2. **Set up the Configuration file to connect to azure data factory** :

* **Prerequisites** : Make an entry of Gen2 connection string with below highlighted name in key vault.

![image](https://user-images.githubusercontent.com/62353482/78953831-f1dda180-7a8e-11ea-82e9-07aa66fd2856.png)



```powershell

// Below is the code snapshot for setting the configuration file to connect to azure data factory

	  "gen1SourceRootPath" : "https://<<Enter the Gen1 source root path>>.azuredatalakestore.net/webhdfs/v1", 
	  "gen2DestinationRootPath" : "https://<<Enter the Gen2 detsination root path>>.dfs.core.windows.net", 
	  "tenantId" : "<< Enter the tenantId>>", 
	  "subscriptionId" : "<<Enter the subscriptionId>>", 
	  "servicePrincipleId" : "<<Enter the servicePrincipleId>>", 
	  "servicePrincipleSecret" : "<<Enter the servicePrincipleSecret Key>>", 
	  "factoryName" : "<<Enter the factoryName>>", 
	  "resourceGroupName" : "<<Enter the resourceGroupName under which the azure data factory pipeline will be created>>",
	  "location" : "<<Enter the location>>", 
	  "overwrite" : "Enter the value" //  True = It will overwrite the existing data factory ,False = It will skip creating data factory

```

 **Scheduling the Factory pipeline for Incremental copy pattern**

```powershell

	  "pipelineId" : "Enter disticnt pipeline id eg 1,2,3,..40", 
	  "isChurningOrIsIncremental" : "true",
	  "triggerFrequency" : "Provide the frequency in Minute or Hour",
	  "triggerInterval" : "Enter the time interval for scheduling (Minimum trigger interval time = 15 minute  ",
	  "triggerUTCStartTime" : "Enter UTC time to start the factory for Incremental copy pattern .Eg 2020-04-09T18:00:00Z",
	  "triggerUTCEndTime" : "Enter the UTC time to end the factory for Incremental copy pattern. Eg 2020-04-10T13:00:00Z",
	  "pipelineDetails":[		
	  
  // Activity 1 //
  	  "sourcePath" : "Enter the Gen1 full path. Eg: /path-name",
	  "destinationPath" : "Enter the Gen2 full path.Eg: path-name",
	  "destinationContainer" : "Enter the Gen2 container name"
  // Activity 2 //
   	  "sourcePath" : "Enter the Gen1 full path. Eg: /path-name",
	  "destinationPath" : "Enter the Gen2 full path.Eg: path-name",
	  "destinationContainer" : "Enter the Gen2 container name"
  
  // Note : Maximum activities per pipeline is 40
  
```

 **Note** Path to [IncrementalLoadConfig.json](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/src/Configuration/IncrementalLoadConfig.json)script
 
### 3. Azure data factory pipeline creation and execution 

 Run the script [StartIncrementalLoadMigration.ps1](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/src/StartIncrementalLoadMigration.ps1) to start the Incremental copy process 
 
 ![image](https://user-images.githubusercontent.com/62351942/78946426-8a682780-7a77-11ea-973b-8f7cad667295.png)

 
### 4. Azure Data factory pipeline monitoring  

 The data factory pipeline will be created in Azure Data Factory and can be monitored as below :
 
 ![image](https://user-images.githubusercontent.com/62351942/78946760-6fe27e00-7a78-11ea-915e-e716fb1d1c78.png)

 
 ### Data Validation

This step ensures that the incremental data is only migrated from Gen1 to Gen2.To validate this , below are the sequence of scripts being called out :

   *  **ConnectToAzure** : Connects to Azure using pre defined and saved subscription details and credentials .
 
   *  **InvokeValidation** : Invokes the Gen1 Inventory and Gen2 Inventory scripts and validate the data from both.
 
   *  **GetGen1Inventory** : This script will read the Gen1 file and folder details.
 
   *  **GetGen2Inventory** : This script will read the Gen2 file and folder details.
 
   *  **CompareGen1andGen2** : This script will compare the Gen1 and Gen2 folder and file details and generate output     		report post migration.
   
**Run the script** [StartIncrementalLoadValidation.ps1](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/src/StartIncrementalLoadValidation.ps1) in powershell , once the azure data factory pipeline run status is succeeded 

![image](https://user-images.githubusercontent.com/62351942/78947387-0c595000-7a7a-11ea-9d8d-b4b73b8bd976.png)


### 4. Data Comparison Report

Once the Gen1 and Gen2 data is compared and validated , the result summary is generated in CSV file into the Output folder as below :

![image](https://user-images.githubusercontent.com/62351942/78856445-ad44fe00-79db-11ea-89e7-c4f89dd62701.png)

The CSV file will show the matched and unmatched records with file name , Gen1 File path , Gen2 file path ,Gen1 file size ,Gen2 File size and Ismatching status

![image](https://user-images.githubusercontent.com/62351942/78914832-da2afc80-7a3f-11ea-8e94-b788ee2bd710.png)


**Note** : IsMatching status = Yes (For matched records ) and No (Unmatched records)

### 5. Application update  

This section makes sure that post Incremental copy pattern is complete and data is validated , the mount path in the work loads is configured to Gen2 endpoint. 

* **Stop the job scheduler** 

* **Unmount the Gen1 path**

* **Mount to Gen2 storage**

* **Re schedule the job scheduler**

* **Check for the new files getting generated at Gen2 root folder path**

The above steps will conclude that the mount path is changed and pointing to Gen2 now. The data will start flowing to Gen2 .


## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

### References

[Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)

