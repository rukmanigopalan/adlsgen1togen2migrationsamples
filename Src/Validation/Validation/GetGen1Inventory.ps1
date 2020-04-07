##################################################################################################################################
# A script to get all gen1 files to array
# 
# Prerequisite:
#  1. need to have the azure subscription
#  2. Azure Datalake storage gen1 account
#  3. Service principal that has permission on the subscription
#  4. All Azure login information such as tenantId, service principal need to store in Azure keyvault. 
# Steps the operation does:
#  1. Connect to Azure using password and tenantid 
#  2. Get files in gen1 
#  3. The Output will be array of object in memory 
#  4. Starting from the Gen1FilePath, get all the folders and subfolders recursively and stored them in the array.
# Sample Usage:
#
#$gen1FileDetails = C:\Users\v-wiya\Documents\GetGen1Inventory.ps1 -subscriptionId  -keyVaultName "Gen2MigrationKV" -tenantIdKVSecreatName "72f988bf-86f1-41af-91ab-2d7cd011db47" -keyVaultServicePrincipalSecretName "Zjl/J.vWJyQ50u]@HOOeVkQwRPKiNw31" -keyVaultServicePrincipalIdSecretName "55b7545f-661a-4710-b336-ea1e3c474d09" -FilePath $filepath -AccountName "sourcedatalakestoregen1" -cutofftime "1/1/1970"
#
#
# 
param(
[string]$subscriptionId,
[string]$filePath,
[string]$accountName,
[string]$cutofftime
)

function GetGen1DataList {
    [cmdletBinding()]
    param(
        [string] $filePath, 
        [string] $accountName, 
        [string] $cutofftime
        )

    #convert cutofftime to int
    if ($cutofftime -eq '')
    {
    $cutoffint=0;
    }
    else{
    $cutoffint=[int64]((get-date $cutofftime)-(get-date "1/1/1970")).TotalMilliseconds;
    }
    #set up array to hold DataLakeStore items
    $files=New-Object Collections.Generic.List[Microsoft.Azure.Commands.DataLakeStore.Models.DataLakeStoreItem];
    if ($filePath -ne '' -and $accountName -ne ''){
        $childItems = Get-AzDataLakeStoreChildItem -AccountName $accountName -Path $filePath;
        foreach ($childItem in $childItems) {
            switch ($childItem.Type) {
                "FILE" {
                    if ($childItem.modificationtime -gt $cutoffint){
                        $files+=$childItem; 
                        }
                }
                "DIRECTORY" {
                    #if the file is directory, then go find the files of the directory
                    $files+=GetGen1DataList $childItem.path $accountName $cutofftime;
                }
            }
        }       
    }
    else{
        throw 'cannot find filepath or account';
    }  
    return $files;
}

# connect to azure using service principal and select the subscription to use
& "$PSScriptRoot\ConnectToAzure.ps1" -subscriptionId $subscriptionId
  
#call function
GetGen1DataList $filePath $accountName $cutofftime;



