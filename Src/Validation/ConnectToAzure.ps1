param(
[string] $subscriptionId,
[string] $keyVaultName,
[string] $tenantIdKVSecreatName,
[string] $servicePrincipalSecreatKVSecreatName,
[string] $servicePrincipalIDKVSecreatName
)
    
    $tenantId = Get-AzKeyVaultSecret -VaultName $keyVaultName -Secretname $tenantIdKVSecreatName 
    $spnSecret=Get-AzKeyVaultSecret -VaultName $keyVaultName -Secretname $servicePrincipalSecreatKVSecreatName 
    $passwd = ConvertTo-SecureString $spnSecret.SecretValueText -AsPlainText -Force
    $SPNId=Get-AzKeyVaultSecret -VaultName $keyVaultName -Secretname $servicePrincipalIDKVSecreatName 
    $pscredential = New-Object System.Management.Automation.PSCredential($SPNId.SecretValueText, $passwd)
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId.SecretValueText
    # List all the subscriptions associated to your account
    Get-AzSubscription
    # Select a subscription
    Set-AzContext -SubscriptionId $subscriptionId