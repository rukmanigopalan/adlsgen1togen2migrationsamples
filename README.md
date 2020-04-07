# Incremental Copy Pattern Guide : A quick start template

## Overview
The purpose of this document is to provide a manual for the Incremental copy pattern from Azure Data Lake Storage 1 (Gen1) to Azure Data Lake Storage 2 (Gen2) using Azure Data Factory and Powershell. As such it provides the directions, references, sample code examples of the PowerShell functions been used. It is intended to be used in form to steps to follow to implement the solution from local machine.
This guide covers the following tasks:

:heavy_check_mark: Set up for migration of incremental data from Gen1 to Gen2 

:heavy_check_mark: Enumerating Gen1 and Gen2 data into CSV

:heavy_check_mark: Data Validation and Comparison between Gen1 and Gen2 data using CSV

##  Getting Started 

### Prerequisites 
You need below:

:heavy_check_mark:Azure subscription 

:heavy_check_mark:Resource group 

:heavy_check_mark:Azure Storage account with Data Lake Storage Gen1 and Gen2 enabled

:heavy_check_mark:Service principal with permission on the subscription 

:heavy_check_mark:Azure Data Factory(v2) 

:heavy_check_mark: Windows Powershell ISE.

## Steps to be followed

### 1. Migration Pipeline Setup
This step will ensure that the configuration file is ready before running the azure data factory pipeline for incremental copy pattern. 
The config file sample format is available on GitHub in [config file sample](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/develop/Src/Migration/).

#### Download the repo to your local machine :
![image](https://user-images.githubusercontent.com/62353482/78593702-e4f54f80-77fb-11ea-8bfb-2ecc8e8ed757.png)

Open the zip folder , right click and Goto properties :

![image](https://user-images.githubusercontent.com/62353482/78596270-56cf9800-7800-11ea-9d8d-c4767a6b0ee6.png)

Check the unblock option in the security to avoid below run time error 

![image](https://user-images.githubusercontent.com/62353482/78596476-b29a2100-7800-11ea-8bb3-4f551a412dc4.png)





#### 


### Data Validation

Post Incremental copy process is completed , the Gen1 file and folder details are written into CSV. 


### Comparison Report


### Application Migration check 



## Error Handling

## References

[Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)

