Bi-directional sync pattern Guide: A quick start template
===================================================

## Overview

This manual will introduce [Wandisco](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/preparation/azure_vm_creation) as a recommended tool to set up bi-directional sync between Gen1 and Gen2. Below will be covered as part of this guide:
  
  *  Live Migration from Gen1 to Gen2
  
  *  Data Consistency Check
  
  *  Application update for ADF, ADB and SQL DWH

Considerations for using the bi-directional sync pattern:

✔️ Ideal for complex scenarios that involve a large number of pipelines and dependencies where a phased approach might make more sense.

✔️ Migration effort is high, but it provides side-by-side support for Gen1 and Gen2.
  
 ## Table of contents
   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [Connect to Wandisco UI](#connect-to-wandisco-ui)
   * [Create Replication Rule](#create-replication-rule)
   * [Migration using LivMigrator](#migration-using-livmigrator)
   * [Consistency check](#consistency-check)
   * [Reach out to us](#reach-out-to-us)
   * [References](#references)
 <!--te-->
 
 ## Prerequisites 

* **Active Azure Subscription**

* **Azure Data Lake Storage Gen1**

* **Azure Data Lake Storage Gen2**. For more details please refer to [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 

* **Licenses for WANdisco Fusion** that accommodate the volume of data that you want to make available to ADLS Gen2

* **Azure Linux Virtual Machine** .Please refer here to know [How to create Azure VM](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Bi-directional/Wandisco%20Set%20up%20and%20Installation.md)

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
 3. **Login to Fusion UI**. Create account and set up ADLS Gen1 and Gen2 storage. [Click here](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Bi-directional/Wandisco%20Set%20up%20and%20Installation.md#adls-gen1-and-gen2-configuration) to know more.
 
    URL --> http://<dnsname>:8081
  
 4. 
  
 


## Create Replication Rule

## Migration using LivMigrator

Follow the steps below to demonstrate the migration of data from your ADLS Gen1 to Gen2 storage.

## Consistency Check
  
  
  
  
  
  
  
  
  
## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.
  
  
## References

 * [ Wandisco fusion Installation and set up guide ](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/preparation/azure_vm_creation)
   
   * [How to use SSH key with Windows on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows)
