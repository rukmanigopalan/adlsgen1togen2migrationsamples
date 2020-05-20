# This script gets the Gen1 files details and returns it in object
# It uses recurisve function to iterate folders and get file details
param(
    [string]$subscriptionId,
    [string]$filePath,
    [string]$accountName,
    [string]$cutofftime)
    
try {
 
     #function to get the ACl short form
     function GetAclShortForm{
     [cmdletBinding()]
            param(
                [int] $aclDigit                
            )
            $hashtable2 = @{
                               0='---'; 
                               1='--X';
                               2='-W-';
                               3= '-WX';
                               4= 'R--';
                               5= 'R-X';
                               6= 'RW-';
                               7= 'RWX';
                            }
            [int]$number = $aclDigit
            $array = [System.Collections.ArrayList]@()          
            while($number -gt 1)
            {
                $array.Add($number % 10)                
               $number = $number / 10
            }

            $aclresult = "{0}{1}{2}" -f $hashtable2[$array[2]], $hashtable2[$array[1]], $hashtable2[$array[0]]
            return $aclresult;
 
    }
# Function to get Gen1 file details 

    
    function GetGen1DataList {
        [cmdletBinding()]
        param(
            [string] $filePath, 
            [string] $accountName, 
            [string] $cutofftime,
            [object[]] $gen1FileinfoList
        )  
    
        if ($cutofftime -eq '') {
            $cutoffint = 0;
        }
        else {
            $cutoffint = [int64]((get-date $cutofftime) - (get-date "1/1/1970")).TotalMilliseconds;
        }
        Import-module az.storage
        Import-Module az.datalakestore
        #$aclinfoList = New-Object Collections.Generic.List[String];        
        #$files = New-Object Collections.Generic.List[Microsoft.Azure.Commands.DataLakeStore.Models.DataLakeStoreItem];    
       
        $childItems = Get-AzDataLakeStoreChildItem -AccountName $accountName -Path $filePath  -ErrorAction Stop;
            
        foreach ($childItem in $childItems) {
            switch ($childItem.Type) {
                "FILE" {
                    if ($childItem.modificationtime -gt $cutoffint) {
                        #$files += $childItem; 
                       $acldigit = [int]$childItem.Permission
                       $permision = GetAclShortForm($acldigit);
                       $fileInfoObject = New-Object PsObject -Property @{Name = [io.path]::GetFileNameWithoutExtension($ChildItem.Name); Path = $childItem.Path; Type = $childItem.Type; Permission = $permision[3];  Length = $childItem.Length};                        
                       $gen1FileinfoList += $fileInfoObject;
                       
                    }
                }
                "DIRECTORY" {
                    #if the file is directory, then go find the files of the directory
                    #$files += GetGen1DataList $childItem.path $accountName $cutofftime;                     
                    $gen1FileinfoList = GetGen1DataList $childItem.path $accountName $cutofftime $gen1FileinfoList; 
                }
            }
        }       
        return $gen1FileinfoList;
        
    }
    
# Call the function to get Gen1 file details
    $gen1FileinfoList = @();
    $Gen1AllAttributes = GetGen1DataList $filePath $accountName $cutofftime $gen1FileinfoList;
    
    return $Gen1AllAttributes ;
          
     
    Write-Host "Finished getting ADL Gen1 File details" -ForegroundColor Green
    Write-Host "`n"
    
}
    
catch {
    Write-Error "`n`n***** `nFailed to get Gen1 file details. Please check the latest log file or following error details ***** `n`n" -ErrorAction Continue
    Write-Error $_.Exception.Message  -ErrorAction Continue
    Write-Error $_.Exception.ItemName -ErrorAction stop
           
} 

#$result = GetGen1Invenotry -subscriptionId "29440f0b-dc91-4851-8e0a-b714bb5d3f78" -filePath "/ZufanFolder/2020" -accountName "sourcedatalakestoregen1" -ErrorAction Stop
#$result