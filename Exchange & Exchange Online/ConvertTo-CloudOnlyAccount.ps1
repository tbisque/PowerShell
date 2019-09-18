function Get-MSOnlineModuleStatus{
	#Function ensures that MSOnline Module is installed, and connected. If not, installs and connects

    $ExoInstalled = Get-InstalledModule | Where-Object {$_.name -match "MSOnline"}
    #Try to install the module, if it's not already:
    If (!$ExoInstalled){
        try {Install-Module MSOnline -Scope CurrentUser}
        catch {
            Write-Warning "Automatic install failed. MSOnline Module must be installed manually."
            Write-Host -f Cyan "`nRun the following command from an elevated PowerShell window:`nInstall-Module MSOnline"
        }
    }
    #Connect to the MsolService, if necessary
    try {Get-MsolDomain -ErrorAction Stop}
    catch {Connect-MsolService}
}
Get-MSOnlineModuleStatus

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
$UserEmail = Read-Host "Enter the full email address of the Account you've already moved to an non-AAD sync'd OU in On-Prem AD"

#Try to Get the user from the delete users in O365
try {
    Get-MsolUser -UserPrincipalName $UserEmail -ReturnDeletedUsers | Restore-MsolUser
    }
catch {
    Write-Warning "Unable to restore $UserEmail in Office 365. It's possible the Sync has not yet happened since the account was moved in On-Prem AD."
    Pause
}

#Get the Account now that it's restored, and set the immutableID to null.
Get-MsolUser -UserPrincipalName $UserEmail | Set-MsolUser -ImmutableId ""
