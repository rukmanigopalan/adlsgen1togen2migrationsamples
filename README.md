# Incremental Copy Pattern Guide : A quick start template

## Overview
The purpose of this document is to provide a manual for the Incremental copy pattern from Azure Data Lake Storage 1 (Gen1) to Azure Data Lake Storage 2 (Gen2) using Azure Data Factory and Powershell. As such it provides the directions, references, sample code examples of the PowerShell functions been used. It is intended to be used in form of steps to follow to implement the solution from local machine.
This guide covers the following tasks:

   * Set up kit for Incremental copy pattern from Gen1 to Gen2 

   * Data Validation of Gen1 and Gen2 

   
### Prerequisites 
You need below for using Migration framework and Data validation :

* **An Azure account with an active subscription** 

* **Azure Storage account with Data Lake Storage Gen1**. 

* **Resource group to hold the storage account**

 * **Azure Storage account with Data Lake Storage Gen2**.For more details please refer to [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 

* **Service principal account with read / write permission on the subscription**. To learn more see [create service principal account](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and to provide SPN access to Gen1 refer to [SPN access to Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory)

* **Azure Data Factory(v2)** 

* **Windows Powershell ISE**.

  
```scala
// Run below commands in PS

       Install-Module Az.Accounts -AllowClobber -Force 
       Install-Module Az.DataFactory -AllowClobber -Force
       Install-Module Az.KeyVault -AllowClobber -Force    
       Install-Module Az.DataLakeStore -AllowClobber -Force
       Install-Module PowerShellGet –Repository PSGallery –Force
       Install-Module az.storage -RequiredVersion 1.13.3-preview -Repository PSGallery -AllowClobber -AllowPrerelease -Force

```
**Note** : Open Powershell as admin

```scala
// Run below code to enable running PS files

         Set-ExecutionPolicy Unrestricted
	
```

## Steps to be followed

### 1. Migration Framework Setup
This step will ensure that the configuration file is ready before running the azure data factory pipeline for incremental copy pattern. 
The config file sample format is available on GitHub in [config file sample](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/develop/Src/Migration/).

### 1.1 Download the repo to your local machine :
![image](https://user-images.githubusercontent.com/62353482/78593702-e4f54f80-77fb-11ea-8bfb-2ecc8e8ed757.png) 

 **Note** : To avoid security warning error --> Open the zip folder , right click and Goto properties --> General --> Check unblock option under security section.

The downloaded migration folder will contain below listed contents :

![image](https://user-images.githubusercontent.com/62351942/78715961-02491d00-78d3-11ea-89e5-5132cf49898d.png)

### Glossary of Contents 

 * **DataFactoryV2Template** : This folder contain all the json templates which is being used for creating dynamic azure data factory.

 *  **InventoryInput.json** : This config file contains all the details of gen1 and gen2 ADLS. In this we have to list all the source and      destination folders,which is being used to create data factory pipeline activities.Config pipeline elements contain number of            pipelines to be created. We can have one time full load pipelines and incremental pipelines.

     **Note** : Setting multiple pipelines and activities enables parallelism mechanism.

 *  **InvokeMethod.ps1**: This powershell script will execute PipelineConfig.ps1 and DataFactory.ps1

 *  **PipelineConfig.ps1** : This powershell script will create all the required json input data, which is being used in Datafactory.ps1      powershell.This will dynamically create the json file considering all the required inputs from InventoryInput.json file.

  * **DataFactory.ps1** : This powershell will create the linked services, datasets and pipeline in sequence order,based on the input         provided in InventoryInput.json

### 1.2 Configuration file set up 

**Path for config file** : [InventoryInput.json](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/Src/Migration/InventoryInputs.json)

```scala

//Below is the code snapshot for setting the configuration file for each variable

{
  "gen1SourceRootPath" : "https://<<adlsgen1>>.azuredatalakestore.net/webhdfs/v1", // Provide the source Gen1 root path 
  "gen2SourceRootPath" : "https://<<adlsgen2>>.dfs.core.windows.net", // Provide the Gen2 source root path
  "tenantId" : "<<tenantId>>", // Provide the tenantId .Where to find TenantId --> Go to Portal.azure.com > Azure Active Directory > Properties. The directory ID it shows there is your tennant ID
  "subscriptionId" : "<<subscriptionId>>", // Provide the SubscriptionId 
  "servicePrincipleId" : "<<servicePrincipleId>>", // Provide the servicePrincipleId
  "servicePrincipleSecret" : "<<servicePrincipleSecret>>", // Provide the servicePrinciplesecret key 
  "factoryName" : "<<factoryName>>", // Give the factory name e.g Gen1ToGen2DataFactory 
  "resourceGroupName" : "<<resourceGroupName>>", // Give the resource group name 
  "location" : "<<location>>", // Provide the Data factory location 
  "overwrite" : "true", // default 

```

**Setting up and scheduling the Factory pipeline for Incremental copy pattern**

```scala

//Below is how to configure and schedule the data factory pipeline 

 "pipeline": [  
	{
		"pipelineId" : "1",   // Set this value between 1 and 50 to start factory and run in parallel  
		"isChurningOrIsIncremental" : "true",   // Value is set to true for Incremental copy pattern
		"triggerFrequency" : "Minute",   // frequency in units 
		"triggerInterval" : "15",   // Set the time interval for scheduling 
		"triggerUTCStartTime" : "2020-04-07T13:00:00Z",   // Provide the UTC time to start the factory 
		"pipelineDetails":[			
			{			
				"sourcePath" : "/AdventureWorks/RawDataFolder/Increment/FactFinance",  // Give the Gen1 source path for first folder 
				"destinationPath" : "AdventureWorks/RawDataFolder/Increment/FactFinance",   // Give the Gen2 landing path
				"destinationContainer" : "gen1sample"  // Give the destination container name 
			},
			{			
				"sourcePath" : "/AdventureWorks/RawDataFolder/Increment/FactInternetSales",  // Give the Gen1 source path for second folder 
				"destinationPath" : "AdventureWorks/RawDataFolder/Increment/FactInternetSales", // Give the Gen2 landing path 
				"destinationContainer" : "gen1sample"  // Give the destination container name
				
// The source path , destination path and destination container name will be repeated for all Gen1 folders existing in the path

```

### 1.3 Azure data factory pipeline execution 

 **Run the [InvokeMethod script](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/develop/Src/Migration/InvokeMethod.ps1)**
 
``` scala

//Run the below script in Powershell

	$PSScriptRoot

	& "$PSScriptRoot\PipelineConfig.ps1"

	& "$PSScriptRoot\DataFactory.ps1"

```


### 2. Post Migration Checks 

:heavy_check_mark: Check the data factory pipeline creation in ADF site 
You can check the pipelines created in the azure data factory like :

![image](https://user-images.githubusercontent.com/62351942/78803126-776c2f00-7973-11ea-94cf-1c0d6de20e64.png)


Once the pipeline run is completed , please check for the files copied to Gen2 container 


![image](https://user-images.githubusercontent.com/62351942/78804420-f0b85180-7974-11ea-8777-c4fd25add31f.png)


:heavy_check_mark: Data (in forms of files and folders) landed to Gen2 path.



You can check the Gen1 files 


### 3. Data Validation

This step ensures that the new data is only migrated from Gen1 to Gen2.To validate the same process ,below is the sequence of functions being called out :

   *  **ConnectToAzure** : This script will connect to Azure using pre defined and saved subscription details and credntials .
 
   *  **InvokeValidation** : This script will invoke the GetGen1Inventory and GetGen2Inventory scripts and validate the data from both.
 
   *  **GetGen1Inventory** : This script will read the Gen1 file and folder details and save to buffer.
 
   *  **GetGen2Inventory** : This script will read the Gen2 file and folder details and save to buffer.
 
   *  **CompareGen1andGen2** : This script will compare the file and folder details between Gen1 and Gen2 and generate comparison report. 
   
  


### 4. Comparison Report


### 5. Application Migration check 

This check will ensure after the Incremental copy pattern is completed and data is validated , the mount path in the Azure data bricks is pointed to the Gen2 path.

**Change and configure the mount path to Gen2 storage**

``scala
// Change the mount path and point to Gen2 storage 

      # DBTITLE 1,Mounting the Gen2 storage
mountName = 'AdventureWorks'
configs_Blob = {"fs.azure.account.key.destndatalakestoregen2.blob.core.windows.net": dbutils.secrets.get(scope = "Gen2migrationSP", key = "Gen2AccountKey")}

mounts = [str(i) for i in dbutils.fs.ls('/mnt/')]
if "FileInfo(path='dbfs:/mnt/" +mountName + "/', name='" +mountName + "/', size=0)" in mounts: 
  dbutils.fs.unmount("/mnt/"+mountName+"/")
  print("Mounting the storage")
  dbutils.fs.mount(
  source = "wasbs://gen1sample@destndatalakestoregen2.blob.core.windows.net/", // Give the Gen2 storage path here 
  mount_point = "/mnt/"+mountName+"/",
  extra_configs = configs_Blob)
  print(mountName + " got mounted")
  print("Mountpoint:", "/mnt/" +mountName + "/")
  
```


**5.4** Re schedule the migration pipeline as per above path 


## Reach out to us

### You found a bug or want to propose a feature?

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

### References

[Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)

