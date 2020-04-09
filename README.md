# Incremental Copy Pattern Guide : A quick start template

## Overview
The purpose of this document is to provide a manual for the Incremental copy pattern from Azure Data Lake Storage 1 (Gen1) to Azure Data Lake Storage 2 (Gen2) using Azure Data Factory and Powershell. As such it provides the directions, references, sample code examples of the PowerShell functions been used. It is intended to be used in form of steps to follow to implement the solution from local machine.
This guide covers the following tasks:

   * Set up kit for Incremental copy pattern from Gen1 to Gen2 

   * Data Validation between Gen1 and Gen2 

   
### Prerequisites 
You need below for using Migration framework and Data validation :

* **An Azure Subscription**

* **Azure Data Lake Storage Gen1**

* **Azure Data Lake Storage Gen2**. For more details please refer to [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 

* **Service principal account with read / write (contributor) permission on the resource group**. To learn more see [create service principal account](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and to provide SPN access to Gen1 refer to [SPN access to Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory)

* **Windows Powershell ISE**.

  **Note** : Open Powershell as admin

 ```powershell
   // Run below code to enable running PS files

         Set-ExecutionPolicy Unrestricted
	
```
```powershell

   // Run below commands in PS

       Install-Module Az.Accounts -AllowClobber -Force 
       Install-Module Az.DataFactory -AllowClobber -Force
       Install-Module Az.KeyVault -AllowClobber -Force    
       Install-Module Az.DataLakeStore -AllowClobber -Force
       Install-Module PowerShellGet –Repository PSGallery –Force
       Install-Module az.storage -RequiredVersion 1.13.3-preview -Repository PSGallery -AllowClobber -AllowPrerelease -Force

```

## Steps to be followed

### 1. Migration Framework Setup

This step will ensure that the configuration file is ready before running the azure data factory pipeline for incremental copy pattern. 

### 1.1 Download the Github repo to your local machine :

![image](https://user-images.githubusercontent.com/62351942/78865940-6105b800-79f3-11ea-9e8e-a39b597695cd.png)


This folder contains all the source code required for the migration and validation of the gen1 and gen2 data.

 **Note** : To avoid security warning error --> Open the zip folder , right click and Goto properties --> General --> Check unblock option under security section.

The downloaded src folder will contain below listed contents :

![image](https://user-images.githubusercontent.com/62351942/78846271-14ed5000-79c0-11ea-8f83-90cb0925ed22.png)


### Glossary of Contents 

 * **Configuration** : This folder will contain the configuration file [IncrementalLoadConfig.json]( https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/develop/src/Configuration). It will contain all the details of Gen1 and Gen2 ADLS along with source and destination path.

  **Note** : Setting multiple pipelines and activities enables parallelism mechanism.
     
 * **Migration** : This folder will contain all the json files , templates which will be used to create dynamic data factory pipeline      and copy the data from Gen1 path to Gen2 container.

 * **Validation** : This folder will contain powershell scripts which will read the Gen1 and Gen2 data and validate it.
 
 * **StartIncrementalLoadMigration** : The script to invoke the migration acitvity by creating increment pipeline in the data factory.
 
 * **StartIncrementalLoadValidation** : The script to invoke the Validation process which will compare the data between Gen1 and Gen2 
   and generate logs in the output folder under Validation.
   
  **Note** : DataSimulation folder contains the sample data generation scripts used to simulate the data for testing the framework. The [Full load Migration and Validation](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/src/StartFullLoadMigrationAndValidation.ps1) script is to migrate the full data load from Gen1 to Gen2.
  
 
### 1.2 Configuration file set up 

**Path for config file** : [IncrementalLoadConfig.json](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/Src/InventoryInputs.json)

```powershell

//Below is the code snapshot for setting the configuration file to connect to azure data factory

{
  "gen1SourceRootPath" : "https://<<adlsgen1>>.azuredatalakestore.net/webhdfs/v1", // Provide the source Gen1 root path 
  "gen2DestinationRootPath" : "https://<<adlsgen2>>.dfs.core.windows.net", // Provide the Gen2 destination root path
  "tenantId" : "<<tenantId>>", // Provide the tenantId .Where to find TenantId --> Go to Portal.azure.com > Azure Active Directory > Properties. The directory ID it shows there is your tennant ID
  "subscriptionId" : "<<subscriptionId>>", // Provide the SubscriptionId 
  "servicePrincipleId" : "<<servicePrincipleId>>", // Provide the servicePrincipleId
  "servicePrincipleSecret" : "<<servicePrincipleSecret>>", // Provide the servicePrinciplesecret key 
  "factoryName" : "<<factoryName>>", // Give the factory name e.g Gen1ToGen2DataFactory 
  "resourceGroupName" : "<<resourceGroupName>>", // Give the resource group name under which azure data factory pipeline will be created
  "location" : "<<location>>", // Provide the Data factory location 
  "overwrite" : "true", //  True = It will overwrite all the existing data factory   , False = It will skip creating data factory

```

**Setting up and scheduling the Factory pipeline for Incremental copy pattern**

```powershell

//Below is how to configure and schedule the data factory pipeline 

"pipeline": [  
{       
	"pipelineId" : "1",   //  Set distinct pipeline id (Note : Maximum pipelines created under data factory is 40)
	"isChurningOrIsIncremental" : "true",   // Value is set to true for Incremental copy pattern
	"triggerFrequency" : "Minute",   // frequency in units (can be Minute or Hour)
	"triggerInterval" : "15",   // Set the time interval for scheduling the factory pipeline ( Minimum trigger interval Time is 15 minutes )
	"triggerUTCStartTime" : "2020-04-07T13:00:00Z",   // Provide the UTC time to start the factory for Incremental copy 
	"triggerUTCEndTime" : "2020-04-08T13:00:00Z",   // Provide the UTC time to end the factory for Incremental copy (Note : End time > Start Time )
	"pipelineDetails":[			
{	// Activity 1 details below :		
	"sourcePath" : "/AdventureWorks/RawDataFolder/Increment/FactFinance",  // Give the Gen1 source full path 
	"destinationPath" : "AdventureWorks/RawDataFolder/Increment/FactFinance",   // Give the Gen2 destination full path excluding container name 
	"destinationContainer" : "gen1sample"  // Give the Gen2 destination container name 
},
{	// Activity 2 details below :		
	"sourcePath" : "/AdventureWorks/RawDataFolder/Increment/FactInternetSales",  
	"destinationPath" : "AdventureWorks/RawDataFolder/Increment/FactInternetSales", 
	"destinationContainer" : "gen1sample"  
				
```

### 1.3 Azure data factory pipeline execution 

 **Run the script [StartIncrementalLoadMigration](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/src/StartIncrementalLoadMigration.ps1)** to start the Incremental copy process 
 
 ```powershell
 
 // Run the below script in PSE
 
 	$incrementalConfigRootPath = $PSScriptRoot + "\Configuration\IncrementalLoadConfig.json"

 	& "$PSScriptRoot\Migration\PipelineConfig.ps1" -inputConfigFilePath $incrementalConfigRootPath

 	& "$PSScriptRoot\Migration\DataFactory.ps1" -inputConfigFilePath $incrementalConfigRootPath
 
 ```

### 2. Migration status check 

:heavy_check_mark: Check the data factory pipeline creation in ADF  

You can check the pipelines created in the azure data factory like :

![image](https://user-images.githubusercontent.com/62351942/78803126-776c2f00-7973-11ea-94cf-1c0d6de20e64.png)


Once the pipeline run is completed , please check for the files copied to Gen2 container 

![image](https://user-images.githubusercontent.com/62351942/78804420-f0b85180-7974-11ea-8777-c4fd25add31f.png)


:heavy_check_mark: Data (in forms of files and folders) landed to Gen2 container path.


### 3. Data Validation

This step ensures that the incremental data is only migrated from Gen1 to Gen2.To validate this , below are the sequence of scripts being called out :

   *  **ConnectToAzure** : This script will connect to Azure using pre defined and saved subscription details and credentials .
 
   *  **InvokeValidation** : This script will invoke the GetGen1Inventory and GetGen2Inventory scripts and validate the data from both.
 
   *  **GetGen1Inventory** : This script will read the Gen1 file and folder details.
 
   *  **GetGen2Inventory** : This script will read the Gen2 file and folder details.
 
   *  **CompareGen1andGen2** : This script will compare the file and folder details between Gen1 and Gen2 and generate comparison     		report.
   
**Run the script** [StartIncrementalLoadValidation](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/src/StartIncrementalLoadValidation.ps1) in powershell , once the azure data factory pipeline run status is succeeded 

```powershell

// Run the command in Powershell

$incrementalConfigRootPath = $PSScriptRoot + "\Configuration\IncrementalLoadConfig.json"

$outerConfig = Get-Content -Raw -Path $incrementalConfigRootPath | ConvertFrom-Json

$pipelineRunIdDetails = @{}

foreach($eachPipeline in $outerConfig.pipeline)
{       
    $pipelineRunIdDetails.Add($eachPipeline.pipelineId,"")
}

& "$PSScriptRoot\Validation\InvokeValidation.ps1" -inputConfigFilePath $incrementalConfigRootPath -pipelineIds $pipelineRunIdDetails

```
  
### 4. Data Comparison Report

Once the data between Gen1 and Gen2 is compared and validated , the result summary is generated in CSV file into the folder Output as below :

![image](https://user-images.githubusercontent.com/62351942/78856445-ad44fe00-79db-11ea-89e7-c4f89dd62701.png)

The CSV file will show the matched and unmatched records with file name , Gen1 File path , Gen2 file path ,Gen1 file size ,Gen2 File size and Ismatching status

![image](https://user-images.githubusercontent.com/62351942/78856720-51c74000-79dc-11ea-8b20-a718fc35ae36.png)

**Note** : IsMatching status = Yes (For matched records ) and No (Unmatched records)

### 5. Application Migration check 

This check will ensure after the Incremental copy pattern is completed and data is validated , the mount path in the Azure data bricks script is pointed to the Gen2 path.


* **Stop the job scheduler** 

```powershell
// Get Gen1 mountName 

mountName = 'AdventureWorksProd'

```

* **Change and configure the mount path to Gen2 storage**

```powershell

// Change the mount path and point to Gen2 storage 

     	# DBTITLE 1,Mounting the Gen2 storage
	mountName = 'AdventureWorksProd'  // **Note : Keep the same mountName for Gen1 and Gen2 
	configs_Blob = {"fs.azure.account.key.destndatalakestoregen2.blob.core.windows.net": dbutils.secrets.get(scope =   	"Gen2migrationSP", key = "Gen2AccountKey")}
	mounts = [str(i) for i in dbutils.fs.ls('/mnt/')]
	if "FileInfo(path='dbfs:/mnt/" +mountName + "/', name='" +mountName + "/', size=0)" in mounts : 
  	dbutils.fs.unmount("/mnt/"+mountName+"/")
  	print("Mounting the storage")
  	dbutils.fs.mount(
  	source = "wasbs://fis@destndatalakestoregen2.blob.core.windows.net/AdventureWorks", // Provide the Gen2 container name and the root folder name (fis = Gen2 container name and root folder name = AdventureWorks
  	mount_point = "/mnt/"+mountName+"/",
  	extra_configs = configs_Blob)
  	print(mountName + " got mounted")
  	print("Mountpoint:", "/mnt/" +mountName + "/")
  
```
**Note** : Please refer to the [MountConfiguration](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/src/DataSimulation/MountConfiguration.py) script for more reference.

* **Re schedule the job scheduler**
* **Check for the new files getting generated at Gen2 root folder path**

The above steps will conclude that the mount path is changed and pointing to Gen2 now. The data will start flowing to Gen2 .


## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

### References

[Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)

