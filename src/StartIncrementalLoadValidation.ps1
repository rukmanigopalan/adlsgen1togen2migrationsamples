
$incrementalConfigRootPath = $PSScriptRoot + "\Configuration\IncrementalLoadConfig.json"

$outerConfig = Get-Content -Raw -Path $incrementalConfigRootPath | ConvertFrom-Json

$pipelineRunIdDetails = @{}

foreach($eachPipeline in $outerConfig.pipeline)
{       
    $pipelineRunIdDetails.Add($eachPipeline.pipelineId,"")
}

& "$PSScriptRoot\Validation\InvokeValidation.ps1" -inputConfigFilePath $incrementalConfigRootPath -pipelineIds $pipelineRunIdDetails

