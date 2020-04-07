
$fileRootPath = $PSScriptRoot+"\"
$templatePath = $fileRootPath + "DataFactoryV2Template\"
$actualFilePath = $fileRootPath + "Final\"
$sourceConfigFullPath = $fileRootPath + "SourceConfig.json"
$inventoryInputsPath = $fileRootPath + "InventoryInputs.json"

# Authenticate the PS page with SPN login

$inputConfigData = Get-Content -Raw -Path $inventoryInputsPath | ConvertFrom-Json
$vaultName = $inputConfigData.keyVaultName
$tenantId = $inputConfigData.tenantId
$passwd = ConvertTo-SecureString (GetKeyVaultSecret -VaultName $vaultName -SecretName "SPNSecret") -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential((GetKeyVaultSecret -VaultName $vaultName -SecretName "SPNId"), $passwd)
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
        [string] $VaultName,
        [Parameter(Mandatory = $true)]
        [string] $SecretName
    )
    process {
        (Get-AzKeyVaultSecret -vaultName $VaultName -name $SecretName).SecretValueText
    }
}

# Remove folder contents and create folder if not exists

function CreateFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $FilePath
    )
    process {
        
        if(Test-Path -Path $FilePath)
        {
            Remove-Item $FilePath -Recurse            
        }
        New-Item -ItemType directory -Path $FilePath
    }
}

# Create a empty data factory if not exist

function CreateDataFactory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryLocation
    )
    process {
        $dataFactory = Get-AzDataFactoryV2 -ResourceGroupName $ResourceGroupName -Name $DataFactoryName -ErrorAction SilentlyContinue
        if(!$dataFactory)
        {
            Set-AzDataFactoryV2 -ResourceGroupName $resourceGroupName -Name $dataFactoryName -Location $DataFactoryLocation       
        }
    }
}

# Create Gen1 linked service 

function CreateGen1LinkedServices{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $LSName,       
        [Parameter(Mandatory = $true)]
        [string] $DataLakeStoreUri,
        [Parameter(Mandatory = $true)]
        [string] $Tenant,
        [Parameter(Mandatory = $true)]
        [string] $SubscriptionId,
        [Parameter(Mandatory = $true)]
        [string] $LSTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $LSPublishPath
    )
    process {
        $spnId = GetKeyVaultSecret -VaultName $vaultName -SecretName "SPNId"
        $spnSecret = GetKeyVaultSecret -VaultName $vaultName -SecretName "SPNSecret"
        $gen1LSTemplate = Get-Content -Raw -Path $LSTemplatePath
        $gen1LSTemplate = $gen1LSTemplate.Replace("@@linkedServiceName@@",$LinkedServiceName).Replace("@@dataLakeStoreUri@@",$DataLakeStoreUri).Replace("@@servicePrincipalId@@",$spnId).Replace("@@tenant@@",$Tenant).Replace("@@subscriptionId@@",$SubscriptionId).Replace("@@resourceGroupName@@",$ResourceGroupName).Replace("@@servicePrincipalKey@@",$spnSecret)              
        $gen1LSTemplate | Set-Content $LSPublishPath        
        Set-AzDataFactoryV2LinkedService -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $LSName -File $LSPublishPath -Force | Format-List                       
    }
}

# Create Gen2 linked service

function CreateGen2LinkedServices{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $LSName,
        [Parameter(Mandatory = $true)]
        [string] $AccountUri,
        [Parameter(Mandatory = $true)]
        [string] $LSTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $LSPublishPath
    )
    process{        
        $accountKey = GetKeyVaultSecret -VaultName $vaultName -SecretName "Gen2AccountKey"       
        $gen2LSTemplate = Get-Content -Raw -Path $LSTemplatePath
        $gen2LSTemplate = $gen2LSTemplate.Replace("@@linkedServiceName@@",$LSName).Replace("@@url@@",$AccountUri).Replace("@@accountKey@@",$accountKey)
        $gen2LSTemplate | Set-Content $LSPublishPath
        Set-AzDataFactoryV2LinkedService -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $LSName -File $LSPublishPath -Force | Format-List
    }    
}

# Check if linked service already exist

function LinkedServiceExists{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $LSName        
    )
    process{        
        $linkedServices = Get-AzDataFactoryV2LinkedService -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName 
        $linkedServiceExist = $false
        foreach($ls in $linkedServices) 
        { 
            if( $ls.Name -eq $LSName) { $linkedServiceExist = $true; break;}
        }
        $linkedServiceExist
    }    
}

# Create Gen1 dataset 

function CreateGen1DataSet{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $DSName,
        [Parameter(Mandatory = $true)]
        [string] $LSReferenceName,
        [Parameter(Mandatory = $true)]
        [string] $Type,
        [Parameter(Mandatory = $true)]
        [string] $Gen1FolderPath,
        [Parameter(Mandatory = $true)]
        [string] $DSTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $DSPublishPath
    )
    process{       
        $gen1DSTemplate = Get-Content -Raw -Path $DSTemplatePath
        $gen1DSTemplate = $gen1DSTemplate.Replace("@@dataSetName@@",$DSName).Replace("@@referenceName@@",$LSReferenceName).Replace("@@type@@",$Type).Replace("@@folderPath@@",$Gen1FolderPath)
        $gen1DSTemplate | Set-Content $DSPublishPath
        Set-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DSName -DefinitionFile $DSPublishPath -Force
     }    
}

# Create Gen2 dataset

function CreateGen2DataSet{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $DSName,
        [Parameter(Mandatory = $true)]
        [string] $LSReferenceName,
        [Parameter(Mandatory = $true)]
        [string] $Type,
        [Parameter(Mandatory = $true)]
        [string] $Gen2Container,
        [Parameter(Mandatory = $true)]
        [string] $Gen2FolderPath,        
        [Parameter(Mandatory = $true)]
        [string] $DSTemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $DSPublishPath
    )
    process{       
        $gen2DSTemplate = Get-Content -Raw -Path $DSTemplatePath
        $gen2DSTemplate = $gen2DSTemplate.Replace("@@dataSetName@@",$DSName).Replace("@@referenceName@@",$LSReferenceName).Replace("@@type@@",$Type).Replace("@@folderPath@@",$Gen2FolderPath).Replace("@@fileSystem@@",$Gen2Container)
        $gen2DSTemplate | Set-Content $DSPublishPath
        Set-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DataSetName -DefinitionFile $DSPublishPath -Force
     }    
}

# Check dataset already exists or not

function DataSetExists{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $DSName        
    )
    process{        
        $dataSets = Get-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName
        $dataSetExist = $false
        foreach($ds in $dataSets) 
        { 
            if( $ds.Name -eq $DSName) { $dataSetExist = $true; break;}
        }
        $dataSetExist
    }    
}

# Copy activity

function CopyPipelineActivities{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ActivityName,
        [Parameter(Mandatory = $true)]
        [string] $InputReferenceName,
        [Parameter(Mandatory = $true)]
        [string] $OnputReferenceName,
        [Parameter(Mandatory = $false)]
        [string] $InputFolderPath,
        [Parameter(Mandatory = $false)]
        [string] $OutputFolderPath,
        [Parameter(Mandatory = $true)]
        [string] $PTemplatePath
    )
    process{   
        
        $pipelineTemplate = Get-Content -Raw -Path $PTemplatePath
        $pipelineTemplate = $pipelineTemplate.Replace("@@activityName@@",$ActivityName).Replace("@@inputFolderPath@@",$InputFolderPath).Replace("@@outputFolderPath@@",$OutputFolderPath).Replace("@@inputReferenceName@@",$InputReferenceName).Replace("@@outputReferenceName@@",$OnputReferenceName)
        $pipelineTemplate
     }    
}

# Create a pipeline with copy activities

function CreateCopyPipeline{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $PipelineName,
        [Parameter(Mandatory = $true)]
        [string] $Activities,
        [Parameter(Mandatory = $true)]
        [string] $PPublishPath,
        [Parameter(Mandatory = $true)]
        [string] $IsIncremental
    )
    process{       
        $activityOutput = $Activities.TrimStart(',')
        if($IsIncremental -eq "true")
        {
            $activityOutput = $headPipeline.Replace("@@pipelineName@@",$PipelineName)+$activityOutput+$incTailPipeline
        }
        else
        {
            $activityOutput = $headPipeline.Replace("@@pipelineName@@",$PipelineName)+$activityOutput+$tailPipeline
        }        
        $activityOutput | Set-Content $PPublishPath
        Set-AzDataFactoryV2Pipeline -ResourceGroupName $ResourceGroupName -Name $PipelineName -DataFactoryName $DataFactoryName -File $PPublishPath -Force
     }    
}

# Check pipeline exists or not

function PipelineExists{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $PName        
    )
    process{        
        $pipelines = Get-AzDataFactoryV2Pipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName
        $pipelineExist = $false
        foreach($p in $dataSets) 
        { 
            if( $p.Name -eq $PName) { $pipelineExist = $true; break;}
        }
        $pipelineExist
    }    
}


# Create trigger for incremental pipeline

function CreateTrigger{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $DataFactoryName,
        [Parameter(Mandatory = $true)]
        [string] $PipelineName,
        [Parameter(Mandatory = $true)]
        [string] $PipelineTriggerName,
        [Parameter(Mandatory = $true)]
        [string] $Frequency,
        [Parameter(Mandatory = $true)]
        [string] $Interval,
        [Parameter(Mandatory = $true)]
        [string] $TriggerStartTime,
        [Parameter(Mandatory = $true)]
        [string] $TPublishPath,
        [Parameter(Mandatory = $true)]
        [string] $TTemplatePath
    )
    process{       
        $triggerTemplate = Get-Content -Raw -Path $TTemplatePath
        $triggerTemplate = $triggerTemplate.Replace("@@dataFactoryTriggerName@@",$PipelineTriggerName).Replace("@@dataFactoryPipeLineName@@",$PipelineName).Replace("@@frequency@@",$Frequency).Replace("@@interval@@",$Interval).Replace("@@startTime@@",$TriggerStartTime)
        $triggerTemplate | Set-Content $TPublishPath
        Set-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $PipelineTriggerName -DefinitionFile $TPublishPath
     }    
}

CreateFolder -FilePath $actualFilePath

# Enumerate the json config file for creating data factory pipelines, linked services, datasets

foreach($factory in $sourceConfigData.factories[0])
{
    $resourceGroupName = $factory.resourceGroupName
    $dataFactoryName = $factory.factoryName
    $dataFactoryLocation = $factory.location

    $dataFactory = CreateDataFactory -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -DataFactoryLocation $dataFactoryLocation
    Write-Host "Factory created "$dataFactory -ForegroundColor Green

    foreach($eachLinkedServices in $factory.linkedServices)
    {
        $linkedServiceName = $eachLinkedServices.name
        $linkedServiceOverwrite = $eachLinkedServices.overwrite

        $linkedServiceExists = LinkedServiceExists -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -LSName $linkedServiceName
        
        if(!($linkedServiceExists) -or ($linkedServiceOverwrite -eq 'true'))
        {
            $adlsGen1LSType = "AzureDataLakeStore"
            $adlsGen2LSType = "AzureBlobFS"
            if($eachLinkedServices.properties.type -eq $adlsGen1LSType)
            {
                CreateGen1LinkedServices -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -LSName $linkedServiceName -DataLakeStoreUri $eachLinkedServices.properties.dataLakeStoreUri -Tenant $eachLinkedServices.properties.tenant -SubscriptionId $eachLinkedServices.properties.subscriptionId -LSTemplatePath $templatePath$gen1LSTemplateFileName -LSPublishPath $actualFilePath$linkedServiceName'.JSON' 
                Write-Host "Linked services created : "$linkedServiceName -ForegroundColor Green
            }
            if($eachLinkedServices.properties.type -eq $adlsGen2LSType)
            {
                CreateGen2LinkedServices -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -LSName $linkedServiceName -AccountUri $eachLinkedServices.properties.url -LSTemplatePath $templatePath$gen2LSTemplateFileName -LSPublishPath $actualFilePath$linkedServiceName'.JSON' 
                Write-Host "Linked services created : "$linkedServiceName -ForegroundColor Green
            }
        }
        
    }

    foreach($eachDataSet in $factory.dataSets)
    {
        $dataSetName = $eachDataSet.name
        $dataSetOverwrite = $eachDataSet.overwrite
        $dataSetExists = DataSetExists -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -DSName $dataSetName 

        if(!($dataSetExists) -or ($dataSetOverwrite -eq 'true'))
        {
            $adlsGen1DSLocationType = "AzureDataLakeStoreLocation"
            $adlsGen2DSLocationType = "AzureBlobFSLocation"
            if($eachDataSet.properties.typeProperties.locationType -eq $adlsGen1DSLocationType)
            {
                CreateGen1DataSet -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -DSName $dataSetName -LSReferenceName $eachDataSet.referenceName -Type $eachDataSet.properties.type -Gen1FolderPath $eachDataSet.properties.typeProperties.folderPath -DSTemplatePath $templatePath$gen1DSTemplateFileName -DSPublishPath $actualFilePath$dataSetName'.JSON' 
                Write-Host "Dataset created : "$dataSetName -ForegroundColor Green
            }
            if($eachDataSet.properties.typeProperties.locationType -eq $adlsGen2DSLocationType)
            {
                CreateGen2DataSet -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -DSName $dataSetName -LSReferenceName $eachDataSet.referenceName -Type $eachDataSet.properties.type -Gen2Container $eachDataSet.properties.typeProperties.fileSystem -Gen2FolderPath $eachDataSet.properties.typeProperties.folderPath -DSTemplatePath $templatePath$gen2DSTemplateFileName -DSPublishPath $actualFilePath$dataSetName'.JSON' 
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
        $pipelineExists = PipelineExists -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -PName $pipelineName 
        if(!($pipelineExists) -or ($pipelineOverwrite -eq 'true'))
        {
            $activityList = ""
            foreach($eachActivity in $eachPipeline.activities)
            {
                if($incremental -eq "true")
                {
                    $activity = CopyPipelineActivities -ActivityName $eachActivity.name -InputReferenceName $eachActivity.inputDataSetReferenceName -OnputReferenceName $eachActivity.outputDataSetReferenceName -InputFolderPath $eachActivity.inputFolderPath -OutputFolderPath $eachActivity.outputFolderPath -PTemplatePath $templatePath$pipelineIncTemplateFileName
                }
                else
                {
                    $activity = CopyPipelineActivities -ActivityName $eachActivity.name -InputReferenceName $eachActivity.inputDataSetReferenceName -OnputReferenceName $eachActivity.outputDataSetReferenceName -PTemplatePath $templatePath$pipelineTemplateFileName
                }                
                
                $activityList = $activityList + ","+ $activity
            }
            if($activityList -ne ",")
            {
                CreateCopyPipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -PipelineName $pipelineName -Activities $activityList -PPublishPath $actualFilePath$pipelineName'.JSON' -IsIncremental $incremental
                Write-Host "Pipeline created : "$pipelineName -ForegroundColor Green
            }            
        }

        if($incremental -eq "false")
        {
            #$pipelineRunIds += Invoke-AzDataFactoryV2Pipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -PipelineName $pipelineName
            Write-Host "Pipeline invoked for : "$pipelineName -ForegroundColor Green
        }
        if($incremental -eq "true")
        {
            CreateTrigger -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -PipelineName $pipelineName -PipelineTriggerName $eachPipeline.triggerName -Frequency $triggerFrequency -Interval $triggerInterval -TriggerStartTime $triggerStartTime -TPublishPath $actualFilePath$triggerName'.JSON' -TTemplatePath $templatePath$pipelineTriggerFileName 
            Write-Host "Pipeline trigger created : "$eachPipeline.triggerName -ForegroundColor Green
            #Start-AzDataFactoryV2Trigger -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -TriggerName $eachPipeline.triggerName
            #Write-Host "Pipeline trigger started : "$eachPipeline.triggerName -ForegroundColor Green
        } 
   }
}
