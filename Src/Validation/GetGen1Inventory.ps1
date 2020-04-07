
param(
[string]$subscriptionId,
[string]$filePath,
[string]$accountName,
[string]$cutofftime
)

function GetGen1DataList {
    [cmdletBinding()]
    param(
        [string] $filePath, 
        [string] $accountName, 
        [string] $cutofftime
        )

   Write-Host "Getting ADL Gen1 File details" -ForegroundColor Yellow
   Write-Host "ADL Gen1 Account: $($accountName)"
   Write-Host "ADL Gen1 Root Path: $($filePath)"
   Write-Host "`n"
   
    # convert cutofftime to int

    if ($cutofftime -eq '')
    {
    $cutoffint=0;
    }
    else{
    $cutoffint=[int64]((get-date $cutofftime)-(get-date "1/1/1970")).TotalMilliseconds;
    }
   
    # set up array to hold DataLakeStore items

    $files=New-Object Collections.Generic.List[Microsoft.Azure.Commands.DataLakeStore.Models.DataLakeStoreItem];
    
    if ($filePath -ne '' -and $accountName -ne ''){
        $childItems = Get-AzDataLakeStoreChildItem -AccountName $accountName -Path $filePath;
        foreach ($childItem in $childItems) {
            switch ($childItem.Type) {
                "FILE" {
                    if ($childItem.modificationtime -gt $cutoffint){
                        $files+=$childItem; 
                        }
                }
                "DIRECTORY" {
                    #if the file is directory, then go find the files of the directory
                    $files+=GetGen1DataList $childItem.path $accountName $cutofftime;
                }
            }
        }       
    }
    else{
        throw 'Can not find filepath or account';
    }  
    return $files;
}

  
# call function

$Gen1AllAttributes = GetGen1DataList $filePath $accountName $cutofftime;

$Gen1AllAttributes | select Path, Name, Length



Write-Host "Finished getting ADL Gen1 File details" -ForegroundColor Green



