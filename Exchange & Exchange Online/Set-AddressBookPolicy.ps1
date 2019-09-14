$Domain = "domain.com"
$ABP = "Company ABP"
#=========================================================
#Ensure successful login to the Exchange Online Module

function Get-ExoModuleInstallStatus {
	$installed = (Get-InstalledModule | 
		Where-Object name -Match "Exchange.Management.ExoPowershellModule")

	$ActiveSession = Get-PSSession | 
		where-Object {
			($_.Computername -match "Outlook.office") -and `
			($_.State -eq "Opened") -and `
			($_.ConfigurationName -eq "Microsoft.Exchange")
		}
		
	#If the module isn't installed:
	if (!$installed){
		Install-Module -Name Microsoft.Exchange.Management.ExoPowershellModule -Scope CurrentUser        	
	}

	#if the module is installed, check to see if there's an active PSSession into Exchange Online
	else{
		if (!$ActiveSession){
			try{
				$EXOSession = New-ExoPSSession
				Import-PSSession $EXOSession
			}
			catch {Write-Warning "Failed to open a new session to Exchange Online"} 
		}
	}
}
Get-ExoModuleInstallStatus

#=========================================================
#Get each Mailbox with an email address matching $Domain, Set it to use the $ABP Address Book Policy
Get-Mailbox -ResultSize unlimited | 
    Where-Object {($_.primarysmtpaddress -match "@$domain") -and ($_.AddressBookPolicy -ne $ABP)} |
    ForEach-Object {
		$_.alias
		Set-Mailbox $_.alias -AddressBookPolicy $ABP
    }