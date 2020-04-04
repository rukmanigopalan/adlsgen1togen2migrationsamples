$fileRootPath = $PSScriptRoot+"\"
$sourceInputFilePath = $fileRootPath + "InventoryInputs.json"
$outputDesFileFullName = "SourceConfig.json"
$sourceInputData = Get-Content -Raw -Path $sourceInputFilePath | ConvertFrom-Json
$gen1SourceRootPath = $sourceInputData.gen1SourceRootPath
$tenantId = $sourceInputData.tenantId
$subscriptionId = $sourceInputData.subscriptionId
$gen2SourceRootPath = $sourceInputData.gen2SourceRootPath
$overwrite = $sourceInputData.overwrite
$resourceGroupName = $sourceInputData.resourceGroupName
$factoryName = $sourceInputData.factoryName
$location = $sourceInputData.location

$adlsGen1LSName = "AzureDataLakeStoreGen1"
$adlsGen1LSType = "AzureDataLakeStore"
$adlsGen1DSLocationType = "AzureDataLakeStoreLocation"
$adlsGen2LSName = "AzureDataLakeStoreGen2"
$adlsGen2LSType = "AzureBlobFS"
$adlsGen2DSLocationType = "AzureBlobFSLocation"
$pipelineCopyType = "Binary"

$jsonBase = @{}
$factoriesList = New-Object System.Collections.ArrayList
$ls = New-Object System.Collections.ArrayList
$ds = New-Object System.Collections.ArrayList
$pipelines = New-Object System.Collections.ArrayList



$gen1LSProperties = @{"type" = $adlsGen1LSType ;"dataLakeStoreUri" = $gen1SourceRootPath;"servicePrincipalId" = "";"tenant" = $tenantId;"subscriptionId" = $subscriptionId;"servicePrincipalKey" = ""}
$ls.Add(@{"lsId" = "1";"name" = $adlsGen1LSName ;"overwrite" = $overwrite;"properties" = $gen1LSProperties})
$gen2LSProperties = @{"type" = $adlsGen2LSType ;"url" = $gen2SourceRootPath;"accountKey" = ""}
$ls.Add(@{"lsId" = "2";"name" = $adlsGen2LSName ;"overwrite" = $overwrite;"properties" = $gen2LSProperties})

$dsCount = 0
$pipelineCount = 0
$checkIncActivity = 0
$checkActivity = 0

foreach($pipeline in $sourceInputData.pipeline)
{
    $pipelineActivityCount = 0
    $pipelineCount++
    if($pipeline.isChurningOrIsIncremental -eq "true")
    {
        $pipelineIncActivities =  New-Object System.Collections.ArrayList

        foreach($pipelineDetails in $pipeline.pipelineDetails)
        {
            $dsCount++
            $inputAdlsGen1Name = "InputGen1ADLS"+$dsCount
            
            $ds1TypeProperties = @{ "locationType" = $adlsGen1DSLocationType; "folderPath" = $pipelineDetails.sourcePath}
            $ds1Properties = @{ "type" = $pipelineCopyType; "typeProperties" = $ds1TypeProperties}
            $ds.Add(@{ "dsId" = $dsCount; "name" = $inputAdlsGen1Name; "referenceName" = $adlsGen1LSName; "overwrite" = $overwrite ;"properties" = $ds1Properties})
            
            $inputAdlsGen2Name = "OutputGen2ADLS"+$dsCount
            
            $ds2TypeProperties = @{ "locationType" = $adlsGen2DSLocationType; "folderPath" = $pipelineDetails.destinationPath ; "fileSystem" = $pipelineDetails.destinationContainer}
            $ds2Properties = @{ "type" = $pipelineCopyType ; "typeProperties" = $ds2TypeProperties }
            $ds.Add(@{"dsId" = $dsCount; "name" = $inputAdlsGen2Name ; "referenceName" = $adlsGen2LSName; "overwrite" = $overwrite ;"properties" = $ds2Properties})
            
            $pipelineActivityCount++
            $desFullPath = $pipelineDetails.destinationContainer +"/"+$pipelineDetails.destinationPath + "/"
            $sourceFullPath = ($pipelineDetails.sourcePath).TrimStart("//") + "/"
            $pipelineIncActivitiesProperties = @{ "name" = "CopyADLSGen1ToGen2Activity"+$pipelineActivityCount; "inputDataSetReferenceName" = $inputAdlsGen1Name; "outputDataSetReferenceName" = $inputAdlsGen2Name; "inputFolderPath" = $pipelineDetails.sourcePath+"/" ; "outputFolderPath" = $desFullPath }    
            $pipelineIncActivities.Add($pipelineIncActivitiesProperties)

        }
        $pipelines.Add(@{"name" = "CopyGen1ToGen2Inc"+$pipelineCount; "type" = "Copy"; "overwrite" = $overwrite ;"incremental" = "true";"triggerName" = "CopyGen1ToGen2IncTrigger"+$pipelineCount; "triggerFrequency" = $pipeline.triggerFrequency;"triggerInterval" = $pipeline.triggerInterval;"triggerUTCStartTime" = $pipeline.triggerUTCStartTime; "activities" = $pipelineIncActivities})
    }
    if($pipeline.isChurningOrIsIncremental -eq "false")
    {
        $pipelineActivities =  New-Object System.Collections.ArrayList
        foreach($pipelineDetails in $pipeline.pipelineDetails)
        {
            $dsCount++
            $inputAdlsGen1Name = "InputADLSGen1"+$dsCount
            
            $ds1TypeProperties = @{ "locationType" = $adlsGen1DSLocationType; "folderPath" = $pipelineDetails.sourcePath}
            $ds1Properties = @{ "type" = $pipelineCopyType; "typeProperties" = $ds1TypeProperties}
            $ds.Add(@{ "dsId" = $dsCount; "name" = $inputAdlsGen1Name; "referenceName" = $adlsGen1LSName; "overwrite" = $overwrite ;"properties" = $ds1Properties})
            
            $dsCount++
            $inputAdlsGen2Name = "OutputADLSGen2"+$dsCount
            
            $ds2TypeProperties = @{ "locationType" = $adlsGen2DSLocationType; "folderPath" = $pipelineDetails.destinationPath ; "fileSystem" = $pipelineDetails.destinationContainer}
            $ds2Properties = @{ "type" = $pipelineCopyType ; "typeProperties" = $ds2TypeProperties }
            $ds.Add(@{"dsId" = $dsCount; "name" = $inputAdlsGen2Name ; "referenceName" = $adlsGen2LSName; "overwrite" = $overwrite ;"properties" = $ds2Properties})

            $pipelineActivityCount++
            $pipelineFullActivitiesProperties = @{ "name" = "CopyADLSGen1ToGen2Activity"+$pipelineActivityCount; "inputDataSetReferenceName" = $inputAdlsGen1Name; "outputDataSetReferenceName" = $inputAdlsGen2Name }    
            $pipelineActivities.Add($pipelineFullActivitiesProperties)
        }
        $pipelines.Add(@{"name" = "CopyGen1ToGen2Full"+$pipelineCount; "type" = "Copy"; "overwrite" = $overwrite ;"incremental" = "false"; "activities" = $pipelineActivities})
    }
    
}

$factoriesList.Add(@{"factoryName" = $factoryName;"resourceGroupName" = $resourceGroupName;"location" = $location;"linkedServices" = $ls ; "dataSets" = $ds ; "pipelines" = $pipelines})
$jsonBase.Add("factories",$factoriesList)
$output = $jsonBase | ConvertTo-Json -Depth 10
$configFilePath = $fileRootPath + $outputDesFileFullName
Set-Content -Path $configFilePath -Value $output
