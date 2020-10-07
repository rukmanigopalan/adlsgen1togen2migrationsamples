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

   * **Azure Data Lake Storage Gen2**. For more details please refer to [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 
