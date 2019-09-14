<#
.SYNOPSIS
  Get All ActiveSync Devices Connected to Exchange

.NOTES
  Author:  Tom Biscardi
  Date:    2/5/2019

.DESCRIPTION
  - Get all Exchange Mailboxes
  - Go through each, get ActiveSync devices associated with that mailbox
#>

#Determine if the PsSnapin for Exchange is Installed:
$Installed = Get-PSSnapin -Registered | Where-Object name -match "Microsoft.Exchange.Management.PowerShell"
$ExchangeSrv = "ExchangeSrv1"

#If the Exchange PsSnapin isn't installed, connect to Exchange 2010
#Note, for 2013/2016, the following command should suffice:
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
if (!$Installed){
    $ExchangeURI = "http://$ExchangeSrv.$env:USERDNSDOMAIN/PowerShell/"
    $Credentials = Get-Credential `
        -Message "**Enter your Admin Credentials** to connect to $ExchangeSrv"

    #Creates a PowerShell connection to ExchangeSrv1
    $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange -Authentication Kerberos `
        -ConnectionUri $ExchangeURI -Credential $Credentials

    #Connections to the Exchange PowerShell connection we defined above
    Import-PSSession $Session `
        -DisableNameChecking -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
}

#Gets all mailboxes from Exchange
$Mailboxes = Get-mailbox * 

#Goes through each of them, and looks for activesync devices for each mailbox 
$ActiveSyncDevices = $Mailboxes | ForEach-Object {
    Get-ActiveSyncDevice -Mailbox $_.alias
}

#Displays Results either in a window, or in the console
try{
    $ActiveSyncDevices | Out-GridView
    }
catch{
    $ActiveSyncDevices | 
        Select-Object userdisplayname,DeviceModel,DeviceType,firstsynctime,WhenChanged |
        Sort-Object FirstSyncTime -Descending |
        Format-Table -AutoSize
}