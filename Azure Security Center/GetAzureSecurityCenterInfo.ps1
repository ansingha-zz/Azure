<#
.SYNOPSIS
    Gets ASC related info from all subscriptions

.DESCRIPTION
    Gets ASC related info (like Notifications are On or not) from all subscriptions in a readable CSV format
#>

param(
 [Parameter(Mandatory=$True, HelpMessage="CSV file location that lists all Subscriptions")]
 [string[]]
 $inputCSVFile,

 [Parameter(Mandatory=$True, HelpMessage="CSV file location that will have the final report")]
 [string[]]
$outputReportFile
 )

Login-AzureRmAccount

armclient login


'' | select 'SubName', 'Id', 'LogCollection','areNotificationsOn', 'securityContactEmails'| Export-Csv $outputReportFile -NoTypeInformation 

$subs =  import-csv $inputCSVFile
foreach($sub in $subs)
{
$subId = $sub.SubscriptionId
Select-AzurermSubscription -SubscriptionId $subId

$JSONfile =   armclient get /subscriptions/$subId/providers/microsoft.Security/policies?api-version=2015-06-01-preview

$ConvertedJSON = $JSONfile | convertfrom-json

foreach($value in $ConvertedJSON.value)
{
$sub.SubscriptionName+','+$value.properties.name+','+$value.properties.logCollection+','+$value.properties.securityContactConfiguration.areNotificationsOn+','+$value.properties.securityContactConfiguration.securityContactEmails| Out-File $outputReportFile -append -encoding ascii
} 
}
