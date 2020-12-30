Gen1 and Gen2 ACL Behavior Analysis
================================================

## Overview

Azure Data Lake Storage is Microsoft's optimized storage solution for big data analytics workloads. ADLS Gen2 is the combination of the current ADLS Gen1 and Blob storage.  
Azure Data Lake Storage Gen2 is built on Azure Blob storage and provides a set of capabilities dedicated to big data analytics. Data Lake Storage Gen2 combines features from Azure Data Lake Storage Gen1, such as file system semantics, directory, and file level security and low cost scalability, tiered storage, high availability/disaster recovery capabilities from Azure Blob storage. 
Azure Data Lake Storage Gen1 implements an access control model that derives from HDFS, which in turn derives from the POSIX access control model.
Azure Data Lake Storage Gen2 implements an access control model that supports both Azure role-based access control (Azure RBAC) and POSIX-like access control lists (ACLs).
This article summarizes the behavioral differences of the access control models for Data Lake Storage Gen1 and Gen2.

 ## Table of contents

   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [ACL behavior in ADLS Gen1 and Gen2 ](#ACL-Behavior-in-ADLS-Gen1-and-Gen2 )
   * [Reach out to us](#reach-out-to-us)
   * [References](#references)
<!--te-->
 
## Prerequisites 

   * **Active Azure Subscription**
   * **Azure Data Lake Storage Gen1 and Gen2**
   * **Azure Key Vault**. Required keys and secrets to be configured here.
   * **Service principal** with read, write and execute permission to the resource group, key vault, data lake store Gen1 and data lake store Gen2. 
To learn more, see [create service principal account](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and to provide SPN access to Gen1 refer to [SPN access to Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory)
   * **Java Development Kit (JDK 7 or higher, using Java version 1.7 or higher)** for Filesystem operations on Azure Data Lake Storage Gen1 and Gen2
   
   
## ACL Behavior in ADLS Gen1 and Gen2 
## 1.	ACCOUNT ROOT PERMISSIONS ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- | --------- |
Check GetFileStatus and GetAclStatus APIs with or without permissions on root Account path  | Permission required on Account root- RX(minimum) or  RWX , to get an account root content view | A user with or without permissions on container root can view account root content
    
## 2.	OID-UPN CONVERSION  ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Check the identity inputs for UPN format APIs  (Eg:GetAclStatus, Liststatus ,GetFileStatus) and OID format APIs (Eg:SetAcl, ModifyAclEntries, RemoveAclEntries)   | OID <-> UPN conversion is supported for Users, Service principals and groups Note: For groups, as there is no UPN, conversion is done to Display name property | Supports only User OID-UPN conversion.  Note:  For service principal or group ,as UPN or Display Name is not unique, the derived OID could end up being an unintended identity  |


## 3. RBAC USER ROLE SIGNIFICANCE  ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
RBAC roles and access control | All users in RBAC Owner role are superusers. All other users (non-superusers), need to have permission that abides by File Folder ACL 
Refer for more details https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-access-control | All users in ‘RBAC -Storage blob data owner’ role are superusers 
All other users can be provided different roles(contributor, reader etc.) that govern their read ,write and delete permissions, this takes precedence to the ACLs sent on individual file or folder.  Refer for more details https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-access-control  |


## 4.	STORE DEFAULT PERMISSION ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Check if default permission is considered during file and directory creation  | Permissions for an item(file/directory) cannot be inherited from the parent items. 
Reference: https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-access-control | IPermissions are only inherited if default permissions have been set on the parent items before the child items have been created. Reference: https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-access-control  | 


## 5.	USER PROVIDED PERMISSION ON FILE/DIRECTORY CREATION ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Create a file/directory with explicit permission | File/Directory is created, and the final permission will be same as the user provided permission  | (File/Directory is created, and the final permission will be computed as [user provided permission ^ umask (currently 027 in code)]  |


## 6.	SET PERMISSION WITH NO PERMISSION PROVIDED ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Setpermission Api is called with permission = null/space and permission parameter not present  | A default value of 770 is set for both file and directory  | Gen2 will return bad request as permission parameter is mandatory |


## 7.	NESTED FILE OR DIRECTORY CREATION FOR NON-OWNER USER ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Check if wx permission on parent is copied to nested file/directory when non-owner creates it. (i.e. dir1 exists and user desires to create dir2/dir3/a.txt or dir2/dir3/dir4) | Adds wx permissions for owner in the sub directory  | Doesn’t add wx permissions in the sub directory  |
 
    

## 8.	UMASK SUPPORT ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Permissions of file/directory can be controlled by applying UMASK on it.  |Client needs to apply umask on the permission on new file/directory before sending the request to server. Note: Server doesn’t provide explicit support in accepting umask as an input | Clients can provide umask as request query params during file and directory creations. 
 If client does not pass umask parameter, default umask 027 will be applied on file/directory  |


## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

## References

* :link: [ACL in ADLS Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-access-control)
* :link: [ACL in ADLS Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-access-control)
* :link: [Securing data stored in Azure Data Lake Storage Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-secure-data)
