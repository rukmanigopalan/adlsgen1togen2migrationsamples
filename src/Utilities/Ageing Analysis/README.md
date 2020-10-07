## Ageing Analysis Pattern Guide: A quick start template

### Overview

Ageing analysis is a process of Identifying active and inactive folders in an Application from Gen1 Data Lake using directory details such as recent child modification date and size. The purpose of this document is to provide a manual in the form of step by step guide for the ageing analysis which can be done before the actual data migration starts. As such it provides the directions, references, sample code examples of the PowerShell functions and python code snippets been used.

This guide covers the following tasks:
* Inventory collection of application folders
* An insight to ageing analysis using inventory list
* Creation of ageing analysis to single pivot sheet using python snippet

Considerations for using the ageing analysis approach

  ✔️ Planning Cutover from Gen1 to Gen2 for all workloads at the same time.

  ✔️ Determining hot, cold tiers of applications.

  ✔️ Ideal for all applications from Gen1 (Blob Storage) to be migrated or also critical applications where the migration need to be managed.
  
  ✔️ Clean up activity as part of Cost reduction
  
  ## Table of contents

   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [Ageing Analysis Setup](#Ageing-Analysis-Setup)
     * [Get Started](#get-started)
     * [Inventory Collection using PowerShell ](#Inventory-Collection-using-PowerShell)
     * [Ageing Analysis approach](#Ageing-Analysis-approach)
     * [Ageing analysis Application Data sheet](#Ageing-analysis-Application-Data-sheet)
   * [Pivot Sheet using python Snippet](#Pivot-Sheet-using-python-Snippet)
   * [Reach out to us](#reach-out-to-us)
   * [References](#references)
<!--te-->
 
## Prerequisites 

   * **Active Azure Subscription**

   * **Azure Data Lake Storage Gen1**
 
   * **Azure Key Vault**. Required keys and secrets to be configured here.

   * **Service principal** with read, write and execute permission to the resource group, key vault, data lake store Gen1 and data lake store Gen2. 
To learn more, see [create service principal account](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and to provide SPN access to Gen1 refer to [SPN access to Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory)

   * **Windows PowerShell ISE**.

   **Note** : Run as administrator

  ```powershell
      
     //Run below code to enable running PS files
      
     Set-ExecutionPolicy Unrestricted
	
     //Check for the below modules in PowerShell . If not existing, install one by one:
      
     Install-Module Az.Accounts -AllowClobber -Force 
     Install-Module Az.DataFactory -AllowClobber -Force
     Install-Module Az.KeyVault -AllowClobber -Force    
     Install-Module Az.DataLakeStore -AllowClobber -Force
     Install-Module PowerShellGet –Repository PSGallery –Force
     
     //Close the PowerShell ISE and Reopen as administrator. Run the below module       
     
     Install-Module az.storage -RequiredVersion 1.13.3-preview -Repository PSGallery -AllowClobber -AllowPrerelease -Force
  ```

