param(
[string] $subscriptionId
)
    
$tenantId = '72f988bf-86f1-41af-91ab-2d7cd011db47'
$passwd = ConvertTo-SecureString "Zjl/J.vWJyQ50u]@HOOeVkQwRPKiNw31" -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential("55b7545f-661a-4710-b336-ea1e3c474d09", $passwd)


Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
# List all the subscriptions associated to your account
Get-AzSubscription
# Select a subscription
Set-AzContext -SubscriptionId $subscriptionId