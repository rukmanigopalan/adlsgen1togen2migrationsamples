
# This script gets the Gen1 files details and returns it in object
# It uses recurisve function to iterate folders and get file details

param(
    [string]$subscriptionId,
    [string]$filePath,
    [string]$accountName,
    [string]$cutofftime
)
    
try {
 
# Function to get Gen1 file details 
    
    function GetGen1DataList {
        [cmdletBinding()]
        param(
            [string] $filePath, 
            [string] $accountName, 
            [string] $cutofftime
        )  
    
        if ($cutofftime -eq '') {
            $cutoffint = 0;
        }
        else {
            $cutoffint = [int64]((get-date $cutofftime) - (get-date "1/1/1970")).TotalMilliseconds;
        }
       
    
        $files = New-Object Collections.Generic.List[Microsoft.Azure.Commands.DataLakeStore.Models.DataLakeStoreItem];    
       
        $childItems = Get-AzDataLakeStoreChildItem -AccountName $accountName -Path $filePath -ErrorAction Stop;
            
        foreach ($childItem in $childItems) {
            switch ($childItem.Type) {
                "FILE" {
                    if ($childItem.modificationtime -gt $cutoffint) {
                        $files += $childItem; 
                    }
                }
                "DIRECTORY" {
                    #if the file is directory, then go find the files of the directory
                    $files += GetGen1DataList $childItem.path $accountName $cutofftime;
                }
            }
        }       
    
        return $files;
    }
    
# Call the function to get Gen1 file details
    
    $Gen1AllAttributes = GetGen1DataList $filePath $accountName $cutofftime;
    
    $Gen1AllAttributes | Select-Object Path, Name, Length
    
    Write-Host "Finished getting ADL Gen1 File details" -ForegroundColor Green
    Write-Host "`n"
    
}
    
catch {
    Write-Error "`n`n***** `nFailed to get Gen1 file details. Please check the latest log file or following error details ***** `n`n" -ErrorAction Continue
    Write-Error $_.Exception.Message  -ErrorAction Continue
    Write-Error $_.Exception.ItemName -ErrorAction stop
           
} 