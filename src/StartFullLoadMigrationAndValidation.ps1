
$fullConfigRootPath = $PSScriptRoot + "\Configuration\FullLoadConfig.json"

& "$PSScriptRoot\Migration\PipelineConfig.ps1" -inputConfigFilePath $fullConfigRootPath

$pipelineRunIds = & "$PSScriptRoot\Migration\DataFactory.ps1" -inputConfigFilePath $fullConfigRootPath
$validationPipeline = @{}

while ($true) {
   
    foreach($item in $pipelineRunIds.GetEnumerator()) 
    {       
        $run = Get-AzDataFactoryV2PipelineRun -ResourceGroupName "Gen1ToGen2Migration" -DataFactoryName "Gen1ToGen2Factory1" -PipelineRunId $item.Value
        
        if ($run) {
            if ($run.Status -ne 'InProgress') {
                $msg = "Pipeline runid "+$item.Value +" finished. The status is: "+ $run.Status                

                if($run.Status -eq 'Succeeded')
                {
                    $validationPipeline.Add($item.Key,$item.Value)
                    Write-Host $msg -foregroundcolor "Green"
                }
                else
                {
                    Write-Host $msg -foregroundcolor "Red"
                }
                
                $pipelineRunIds.Remove($item.Key)
                break
            }
            $msg = "Pipeline runId "+$item.Value+" is running...status: InProgress"
            Write-Host $msg -foregroundcolor "Yellow"
        }
    }  
    if($pipelineRunIds.Count -eq 0)
    {
        break
    }
    Start-Sleep -Seconds 15  
}

& "$PSScriptRoot\Validation\InvokeValidation.ps1" -inputConfigFilePath $fullConfigRootPath -pipelineIds $validationPipeline