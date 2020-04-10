
# This script gets the Gen1, Gen2 file details, compares it and export result to CSV 

Param(  
    [string]$inputConfigFilePath,
    [hashtable] $pipelineIds
)

Import-module az.storage -RequiredVersion 1.13.0
Import-Module az.datalakestore

$sourceConfigFullPath = $inputConfigFilePath
$sourceConfigData = Get-Content -Raw -Path $sourceConfigFullPath | ConvertFrom-Json

$subscriptionId = $sourceConfigData.subscriptionId
$resourceGroupName = $sourceConfigData.resourceGroupName
$gen1SourceRootPath = $sourceConfigData.gen1SourceRootPath
$gen2SourceRootPath = $SourceConfigData.gen2DestinationRootPath
$gen1AccountName = $gen1SourceRootPath.Substring(8, $gen1SourceRootPath.indexOf(".") - 8)
$gen2AccountName = $gen2SourceRootPath.Substring(8, $gen2SourceRootPath.indexOf(".") - 8)
$currentDate = (Get-Date).ToString("yyyyMMddHHmm")
$validationResultFolder = $PSScriptRoot + "\Output\" + $currentDate + "\"
$LogPath = $PSScriptRoot + "\Log\" + "ExecutionLog_" + $CurrentDate + ".txt" 

Start-Transcript -Path $LogPath -Append

If (!(Test-path $validationResultFolder)) {
    New-Item -ItemType Directory -Force -Path $validationResultFolder
    Write-Host "`nCreated below directory to store validation result files `n" -ForegroundColor Green
    Write-Host "$($validationResultFolder)"
}

# Get the Gen1 and Gen2 paths configured in Config file and compare details, export result to CSV

foreach ($eachPipeline in $sourceConfigData.pipeline) {    
    if ($pipelineIds.ContainsKey($eachPipeline.pipelineId)) {
        foreach ($eachPath in $eachPipeline.pipelineDetails) {
            $gen1Path = $eachPath.sourcePath
            $gen2Path = $eachPath.destinationPath
            $gen2Container = $eachPath.destinationContainer
            $resultFilePath = $validationResultFolder + $gen1Path.Replace("/", "-") + ".csv"
	    		    	
            Write-Host "`n"
            Write-Host "Getting ADL Gen1 File details" -ForegroundColor Yellow
            Write-Host "ADL Gen1 Account: $($gen1AccountName)" 
            Write-Host "ADL Gen1 Root Path: $($gen1Path)" 
            Write-Host "`n"
          
            $gen1FileDetails = @(& "$PSScriptRoot\GetGen1Inventory.ps1" -subscriptionId $subscriptionId -filePath $gen1Path -accountName $gen1AccountName -ErrorAction Stop) 
                     
            $gen2FileDetails = @(& "$PSScriptRoot\GetGen2Inventory.ps1" -subscriptionId $subscriptionId -storageAccountName $gen2AccountName -resourceGroupName $resourceGroupName -gen2FilesystemName $gen2Container -gen2FilePath $gen2Path)
            
            & "$PSScriptRoot\CompareGen1AndGen2.ps1" -gen1Files $gen1FileDetails -gen2Files $gen2FileDetails -ValidationResultFilePath $resultFilePath `
            
        }
    }
}

Stop-Transcript