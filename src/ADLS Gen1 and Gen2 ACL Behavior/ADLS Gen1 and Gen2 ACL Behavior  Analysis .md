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
GetFileStatus and GetAclStatus API do not mandate any minimum permission on a path in Hadoop and need only traversal (X) permission till the parent path. Hence a user with no permission can successfully run these APIs on account root | A minimum of RX permission was introduced on the account root so that a user with no permission fails to get a view of contents on account root | Like Hadoop. A user who doesn’t have any permission on container root can successfully run GetFileStatus and GetAclStatus operations |
    
## 2.	OID-UPN CONVERSION  ##
Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Some APIs accept identity inputs in UPN format (SetAcl, ModifyAclEntries, RemoveAclEntries) and few based on a request queryparam can provide identity info in UPN format (GetAclStatus, Liststatus and GetFileStatus) within response. | OID <-> UPN conversion is supported for Users, Service principals and groups (in case of groups, as there is no UPN, conversion is done to Display name property) | Supports only User OID-UPN conversion. As per a discussion, this is because of a known issue in conversion for service principal and groups.  UPN or Display Name is not unique to one service principal or group respectively. Hence the derived OID could end up being an unintended identity |


## 3. RBAC USER ROLE SIGNIFICANCE  ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
RBAC roles and access control | All users in RBAC Owner role are superusers.Refer for more details [Access control in Azure Data Lake Storage Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-access-control). All other users (non-superusers), need to have permission that abides by File Folder ACL | Users can be provided different roles that govern their permissions for write, read and delete. And this takes precedence to the ACLs sent on individual file or folder. Refer for more details [Access control in Azure Data Lake Storage Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-access-control). For a user to be superuser, they need to be given “Storage blob data owner” RBAC role |


## 4.	STORE DEFAULT PERMISSION ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
During file and directory creation, there are scenarios where a store default permission is taken into the permission computation | It is fixed to 770 (considering a fixed umask of 007 at server) | If default acl is present on the parent, default permissions is 777 for directory and 666 for file. If default acl is not present on the parent, a umask of 027  gets applied on the above mentioned default permissions of file/directory | 


## 5.	USER PROVIDED PERMISSION ON FILE/DIRECTORY CREATION ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Users can provide an explicit permission that needs to be set during file/directory creation | File/Directory is created, and the final permission will be same as the user provided permission | (Considering the case where no user request input for umask is present) File/Directory is created, and the final permission will be computed as [user provided permission ^ umask (which is currently 027 in Gen2 code)] |



## 6.	SET PERMISSION WITH NO PERMISSION PROVIDED ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Setpermission Api is called with permission = null/space or the permission parameter is not present | Store default of 770 is set for both file and directory | Gen2 will return bad request as permission header is a necessity |


## 7.	NESTED FILE OR DIRECTORY CREATION FOR NON-OWNER USER ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
When a non-owner create a nested file or directory i.e. dir1 exists and user desires to create dir2/dir3/a.txt or dir2/dir3/dir4 when non owner user has wx permission on parent | Gen1 adds wx for owner user | Gen2 doesn’t add wx  In the sub directory |
 
    

## 8.	UMASK SUPPORT ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
UMASK is a client concept where new file or directory permissions can be controlled | Clients need to apply umask on the permission they expect on new file/directory before sending the request to server. Server doesn’t provide explicit support in accepting umask as an input | Clients can provide umask as means of request query params during file and directory creations. If client does not pass umask parameter, 027 default umask in Gen2 store will get applied |


## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

## References

* :link: [ACL in ADLS Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-access-control)
* :link: [ACL in ADLS Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-access-control)
* :link: [Securing data stored in Azure Data Lake Storage Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-secure-data)
