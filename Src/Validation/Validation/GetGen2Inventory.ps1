##################################################################################################################################
# A script to analyze the Gen2 files system for all the files.
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
#      remove if the files are existed and create the files
#  4. Starting from the Ge2FilePath, get all the folders and subfolders recursively and stored them in the array.
#  5. Looping through the array, analyze the information of the file and write the output of the file information in the appropriate csv file.
# Sample Usage:
#
# .\InventoryGetGen2Inventory.ps1 -subscriptionId "<subId>" -keyVaultName "Gen2MigrationKV" -keyVaultTenantIdSecretName "TenantId" -keyVaultServicePrincipalSecretName "SPNSecret" -keyVaultServicePrincipalIdSecretName "SPNId" -storageAccountName "destndatalakestoregen2"  -resourceGroupName "Gen1ToGen2Migration" -gen2FilesystemName "gen1sample" -gen2FilePath "AdventureWorks/RawDataFolder"
#
#
# 

Param(  
   [string]$subscriptionId,
   [string]$storageAccountName,
   [string]$resourceGroupName,   
   [string]$gen2FilesystemName,
   [string]$gen2FilePath  
   )

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

# connect to azure using service principal and select the subscription to use
& "$PSScriptRoot\ConnectToAzure.ps1" -subscriptionId $subscriptionId

# connect to Azure datalake gen2 storage
$ctx = ConnectToGen2 $resourceGroupName $storageAccountName    

$files=New-Object Collections.Generic.List[Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureDataLakeGen2Item];
#Get all child items recursively. this will return a list of all child item          
$gen2ChildItems = Get-AzDataLakeGen2ChildItem -Context $ctx -FileSystem $gen2FilesystemName -Path $gen2FilePath  -Recurse

# loop through each child item and write the information of the file into CSV
foreach ($childItem in $gen2ChildItems)
{
    if(!$childItem.IsDirectory)
    {   
       $files +=$childItem                      
    }        
}

return $files; 


