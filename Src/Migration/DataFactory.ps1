
$fileRootPath = $PSScriptRoot+"\"
$templatePath = $fileRootPath + "DataFactoryV2Template\"
$actualFilePath = $fileRootPath + "DeployableTemplate\"
$sourceConfigFullPath = $fileRootPath + "SourceConfig.json"
$inventoryInputsPath = $fileRootPath + "InventoryInputs.json"

# Authenticate the PS page with SPN login

$inputConfigData = Get-Content -Raw -Path $inventoryInputsPath | ConvertFrom-Json
$vaultName = $inputConfigData.keyVaultName
$tenantId = $inputConfigData.tenantId
$passwd = ConvertTo-SecureString ($inputConfigData.servicePrincipleSecret) -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential(($inputConfigData.servicePrincipleId), $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
Write-Host "Authenticated with SPN " -ForegroundColor Green

$sourceConfigData = Get-Content -Raw -Path $sourceConfigFullPath | ConvertFrom-Json

$headPipeline = "{    ""name"": ""@@pipelineName@@"",    ""properties"": {        ""activities"": ["
$tailPipeline = "],        ""annotations"": []    }}"
$incTailPipeline = "],""parameters"": {""windowStart"": {""type"": ""String""},""windowEnd"": {""type"": ""String""}},""annotations"": []}}"

$gen1LSTemplateFileName = "LSADLSGen1Template.JSON"
$gen2LSTemplateFileName = "LSADLSGen2Template.JSON"
$gen1DSTemplateFileName = "DSInputADLSGen1Template.JSON"
$gen2DSTemplateFileName = "DSOutputADLSGen2Template.JSON"
$pipelineTemplateFileName = "PCopyGen1ToGen2Template.JSON"
$pipelineIncTemplateFileName = "PCopyGen1ToGen2IncTemplate.JSON"
$pipelineTriggerFileName = "PScheduleTrigger.JSON"
$sqlServer = $inputConfigData.sqlServerName
$sqlDBName = $inputConfigData.sqlDBName
$userName = $inputConfigData.sqlUserName

$pipelineRunIds = @()
$todaysDate = (Get-Date).ToUniversalTime() 
$triggerStartTime = $todaysDate.ToString("yyyy-MM-ddTHH:mm:ss.fffZ") 
$runStartedAfter = $todaysDate.ToString("yyyy-MM-dd")
$runStartedBefore = $todaysDate.AddDays(1).ToString("yyyy-MM-dd")


# Get key vault secret value

function GetKeyVaultSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $vaultName,
        [Parameter(Mandatory = $true)]
        [string] $secretName
    )
    process {
        (Get-AzKeyVaultSecret -vaultName $vaultName -name $secretName).SecretValueText
    }
}

# Remove folder contents and create folder if not exists

function CreateFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $filePath
    )
    process {
        
        if(Test-Path -Path $filePath)
        {
            Remove-Item $filePath -Recurse            
        }
        New-Item -ItemType directory -Path $filePath
    }
}

# Create a empty data factory if not exist

function CreateDataFactory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryLocation
    )
    process {
        $dataFactory = Get-AzDataFactoryV2 -ResourceGroupName $resourceGroupName -Name $dataFactoryName -ErrorAction SilentlyContinue
        if(!$dataFactory)
        {
            Set-AzDataFactoryV2 -ResourceGroupName $resourceGroupName -Name $dataFactoryName -Location $dataFactoryLocation       
        }
    }
}

# Create Gen1 linked service 

function CreateGen1LinkedServices{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $lsName,       
        [Parameter(Mandatory = $true)]
        [string] $dataLakeStoreUri,
        [Parameter(Mandatory = $true)]
        [string] $tenant,
        [Parameter(Mandatory = $true)]
        [string] $subscriptionId,
        [Parameter(Mandatory = $true)]
        [string] $lsTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $lsPublishPath
    )
    process {
        $spnId = GetKeyVaultSecret -VaultName $vaultName -SecretName "SPNId"
        $spnSecret = GetKeyVaultSecret -VaultName $vaultName -SecretName "SPNSecret"
        $gen1LSTemplate = Get-Content -Raw -Path $lsTemplatePath
        $gen1LSTemplate = $gen1LSTemplate.Replace("@@linkedServiceName@@",$linkedServiceName).Replace("@@dataLakeStoreUri@@",$dataLakeStoreUri).Replace("@@servicePrincipalId@@",$spnId).Replace("@@tenant@@",$Tenant).Replace("@@subscriptionId@@",$subscriptionId).Replace("@@resourceGroupName@@",$resourceGroupName).Replace("@@servicePrincipalKey@@",$spnSecret)              
        $gen1LSTemplate | Set-Content $lsPublishPath        
        Set-AzDataFactoryV2LinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $lsName -File $lsPublishPath -Force | Format-List                       
    }
}

# Create Gen2 linked service

function CreateGen2LinkedServices{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $lsName,
        [Parameter(Mandatory = $true)]
        [string] $accountUri,
        [Parameter(Mandatory = $true)]
        [string] $lsTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $lsPublishPath
    )
    process{        
        $accountKey = GetKeyVaultSecret -VaultName $vaultName -SecretName "Gen2AccountKey"       
        $gen2LSTemplate = Get-Content -Raw -Path $lsTemplatePath
        $gen2LSTemplate = $gen2LSTemplate.Replace("@@linkedServiceName@@",$lsName).Replace("@@url@@",$accountUri).Replace("@@accountKey@@",$accountKey)
        $gen2LSTemplate | Set-Content $lsPublishPath
        Set-AzDataFactoryV2LinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $lsName -File $lsPublishPath -Force | Format-List
    }    
}

# Check if linked service already exist

function LinkedServiceExists{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $lsName        
    )
    process{        
        $linkedServices = Get-AzDataFactoryV2LinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName 
        $linkedServiceExist = $false
        foreach($ls in $linkedServices) 
        { 
            if( $ls.Name -eq $lsName) { $linkedServiceExist = $true; break;}
        }
        $linkedServiceExist
    }    
}

# Create Gen1 dataset 

function CreateGen1DataSet{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $dsName,
        [Parameter(Mandatory = $true)]
        [string] $lsReferenceName,
        [Parameter(Mandatory = $true)]
        [string] $type,
        [Parameter(Mandatory = $true)]
        [string] $gen1FolderPath,
        [Parameter(Mandatory = $true)]
        [string] $dsTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $dsPublishPath
    )
    process{       
        $gen1DSTemplate = Get-Content -Raw -Path $dsTemplatePath
        $gen1DSTemplate = $gen1DSTemplate.Replace("@@dataSetName@@",$dsName).Replace("@@referenceName@@",$lsReferenceName).Replace("@@type@@",$type).Replace("@@folderPath@@",$gen1FolderPath)
        $gen1DSTemplate | Set-Content $dsPublishPath
        Set-AzDataFactoryV2Dataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $dsName -DefinitionFile $dsPublishPath -Force
     }    
}

# Create Gen2 dataset

function CreateGen2DataSet{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $dsName,
        [Parameter(Mandatory = $true)]
        [string] $lsReferenceName,
        [Parameter(Mandatory = $true)]
        [string] $type,
        [Parameter(Mandatory = $true)]
        [string] $gen2Container,
        [Parameter(Mandatory = $true)]
        [string] $gen2FolderPath,        
        [Parameter(Mandatory = $true)]
        [string] $dsTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $dsPublishPath
    )
    process{       
        $gen2DSTemplate = Get-Content -Raw -Path $dsTemplatePath
        $gen2DSTemplate = $gen2DSTemplate.Replace("@@dataSetName@@",$dsName).Replace("@@referenceName@@",$lsReferenceName).Replace("@@type@@",$type).Replace("@@folderPath@@",$gen2FolderPath).Replace("@@fileSystem@@",$gen2Container)
        $gen2DSTemplate | Set-Content $dsPublishPath
        Set-AzDataFactoryV2Dataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $dataSetName -DefinitionFile $dsPublishPath -Force
     }    
}

# Check dataset already exists or not

function DataSetExists{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $dsName        
    )
    process{        
        $dataSets = Get-AzDataFactoryV2Dataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName
        $dataSetExist = $false
        foreach($ds in $dataSets) 
        { 
            if( $ds.Name -eq $dsName) { $dataSetExist = $true; break;}
        }
        $dataSetExist
    }    
}

# Copy activity

function CopyPipelineActivities{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $activityName,
        [Parameter(Mandatory = $true)]
        [string] $inputReferenceName,
        [Parameter(Mandatory = $true)]
        [string] $outputReferenceName,
        [Parameter(Mandatory = $false)]
        [string] $inputFolderPath,
        [Parameter(Mandatory = $false)]
        [string] $outputFolderPath,
        [Parameter(Mandatory = $true)]
        [string] $pTemplatePath
    )
    process{   
        
        $pipelineTemplate = Get-Content -Raw -Path $pTemplatePath
        $pipelineTemplate = $pipelineTemplate.Replace("@@activityName@@",$activityName).Replace("@@inputFolderPath@@",$inputFolderPath).Replace("@@outputFolderPath@@",$outputFolderPath).Replace("@@inputReferenceName@@",$inputReferenceName).Replace("@@outputReferenceName@@",$outputReferenceName)
        $pipelineTemplate
     }    
}

# Create a pipeline with copy activities

function CreateCopyPipeline{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $pipelineName,
        [Parameter(Mandatory = $true)]
        [string] $activities,
        [Parameter(Mandatory = $true)]
        [string] $pPublishPath,
        [Parameter(Mandatory = $true)]
        [string] $isIncremental
    )
    process{       
        $activityOutput = $activities.TrimStart(',')
        if($isIncremental -eq "true")
        {
            $activityOutput = $headPipeline.Replace("@@pipelineName@@",$pipelineName)+$activityOutput+$incTailPipeline
        }
        else
        {
            $activityOutput = $headPipeline.Replace("@@pipelineName@@",$pipelineName)+$activityOutput+$tailPipeline
        }        
        $activityOutput | Set-Content $pPublishPath
        Set-AzDataFactoryV2Pipeline -ResourceGroupName $resourceGroupName -Name $pipelineName -DataFactoryName $dataFactoryName -File $pPublishPath -Force
     }    
}

# Check pipeline exists or not

function PipelineExists{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $pName        
    )
    process{        
        $pipelines = Get-AzDataFactoryV2Pipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName
        $pipelineExist = $false
        foreach($p in $dataSets) 
        { 
            if( $p.Name -eq $pName) { $pipelineExist = $true; break;}
        }
        $pipelineExist
    }    
}


# Create trigger for incremental pipeline

function CreateTrigger{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $dataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $pipelineName,
        [Parameter(Mandatory = $true)]
        [string] $pipelineTriggerName,
        [Parameter(Mandatory = $true)]
        [string] $frequency,
        [Parameter(Mandatory = $true)]
        [string] $interval,
        [Parameter(Mandatory = $true)]
        [string] $triggerStartTime,
        [Parameter(Mandatory = $true)]
        [string] $tPublishPath,
        [Parameter(Mandatory = $true)]
        [string] $tTemplatePath
    )
    process{       
        $triggerTemplate = Get-Content -Raw -Path $tTemplatePath
        $triggerTemplate = $triggerTemplate.Replace("@@dataFactoryTriggerName@@",$pipelineTriggerName).Replace("@@dataFactoryPipeLineName@@",$pipelineName).Replace("@@frequency@@",$frequency).Replace("@@interval@@",$interval).Replace("@@startTime@@",$triggerStartTime)
        $triggerTemplate | Set-Content $tPublishPath
        Set-AzDataFactoryV2Trigger -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $pipelineTriggerName -DefinitionFile $tPublishPath -Force
     }    
}

CreateFolder -FilePath $actualFilePath

# Enumerate the json config file for creating data factory pipelines, linked services, datasets

foreach($factory in $sourceConfigData.factories[0])
{
    $resourceGroupName = $factory.resourceGroupName
    $dataFactoryName = $factory.factoryName
    $dataFactoryLocation = $factory.location

    $dataFactory = CreateDataFactory -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -dataFactoryLocation $dataFactoryLocation
    Write-Host "Factory created "$dataFactory -ForegroundColor Green

    foreach($eachLinkedServices in $factory.linkedServices)
    {
        $linkedServiceName = $eachLinkedServices.name
        $linkedServiceOverwrite = $eachLinkedServices.overwrite

        $linkedServiceExists = LinkedServiceExists -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -lsName $linkedServiceName
        
        if(!($linkedServiceExists) -or ($linkedServiceOverwrite -eq 'true'))
        {
            $adlsGen1LSType = "AzureDataLakeStore"
            $adlsGen2LSType = "AzureBlobFS"
            if($eachLinkedServices.properties.type -eq $adlsGen1LSType)
            {
                CreateGen1LinkedServices -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -lsName $linkedServiceName -dataLakeStoreUri $eachLinkedServices.properties.dataLakeStoreUri -tenant $eachLinkedServices.properties.tenant -subscriptionId $eachLinkedServices.properties.subscriptionId -lsTemplatePath $templatePath$gen1LSTemplateFileName -lsPublishPath $actualFilePath$linkedServiceName'.JSON' 
                Write-Host "Linked services created : "$linkedServiceName -ForegroundColor Green
            }
            if($eachLinkedServices.properties.type -eq $adlsGen2LSType)
            {
                CreateGen2LinkedServices -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -lsName $linkedServiceName -accountUri $eachLinkedServices.properties.url -lsTemplatePath $templatePath$gen2LSTemplateFileName -lsPublishPath $actualFilePath$linkedServiceName'.JSON' 
                Write-Host "Linked services created : "$linkedServiceName -ForegroundColor Green
            }
        }
        
    }

    foreach($eachDataSet in $factory.dataSets)
    {
        $dataSetName = $eachDataSet.name
        $dataSetOverwrite = $eachDataSet.overwrite
        $dataSetExists = DataSetExists -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -dsName $dataSetName 

        if(!($dataSetExists) -or ($dataSetOverwrite -eq 'true'))
        {
            $adlsGen1DSLocationType = "AzureDataLakeStoreLocation"
            $adlsGen2DSLocationType = "AzureBlobFSLocation"
            if($eachDataSet.properties.typeProperties.locationType -eq $adlsGen1DSLocationType)
            {
                CreateGen1DataSet -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -dsName $dataSetName -lsReferenceName $eachDataSet.referenceName -type $eachDataSet.properties.type -gen1FolderPath $eachDataSet.properties.typeProperties.folderPath -dsTemplatePath $templatePath$gen1DSTemplateFileName -dsPublishPath $actualFilePath$dataSetName'.JSON' 
                Write-Host "Dataset created : "$dataSetName -ForegroundColor Green
            }
            if($eachDataSet.properties.typeProperties.locationType -eq $adlsGen2DSLocationType)
            {
                CreateGen2DataSet -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -dsName $dataSetName -lsReferenceName $eachDataSet.referenceName -type $eachDataSet.properties.type -gen2Container $eachDataSet.properties.typeProperties.fileSystem -gen2FolderPath $eachDataSet.properties.typeProperties.folderPath -dsTemplatePath $templatePath$gen2DSTemplateFileName -dsPublishPath $actualFilePath$dataSetName'.JSON' 
                Write-Host "Dataset created : "$dataSetName -ForegroundColor Green
            }
        }
    }    
   
   foreach($eachPipeline in $factory.pipelines)
   {
        $pipelineName = $eachPipeline.name
        $pipelineOverwrite = $eachPipeline.overwrite 
        $incremental = $eachPipeline.incremental  
        $triggerName = $eachPipeline.triggerName
        $triggerFrequency = $eachPipeline.triggerFrequency 
        $triggerInterval = $eachPipeline.triggerInterval
        $triggerStartTime = $eachPipeline.triggerUTCStartTime
        $pipelineExists = PipelineExists -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -pName $pipelineName 
        if(!($pipelineExists) -or ($pipelineOverwrite -eq 'true'))
        {
            $activityList = ""
            foreach($eachActivity in $eachPipeline.activities)
            {
                if($incremental -eq "true")
                {
                    $activity = CopyPipelineActivities -activityName $eachActivity.name -inputReferenceName $eachActivity.inputDataSetReferenceName -outputReferenceName $eachActivity.outputDataSetReferenceName -inputFolderPath $eachActivity.inputFolderPath -outputFolderPath $eachActivity.outputFolderPath -pTemplatePath $templatePath$pipelineIncTemplateFileName
                }
                else
                {
                    $activity = CopyPipelineActivities -activityName $eachActivity.name -inputReferenceName $eachActivity.inputDataSetReferenceName -outputReferenceName $eachActivity.outputDataSetReferenceName -pTemplatePath $templatePath$pipelineTemplateFileName
                }                
                
                $activityList = $activityList + ","+ $activity
            }
            if($activityList -ne ",")
            {
                CreateCopyPipeline -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -pipelineName $pipelineName -activities $activityList -pPublishPath $actualFilePath$pipelineName'.JSON' -isIncremental $incremental
                Write-Host "Pipeline created : "$pipelineName -ForegroundColor Green
            }            
        }

        if($incremental -eq "false")
        {
            $pipelineRunIds += Invoke-AzDataFactoryV2Pipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -PipelineName $pipelineName
            Write-Host "Pipeline invoked for : "$pipelineName -ForegroundColor Green
        }
        if($incremental -eq "true")
        {
            CreateTrigger -resourceGroupName $resourceGroupName -dataFactoryName $dataFactoryName -pipelineName $pipelineName -pipelineTriggerName $eachPipeline.triggerName -frequency $triggerFrequency -interval $triggerInterval -triggerStartTime $triggerStartTime -tPublishPath $actualFilePath$triggerName'.JSON' -tTemplatePath $templatePath$pipelineTriggerFileName 
            Write-Host "Pipeline trigger created : "$eachPipeline.triggerName -ForegroundColor Green
            Start-AzDataFactoryV2Trigger -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -TriggerName $eachPipeline.triggerName -Force
            Write-Host "Pipeline trigger started : "$eachPipeline.triggerName -ForegroundColor Green
        } 
   }
}
