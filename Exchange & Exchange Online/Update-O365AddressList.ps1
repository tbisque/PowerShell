#Find Recipeints with a specific domain in their email address:
$Domain = "@cusonet.com"

#Function to ensure successful connection to O365
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
		Write-Warning "Exchange Online Module not Installed."
		Write-Host -f Cyan "To install the module, run the following cmdlet from an elevated PowerShell window:"	
		"Install-Module -Name Microsoft.Exchange.Management.ExoPowershellModule -Verbose -Force;"        	
	}

    #if the module is installed, check to see if there's an active PSSession into Exchange Online
    else{
		if (!$ActiveSession){
            try{$EXOSession = New-ExoPSSession
            Import-PSSession $EXOSession}
        catch {Write-Warning "Failed to open a new session to Exchange Online"} 
        }
    }
}
Get-ExoModuleInstallStatus

#Gets all recipients
Get-Recipient * -ResultSize Unlimited | 
    Where-Object PrimarySmtpAddress -Match $Domain | 
    ForEach-Object {
        #If it's a mailbox, give it a quick change
        if ("UserMailbox" -eq $_.RecipientType){
            $OriginalSDN = (Get-Mailbox $_.alias).SimpleDisplayName
            Set-Mailbox $_.alias -SimpleDisplayName "Test"
            Set-Mailbox $_.alias -SimpleDisplayName $OriginalSDN
            Remove-Variable OriginalSDN
        }

        #If it's a MailUser, give it a quick change
        elseif ("MailUser" -eq $_.RecipientType){
            $OriginalSDN = (Get-MailUser $_.Name).SimpleDisplayName
            Set-MailUser $_.alias -SimpleDisplayName "Test"
            Set-MailUser $_.alias -SimpleDisplayName $OriginalSDN 
            Remove-Variable OriginalSDN
        }

        #If not, skip:
        else {
            $User = $_.alias
            Write-Warning "$User not a UserMailbox, nor a MailUser. Was actually:"
            Write-Host $_.RecipientType
            Remove-Variable User
        }
}