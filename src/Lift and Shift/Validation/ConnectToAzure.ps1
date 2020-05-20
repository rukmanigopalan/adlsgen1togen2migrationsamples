
# This script connects to Azure Account and sets the subscription

param(
    [string] $subscriptionId,
    [string] $tenantId,
    [string] $spnId,
    [string] $spnSecret
)

try
{
    $passwd = ConvertTo-SecureString $spnSecret -AsPlainText -Force
    $pscredential = New-Object System.Management.Automation.PSCredential($spnId, $passwd)

    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId -ErrorAction Stop -WarningAction SilentlyContinue

    Set-AzContext -SubscriptionId $subscriptionId

    Write-Host "Connected to Azure Account" -ForegroundColor Green
}

catch {
    Write-Error "`n`n***** `nFailed to connect to Azure. Please check the latest log file or following error details ***** `n`n" -ErrorAction Continue
    Write-Error $_.Exception.Message  -ErrorAction Continue
    Write-Error $_.Exception.ItemName -ErrorAction stop
       
} 