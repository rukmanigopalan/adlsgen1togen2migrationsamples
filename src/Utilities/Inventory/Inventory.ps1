
# connect to azure using servicePrincipalId and tenantId to use

$TenantId = << Enter the TenantID >>
$ServicePrincipalId = <<Enter the ServicePrincipalId>>
$ServicePrincipalKey = <<Enter the ServicePrincipalKey>>
$dataLakeStore=<<Enter the dataLakeStore name>>


inputPath=<<Enter the source path -location of root folder to which needs the details>>
$outputPath=<<Enter the destination path -location to save the output >>

# connect to Azure datalake gen1 storage
$SecurePassword = ConvertTo-SecureString $ServicePrincipalKey -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ( $ServicePrincipalId, $SecurePassword)
Login-AzAccount -ServicePrincipal  -TenantId $TenantId -Credential $Credential

$starttime = get-date
write-output(("start time: $starttime" ))

$outputFileName=$inputPath.Replace('/','_')
$outputFile="$outputPath$outputFileName.txt"
$Detailsfile = "$outputPath"+$outputFileName+"_Details1.txt"
Remove-Item $Detailsfile -ErrorAction Ignore

# Function to get Gen1 file details 
Try
{
    $dataLakeStoreName = "$dataLakeStore.azuredatalakestore.net"

    Export-AzDataLakeStoreChildItemProperty -Account $dataLakeStoreName -Path $inputPath -OutputPath $outputFile -MaximumDepth 2  -GetDiskUsage -IncludeFile    

	"Path"+"`t"+"Type"+"TotalNoOfDirectFiles"+"`t"+"TotalNoOfDirectDirectories"+"`t"+"TotalSize"+"`t"+"`t"+"TotalNoOfFiles"+"`t"+"TotalNoOfDirectories"+"`t"+"Owner"+"`t"+"Permission"+"`t"+"LastModifiedTime"+"`t"+"RecentChildModificationTime"+"`t"+"ActiveFlag" | Out-File -FilePath $Detailsfile -Append -Force
    $collection = @()

    Import-Csv $outputFile -Delimiter "`t" | ForEach-Object  {
		$dataLakeStoreName = "$using:dataLakeStoreName"
		$Detailsfile ="$using:Detailsfile"
		$disk =  $_
			$EndDate= Get-date
			$LastModified = @{l="LastModified";e={(Get-Date "1970-01-01 00:00:00.000Z").AddSeconds($_.ModificationTime/1000)}}
			$data=Get-AzDataLakeStoreItem -Account $dataLakeStoreName -path $($_.'Entry Name') | where-object {$_.Type -eq "DIRECTORY" } | Select-Object -property Path,$LastModified,Owner,Permission
			$ChildData=Get-AzDataLakeStoreChildItem -Account $dataLakeStoreName -path $($_.'Entry Name') | Select-Object -property Path,$LastModified | sort LastModified -descending | select -First 1 | select LastModified,@{l="ActiveFlag";e={if ((New-TimeSpan -Start $_.LastModified -End $EndDate).days -gt 40) {'False'} else {'True'}}}

		$disk.'Entry name'+"`t"+$disk.'Entry Type' +"`t"+$disk.'Total number of direct files'+"`t"+$disk.'Total number of direct directories'+"`t"+$disk.'Total size'+"`t"+$disk.'Total number of files'+"`t"+$disk.'Total number of direct directories'+"`t"+$data.Owner+"`t"+$data.permission+"`t"+$data.LastModified+"`t"+$ChildData.LastModified+"`t"+$ChildData.ActiveFlag | Out-File -FilePath $Detailsfile -Append -Force
       
        } 
}
Catch
{
    echo $_.Exception|format-list -force
}

$endtime = get-date
write-output(("end time: $endtime" ))
