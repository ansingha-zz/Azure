### To Install Diagnostic extension on all VMs in a subscription and then collect Diagnostic logs from those VMs in a storage account in a different subscription

```
<#
 .SYNOPSIS
   Collect Diagnostics logs from Classic VMs in a central storage account

 .DESCRIPTION
    Installs Diagnostic extension on all VMs in a subscription. Then collects Diagnostic logs from those VMs in a central storage account.

 .PARAMETER configPath
    The path to the config file.

 .PARAMETER storageAccount
    The storage account name where we want to collect Diagnostics logs
 
 .PARAMETER subId
    The Subscription Id for which we want to run this script
#>

param(
 [Parameter(Mandatory=$True, HelpMessage="The path to the config file; it will be on the local machine")]
 [string]
 $configPath,

 [Parameter(Mandatory=$True, HelpMessage="The storage account name where we want to collect Diagnostics logs")]
 [string]
 $storageAccount,

 [Parameter(Mandatory=$True, HelpMessage="The Subscription Id for which we want to collect Diagnostic logs")]
 [string]
 $subId
)

#sign in
Add-AzureAccount

#setting storage context
$storageKey = (Get-AzureStorageKey –StorageAccountName $storageAccount).Primary
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $storageKey

#selecting correct subscription 
Select-AzureSubscription -SubscriptionId $subId

#get all the VMs
$VMs = Get-AzureVM

foreach($vm in $VMs)
{
    $RG = $vm.ServiceName
    $VMName = $vm.Name
    $NewResourceId = "/subscriptions/$subId/resourcegroups/$RG/providers/Microsoft.ClassicCompute/virtualMachines/$VMName"

    #reading from XML Config file
    [xml]$ConfigFile = Get-Content $configPath
    $ResourceId = $configFile.WadCfg.DiagnosticMonitorConfiguration.Metrics
    #updating XML Config file for this VM
    $ResourceId.resourceId = $NewResourceId
    #saving XML Config file
    $ConfigFile.Save($configPath)

    #installing Diagnostics extension
    Get-AzureVM -ServiceName $vm.ServiceName -Name $VMName |
    Set-AzureVMDiagnosticsExtension -DiagnosticsConfigurationPath $configPath -StorageContext $storageContext -Version '1.*' | Update-AzureVM
}
```

For more information and to get Config file, please refer: https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-ps-extensions-diagnostics  
