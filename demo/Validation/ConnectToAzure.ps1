param(
[string] $subscriptionId,
[string] $tenantId,
[string] $spnId,
[string] $spnSecret
)
    
$passwd = ConvertTo-SecureString $spnSecret -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($spnId, $passwd)

Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId

Set-AzContext -SubscriptionId $subscriptionId

Write-Host "Connected to Azure Account" -ForegroundColor Green

