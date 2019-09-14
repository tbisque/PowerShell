function Get-ExoModuleInstallStatus {
	$installed = (Get-InstalledModule | 
		Where-Object name -Match "Exchange.Management.ExoPowershellModule")

	#If the module isn't installed:
	if (!$installed){
		Write-Warning "Exchange Online Module not Installed."
		Write-Host -f Cyan "To install the module, run the following cmdlet from an elevated PowerShell window:"	
		"Install-Module -Name Microsoft.Exchange.Management.ExoPowershellModule -Verbose -Force;"        
	}

	$EXOSession = New-ExoPSSession
	Import-PSSession $EXOSession
}Get-ExoModuleInstallStatus

#Explains the purpose of the script
Write-Host -f Cyan "`nPurpose:"
    "This script converts a formerly on-prem AD account to a Cloud-Only Account"
    
Write-Host -f Red "`nRequirements:"
    "- On-Prem account must have already been moved into Migrated Account"
    "- Azure AD Sync must have been done since making the above change"
    "- Global Admin Rights on Office 365`n"

Write-Warning "FOR ACCOUNTS ONLY THAT DON'T NEED TO BE IN ON-PREM AD!`nDO NOT PROCEED OTHERWISE`n"

#Connect to the MsolService
Connect-MsolService

#Ask the User for an Email Address
$UserEmail = Read-Host "Enter the full email address of the Rep Account you've already moved in On-Prem AD"

#Try to Get the user from the delete users in O365
try {
    Get-MsolUser -UserPrincipalName $UserEmail -ReturnDeletedUsers | Restore-MsolUser
    }
catch {
    Write-Warning "Unable to restore $UserEmail in Office 365. It's possible the Sync has not yet happened since the account was moved in On-Prem AD."
    Pause
}

#Get the Account now that it's restored, and set the immutableID to null.
Get-MsolUser -UserPrincipalName $UserEmail | Set-MsolUser -ImmutableId $null
