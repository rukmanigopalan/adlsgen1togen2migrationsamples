
# This script gets the Gen2 files details and returns it in object

Param(  
    [string]$subscriptionId,
    [string]$storageAccountName,
    [string]$resourceGroupName,   
    [string]$gen2FilesystemName,
    [string]$gen2FilePath  
)
 
try {

# Function to get the ADL Gen2 Storage context
 
   function ConnectToGen2 {
        param(
            [string] $resourceGroupName,
            [string] $storageAccountName)
 
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
        # Retrieve the context.
        $ctx = $storageAccount.Context            
        return $ctx
    }
 
     
    Write-Host "Getting ADL Gen2 File details" -ForegroundColor Yellow
    Write-Host "ADL Gen2 Account: $($storageAccountName)"
    Write-Host "ADL Gen2 Root Path: $($gen2FilePath)"
    Write-Host "`n"
 
    # connect to azure using service principal and select the subscription to use
    #& "$PSScriptRoot\ConnectToAzure.ps1" -subscriptionId $subscriptionId
 
    # connect to Azure datalake gen2 storage
    $ctx = ConnectToGen2 $resourceGroupName $storageAccountName    
 
    $files = New-Object Collections.Generic.List[Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureDataLakeGen2Item];
    #Get all child items recursively. this will return a list of all child item          
    $gen2ChildItems = Get-AzDataLakeGen2ChildItem -Context $ctx -FileSystem $gen2FilesystemName -Path $gen2FilePath  -Recurse -ErrorAction Stop
 
    # loop through each child item and write the information of the file into CSV
    foreach ($childItem in $gen2ChildItems) {
        if (!$childItem.IsDirectory) {   
            $files += $childItem                      
        }     
    
    }
 
    Write-Host "Finished getting ADL Gen2 File details" -ForegroundColor Green
 
    $Gen2Files = $files | Select-Object @{name = "Path"; expression = { "/" + $_.Path } }, Length | Where-Object Path -NE $NULL
 
    return $Gen2Files; 
 
}
 
catch {
    Write-Error "`n`n***** `nFailed to get Gen2 file details. Please check the latest log file or following error details ***** `n`n" -ErrorAction Continue
    Write-Error $_.Exception.Message  -ErrorAction Continue
    Write-Error $_.Exception.ItemName -ErrorAction stop
        
} 
 