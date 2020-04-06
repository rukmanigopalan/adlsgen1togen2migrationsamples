##################################################################################################################################
# A script to analyze the Gen2 files system for all the folders and files.
# 
# Prerequisite:
#  1. need to have the azure subscription
#  2. ReourceGroup
#  3. Azure Storage account and Azure storage container
#  4. Service principal that has permission on the subscription
#  5. All Azure login information such as tenantId, service principal need to store in Azure keyvault. 
# Steps the operation does:
#  1. Connect to Azure using the information stored in keyvault
#  2. Get Azure account to analyze the file system
#  3. the output of the analysis of the file system will be stored in the csv files. the path where the files will be stores will be read from the parameter.
#      remove if the files are existed and create the files and folders
#  4. Starting from the Ge2FilePath, get all the folders and subfolders recursively and stored them in the array.
#  5. Looping through the array, analyze the information of the folder or file and write the output of the file/folder information in the appropriate csv file.
# Sample Usage:
#
# .\InventoryGen2FileFolder.ps1 -subscriptionId "<subId>" -keyVaultName "Gen2MigrationKV" -keyVaultTenantIdSecretName "TenantId" -keyVaultServicePrincipalSecretName "SPNSecret" -keyVaultServicePrincipalIdSecretName "SPNId" -storageAccountName "destndatalakestoregen2"  -resourceGroupName "Gen1ToGen2Migration" -gen2FilesystemName "gen1sample" -gen2FilePath "AdventureWorks/RawDataFolder" -filePathToWriteGen2folderInformation "c:\ps-test\scripts\InsertGen2Folder.csv" -filePathToWriteGen2fileInformation "c:\ps-test\scripts\InsertGen2files.csv"
#
#
# 

Param(  
   [string]$subscriptionId,
   [string]$keyVaultName,
   [string]$keyVaultTenantIdSecretName,
   [string]$keyVaultServicePrincipalSecretName,
   [string]$keyVaultServicePrincipalIdSecretName,
   [string]$storageAccountName,
   [string]$resourceGroupName,   
   [string]$gen2FilesystemName,
   [string]$gen2FilePath,
   [string]$filePathToWriteGen2folderInformation,
   [string]$filePathToWriteGen2fileInformation
   )

 Import-Module Az.Storage -RequiredVersion 1.13.1 

    # connect to azure using service principal and select the subscription to use
 .\ConnectToAzure.ps1 -subscriptionId $subscriptionId -keyVaultName $keyVaultName -tenantIdKVSecreatName $keyVaultTenantIdSecretName -servicePrincipalSecreatKVSecreatName $keyVaultServicePrincipalIdSecretName -servicePrincipalIDKVSecreatName $keyVaultServicePrincipalIdSecretName
  
    # connect to Azure datalake gen2 storage
    $ctx = ConnectToGen2 $resourceGroupName $storageAccountName       
    #$vaultName='Gen2MigrationKV';

    createInsertFiles $filePathToWriteGen2folderInformation $filePathToWriteGen2fileInformation
    #Get all child items recursively. this will return a list of all child item including folders and files in all directories and sub directories            
    $gen2ChildItems = Get-AzDataLakeGen2ChildItem -Context $ctx -FileSystem $gen2FilesystemName -Path $gen2FilePath  -Recurse

    # loop through each child item and write the information of the folder/file with its ACL info to the specific database table
    foreach ($ChildItem in $gen2ChildItems)
    {
        if($ChildItem.IsDirectory)
        {   
            # childItem is a folder and insert it the Gen2Folder table           
            $time=get-date;
            $insertString = "{0},{1},{2},{3},{4},{5},{6}" -f $ChildItem.Name, $ChildItem.Path, $ChildItem.BlobType, $ChildItem.ContentType, $ChildItem.Length, $time, $time;
            Add-Content $filePathToWriteGen2folderInformation $insertString                        
        }
        else 
        {
            $time=get-date;
            # childItem is a file and insert it the Gen2File table             
            $insertString = "{0},{1},{2},{3},{4},{5},{6},{7}" -f [io.path]::GetFileNameWithoutExtension($ChildItem.Name), $ChildItem.Path, $ChildItem.BlobType, $ChildItem.Length, $ChildItem.Length, $ChildItem.LastModified.DateTime, $time, $time;            
            Add-Content $filePathToWriteGen2fileInformation $insertString           
        }
    }    


function createInsertFiles
{
  param([string] $folderInformationFileNamePath,
        [string] $fileInformationFileNamePath
        )  

  Remove-Item $folderPath + "\" + $folderInformationFileName
  Remove-Item $folderPath + "\" + $fileInformationFileName
  
  $folderInformationFolderPath = [System.IO.Path]::GetDirectoryName($folderInformationFileNamePath)
  $fileInformationFolderPath = [System.IO.Path]::GetDirectoryName($fileInformationFileNamePath)
  $folderInformationFilename = Split-Path $folderInformationFileNamePath -leaf
  $fileInformationFileName = Split-Path $fileInformationFileNamePath -leaf
  New-Item -Path $folderInformationFolderPath -Name $folderInformationFilename -ItemType "file" -Value "FolderName,FolderPath,AssignedFolderType,IdentifiedFolderType,FolderSizeInBytes,RowInsertedDate,RowUpdatedDate"
  New-Item -Path $fileInformationFolderPath -Name $fileInformationFileName -ItemType "file" -Value "FileName,FilePath,FileBlobType,BlockSize,FileSizeInBytes,filemodificationtime,RowInsertedDate,RowUpdatedDate"
 
}

function ConnectToGen2
{
    param(
        [string] $resourceGroupName,
        [string] $storageAccountName)

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
    # Retrieve the context.
    $ctx = $storageAccount.Context            
    return $ctx
}

