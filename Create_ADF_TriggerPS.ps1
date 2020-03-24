#Connect-AzAccount
Function login(){
   Param(
   [string]$tenantId,
   [string]$passowrd,
   [string]$subscriptionId,
   [string]$servicePrincipalId
   )
    if(-not($passowrd))
    { 
        Throw “You must supply a value for -password” 
    }
    if(-not($tenantId))
    { 
        Throw “You must supply a value for -tenantId” 
    }

    if(-not($subscriptionId))
    { 
        Throw “You must supply a value for -subscriptionId” 
    }

    if(-not($servicePrincipalId))
    { 
        Throw “You must supply a value for -servicePrincipalId” 
    }
    $passwd = ConvertTo-SecureString $passowrd -AsPlainText -Force
    $pscredential = New-Object System.Management.Automation.PSCredential($servicePrincipalId, $passwd)
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId

    # List all the subscriptions associated to your account
    Get-AzSubscription

    # Select a subscription
    Set-AzContext -SubscriptionId $subscriptionId
}



Function createADFTrigger()
{
Param(
   [string]$tenantId,
   [string]$passowrd,
   [string]$subscriptionId,
   [string]$servicePrincipalId,
   [string]$resourceGroupName,    
   [string]$dataFactoryName,
   [string]$dataFactoryTriggerName,
   [string]$dataFactoryPipeLine              
   )

   #login -tenantId $tenantId -passowrd $passowrd -subscriptionId $subscriptionId -servicePrincipalId $servicePrincipalId

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
                "frequency": "Hour",
                "interval": 1,
                "startTime": "2020-03-20T08:45:00-08:00",
                "endTime": "2020-03-22T18:00:00-08:00"
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

## IMPORTANT: stores the JSON definition in a file that will be used by the Set-AzDataFactoryV2LinkedService command. 
$azureDataTriggerDefinition | Out-File ./AzureDataFactoryTriggerdef.json

## Create Data factory triger service in the data factory.

Set-AzDataFactoryV2Trigger -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $dataFactoryTriggerName -DefinitionFile ./AzureDataFactoryTriggerdef.json

#Start-AzDataFactoryV2Trigger -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name "trigger1"
}


createADFTrigger -tenantId "TenantId" -passowrd "password" -subscriptionId "subId" -servicePrincipalId "ServId" -resourceGroupName "Migration" -dataFactoryName "Gen1-Gen2" -dataFactoryTriggerName "trigger1" -dataFactoryPipeLine "CopyPipeline_5o0"

