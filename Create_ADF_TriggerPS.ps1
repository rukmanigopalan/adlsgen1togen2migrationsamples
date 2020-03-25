<#
.DESCRIPTION
    Script to create azure data factory pipeline trigger


.EXAMPLE
    PS> .\Create_ADF_TriggerPS.ps1 -subscriptionId "d64dd2aa-2f31-4e06-a954-95520e60ffd0" -resourceGroupName "Migration" -dataFactoryName "Gen1-Gen2" -dataFactoryTriggerName "trigger123" -dataFactoryPipeLine "CopyPipeline_5o0" -frequency "Hour" -interval "1"  -startTime "2020-03-20T08:45:00-08:00"  -endTime "2020-03-22T18:00:00-08:00" 
 

.NOTES
    Prerequisites:
    1. Az PowerShell Module
        `Install-Module Az -AllowClobber`
    2. Need to have Azure data factory created.
    3. Need to have Azure data factory pipeline created.    
#>


Param(
   
   [string]$subscriptionId,
   [string]$resourceGroupName,    
   [string]$dataFactoryName,
   [string]$dataFactoryTriggerName,
   [string]$dataFactoryPipeLine,
   [string]$frequency,
   [string]$interval,
   [string]$startTime,
   [string]$endTime               
   )

  
   # Script starts here 
    Connect-AzAccount 

    # List all the subscriptions associated to your account
    Get-AzSubscription

    # Select a subscription
    Set-AzContext -SubscriptionId $subscriptionId
$azureDataTriggerDefinition =@"
{
    "properties": {
        "name": "$dataFactoryTriggerName",
        "type": "ScheduleTrigger",
        "typeProperties": {
            "recurrence": {
                "frequency":"$frequency",
                "interval": "$interval",
                "startTime": "$startTime",
                "endTime":   "$endTime"
            }
        },
        "pipelines": [{
                "pipelineReference": {
                    "type": "PipelineReference",
                    "referenceName": "$dataFactoryPipeLine"
                },
                "parameters": {}
            }
        ]
    }
}
"@

## IMPORTANT: stores the JSON definition in a file that will be used by the Set-AzDataFactoryV2Trigger command. 
$azureDataTriggerDefinition | Out-File ./AzureDataFactoryTriggerdef.json

## Create Data factory triger service in the data factory.

Set-AzDataFactoryV2Trigger -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $dataFactoryTriggerName -DefinitionFile ./AzureDataFactoryTriggerdef.json



