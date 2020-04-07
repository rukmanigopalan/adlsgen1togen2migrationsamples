$fileRootPath = $PSScriptRoot+"\"
$sourceConfigFullPath = $fileRootPath + "InventoryInputs.json"

$sourceConfigData = Get-Content -Raw -Path $sourceConfigFullPath | ConvertFrom-Json

$subscriptionId = $sourceConfigData.subscriptionId
$resourceGroupName = $sourceConfigData.resourceGroupName
$tenantId = $sourceConfigData.tenantId
$keyVaultName = $sourceConfigData.keyVaultName

function ExportCsv{
    param([system.collections.icollection]$files, [string] $path )
    $files|export-csv -path $path
}

foreach($eachPipeline in $sourceConfigData.pipeline)
{    
    foreach($eachPath in $eachPipeline.pipelineDetails)
    {
        $gen1Path = $eachPath.sourcePath
        $gen2Path = $eachPath.destinationPath
        $gen2Container = $eachPath.destinationContainer

        $gen1FileDetails = & "$PSScriptRoot\GetGen1Inventory.ps1" -subscriptionId $subscriptionId -filePath $gen1Path -accountName "sourcedatalakestoregen1" -cutofftime "1/1/1970"
        $gen2FileDetails = & "$PSScriptRoot\GetGen2Inventory.ps1" -subscriptionId $subscriptionId -storageAccountName "destndatalakestoregen2" -resourceGroupName $resourceGroupName -gen2FilesystemName $gen2Container -gen2FilePath $gen2Path

        $dataDiff = & "$PSScriptRoot\CompareGen1AndGen2.ps1" -gen1Files $gen1FileDetails -gen2Files $gen2FileDetails

        ExportCsv -files $dataDiff -path $fileRootPath"compare1.csv"
    }
}


#$gen1FileDetails = C:\Users\v-wiya\Documents\GetGen1Inventory.ps1 -subscriptionId  -keyVaultName "Gen2MigrationKV" -tenantIdKVSecreatName "72f988bf-86f1-41af-91ab-2d7cd011db47" -keyVaultServicePrincipalSecretName "Zjl/J.vWJyQ50u]@HOOeVkQwRPKiNw31" -keyVaultServicePrincipalIdSecretName "55b7545f-661a-4710-b336-ea1e3c474d09" -FilePath $filepath -AccountName "sourcedatalakestoregen1" -cutofftime "1/1/1970"
#$gen2FileDetails = .\GetGen2Inventory.ps1 -subscriptionId $subscriptionId -keyVaultName "Gen2MigrationKV" -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" -clientSecret "Zjl/J.vWJyQ50u]@HOOeVkQwRPKiNw31" -clientId "55b7545f-661a-4710-b336-ea1e3c474d09" -storageAccountName "destndatalakestoregen2" -resourceGroupName "Gen1ToGen2Migration" -gen2FilesystemName "gen1sample" -gen2FilePath $filepath
#$gen1FileDetails = & "$PSScriptRoot\GetGen1Inventory.ps1" -subscriptionId $subscriptionId -keyVaultName "Gen2MigrationKV" -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" -clientSecret "Zjl/J.vWJyQ50u]@HOOeVkQwRPKiNw31" -clientId "55b7545f-661a-4710-b336-ea1e3c474d09" -filePath $filepath -accountName "sourcedatalakestoregen1" -cutofftime "1/1/1970"
#$gen2FileDetails = & "$PSScriptRoot\GetGen2Inventory.ps1" -subscriptionId $subscriptionId -keyVaultName "Gen2MigrationKV" -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" -clientSecret "Zjl/J.vWJyQ50u]@HOOeVkQwRPKiNw31" -clientId "55b7545f-661a-4710-b336-ea1e3c474d09" -storageAccountName "destndatalakestoregen2" -resourceGroupName "Gen1ToGen2Migration" -gen2FilesystemName "gen1sample" -gen2FilePath $filepath 


#$diff = C:\Users\v-wiya\Documents\CompareGen1AndGen2.ps1 -Gen1Files $gen1FileDetails -Gen2Files $gen2FileDetails -outputPath "C:\Users\v-wiya\Documents\diff.csv"
#


