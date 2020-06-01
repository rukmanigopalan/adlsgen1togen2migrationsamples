
# This script gets the Gen2 files details and returns it in object
Param(  
    [string]$subscriptionId,
    [string]$storageAccountName,
    [string]$resourceGroupName,   
    [string]$gen2FilesystemName,
    [string]$gen2FilePath    
)

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
    $aclinfoList = New-Object Collections.Generic.List[String];
    $gen2FileinfoList = @();
    $files = New-Object Collections.Generic.List[Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureDataLakeGen2Item];
    #Get all child items recursively. this will return a list of all child item          
    $gen2ChildItems = Get-AzDataLakeGen2ChildItem -Context $ctx -FileSystem $gen2FilesystemName -Path $gen2FilePath  -Recurse -ErrorAction Stop
 
    # loop through each child item and write the information of the file into CSV
        foreach ($childItem in $gen2ChildItems)
        {
            if(!$childItem.IsDirectory)
            {   
               $files +=$childItem
               $PermissionString = "{0}{1}{2}" -f $childItem.Permissions.Owner.value__, $childItem.Permissions.Group.value__, $childItem.Permissions.Other.value__;
               $acldigit = [int]$PermissionString
               $permision = GetAclShortForm($acldigit);
               $gen2FileinfoList += New-Object PsObject -Property @{Name = [io.path]::GetFileNameWithoutExtension($ChildItem.Name); Path = "/" + $childItem.Path; Permission = $permision[3];  Length = $childItem.Length};           
                                           
            } 
              
        } 
           
        #$Gen2Files =  $gen2FileinfoList | Select-Object Path, Name, Length, Permission;
        
        return $gen2FileinfoList;
 
    }
 
    catch {
        Write-Error "`n`n***** `nFailed to get Gen2 file details. Please check the latest log file or following error details ***** `n`n" -ErrorAction Continue
        Write-Error $_.Exception.Message  -ErrorAction Continue
        Write-Error $_.Exception.ItemName -ErrorAction stop
      
    } 

 
