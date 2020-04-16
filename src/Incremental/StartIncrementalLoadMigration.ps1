
$incrementalConfigRootPath = $PSScriptRoot + "\Configuration\IncrementalLoadConfig.json"

& "$PSScriptRoot\Migration\PipelineConfig.ps1" -inputConfigFilePath $incrementalConfigRootPath

& "$PSScriptRoot\Migration\DataFactory.ps1" -inputConfigFilePath $incrementalConfigRootPath
