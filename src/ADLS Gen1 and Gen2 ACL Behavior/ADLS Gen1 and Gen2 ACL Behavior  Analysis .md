Gen1 and Gen2 ACL Behavior Analysis
================================================

## Overview

Azure Data Lake Storage is Microsoft's optimized storage solution for big data analytics workloads.  Current Azure Storage ADLS Gen1 enhanced and developed ADLS Gen2. ADLS Gen2 is the combination of the current ADLS (now called Gen1) and Blob storage.  
Azure Data Lake Storage Gen2 is built on Azure Blob storage and provides a set of capabilities dedicated to big data analytics. Data Lake Storage Gen2 combines features from Azure Data Lake Storage Gen1, such as file system semantics, directory, and file level security and scale with low-cost, tiered storage, high availability/disaster recovery capabilities from Azure Blob storage. 
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
   
## ACL Behavior in ADLS Gen1 and Gen2 
## 1.	ACCOUNT ROOT PERMISSIONS ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- | --------- |
GetFileStatus and GetAclStatus API do not mandate any minimum permission on a path in Hadoop and need only traversal (X) permission till the parent path. Hence a user with no permission can successfully run these APIs on account root | A minimum of RX permission was introduced on the account root so that a user with no permission fails to get a view of contents on account root | Like Hadoop. A user who doesn’t have any permission on container root can successfully run GetFileStatus and GetAclStatus operations |

***TEST STEPS:***

**GEN1 Behavior Testing Steps**
1.	validate getFileStatus,getACLStatus on ADLS Gen1 directory/file by using Java SDK
    *	Step1: Connect ADLS gen1 with service principal (SPN)
    *	Step2 : SPN should have read and execute permissions on directory/file on which getAClStatus/ getFileStatus API calls
    
**GEN2 Behavior Testing Steps**

1.  validate getFileStaus,getAclStatus on  ADLS Gen2 by using SDK
     *	Step1: Connect ADLS gen2 with service principal (SPN)
     *	Step2: SPN should have read and execute permissions on directory/file on which getAClStatus/ getFileStatus API calls. 

## 2.	OID-UPN CONVERSION  ##
Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
Some APIs accept identity inputs in UPN format (SetAcl, ModifyAclEntries, RemoveAclEntries) and few based on a request queryparam can provide identity info in UPN format (GetAclStatus, Liststatus and GetFileStatus) within response. | OID <-> UPN conversion is supported for Users, Service principals and groups (in case of groups, as there is no UPN, conversion is done to Display name property) | Supports only User OID-UPN conversion. As per a discussion, this is because of a known issue in conversion for service principal and groups.  UPN or Display Name is not unique to one service principal or group respectively. Hence the derived OID could end up being an unintended identity |

***TEST STEPS:***

**GEN1 Behavior Testing Steps**
1.	validate GetAclStatus or Liststatus or GetFileStatus with OID =false and UPN =true 
    *	Step1: Connect ADLS gen1 with service principal (SPN)
    *	Step2 : Check GetAclStatus or Liststatus or GetFileStatus with OID =false and UPN =true and vice -versa
2. Test the same for AAD group and user
    
**GEN2 Behavior Testing Steps**
1. validate GetAclStatus or Liststatus or GetFileStatus with OID =false and UPN =true 
     *	Step1: Connect ADLS gen2 with service principal (SPN)
     *	Step2: : Check GetAclStatus or Liststatus or GetFileStatus with OID =false and UPN =true and vice -versa. 
2. Test the same for AAD group and user



## 3. RBAC USER ROLE SIGNIFICANCE  ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
RBAC roles and access control | All users in RBAC Owner role are superusers.Refer for more details [Access control in Azure Data Lake Storage Gen1](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-access-control). All other users (non-superusers), need to have permission that abides by File Folder ACL | Users can be provided different roles that govern their permissions for write, read and delete. And this takes precedence to the ACLs sent on individual file or folder. Refer for more details [Access control in Azure Data Lake Storage Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-access-control). For a user to be superuser, they need to be given “Storage blob data owner” RBAC role |

***TEST STEPS:***

**GEN1 Behavior Testing Steps**
1.	Perform read or write operation on Gen1 with different roles 
    *	Step1: Connect ADLS gen1 with service principal (SPN)
    *	Step2 : Perform read or write operation on Gen1 file  with connected SPN as owner  of  the file
2. Test the same for superuser, other users
    
**GEN2 Behavior Testing Steps**
1. Perform read or write operation on Gen2 with different roles
     *	Step1: Connect ADLS gen2 with service principal (SPN)
     *	Step2: : Perform read or write operation on Gen2 file with connected SPN as owner of  the file
2. Test the same for superuser, other users

## 4.	STORE DEFAULT PERMISSION ##

Scenario  | GEN1 Behavior | GEN2 Behavior |
------------- | ------------- |-----------|
During file and directory creation, there are scenarios where a store default permission is taken into the permission computation | It is fixed to 770 (considering a fixed umask of 007 at server) | If default acl is present on the parent, default permissions is 777 for directory and 666 for file. If default acl is not present on the parent, a umask of 027  gets applied on the above mentioned default permissions of file/directory | 

***TEST STEPS:***

**GEN1 Behavior Testing Steps**
1.	Create a directory on Gen1 via ADB/Portal and check permissions 
    *	Step1: Connect ADLS gen1 with service principal (SPN)
    *	Step2 : Create a directory on Gen1/ via ADB/Portal and check permissions
2. Test the same for superuser, other users
    
**GEN2 Behavior Testing Steps**
1. Create a directory on Gen2 via ADB/Portal and check permissions
     *	Step1: Connect ADLS gen2 with service principal (SPN)
     *	Step2: : Create a directory on Gen2/ via ADB/Portal and check permissions
2. Test the same for superuser, other users



## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

## References

* :link: [ACL in ADLS Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-access-control)
