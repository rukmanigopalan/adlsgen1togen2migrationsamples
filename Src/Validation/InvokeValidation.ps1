
#Install-Module -Name Az.Storage -RequiredVersion 1.13.0
#Import-module az.storage -RequiredVersion 1.13.0
#Import-Module az.datalakestore

$fileRootPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf('\'))
$sourceConfigFullPath = $fileRootPath+ "\Migration\InventoryInputs.json"
$sourceConfigData = Get-Content -Raw -Path $sourceConfigFullPath | ConvertFrom-Json

$subscriptionId = $sourceConfigData.subscriptionId
$resourceGroupName = $sourceConfigData.resourceGroupName
$tenantId = $sourceConfigData.tenantId
$keyVaultName = $sourceConfigData.keyVaultName
$spnId = $sourceConfigData.servicePrincipleId
$spnSecret = $sourceConfigData.servicePrincipleSecret
$gen1SourceRootPath = $sourceConfigData.gen1SourceRootPath
$gen2SourceRootPath = $SourceConfigData.gen2SourceRootPath
$gen1AccountName = $gen1SourceRootPath.Substring(8,$gen1SourceRootPath.indexOf(".")-8)
$gen2AccountName = $gen2SourceRootPath.Substring(8,$gen2SourceRootPath.indexOf(".")-8)
$ValidationResultFolder = $PSScriptRoot


foreach($eachPipeline in $sourceConfigData.pipeline)
{    
    foreach($eachPath in $eachPipeline.pipelineDetails)
    {
        $gen1Path = $eachPath.sourcePath
        $gen2Path = $eachPath.destinationPath
        $gen2Container = $eachPath.destinationContainer
        $ResultFilePath = $ValidationResultFolder + $gen1Path.Replace("/","-") + ".csv"

        $Gen1FileDetails = & "$PSScriptRoot\GetGen1Inventory.ps1" `
        -subscriptionId $subscriptionId  `
        -filePath $gen1Path  `
        -accountName $gen1AccountName      

     
        $gen2FileDetails = & "$PSScriptRoot\GetGen2Inventory.ps1"  `
        -subscriptionId $subscriptionId `
        -storageAccountName $gen2AccountName `
        -resourceGroupName $resourceGroupName `
        -gen2FilesystemName $gen2FileSystemName `
        -gen2FilePath $gen2Path

        & "$PSScriptRoot\CompareGen1AndGen2.ps1" `
        -gen1Files $Gen1FileDetails `
        -gen2Files $gen2FileDetails `
        -ValidationResultFilePath $ResultFilePath `
        
    }
}