#Defines a specific domain to filter down recipients later:
$Domain = "@domain.com"

#Determines if the Office365 Exchange Module is installed. If not, provides instructions for installing
function Get-ExoModuleInstallStatus {
	$installed = (Get-InstalledModule | 
		Where-Object name -Match "Exchange.Management.ExoPowershellModule")

	#If the module isn't installed:
	if (!$installed){
        Write-Host "`n"
		Write-Warning "Exchange Online Module not Installed!"
		Write-Host -f Cyan "`nTo install the module, run the following cmdlet from an elevated PowerShell window:"	
		"Install-Module -Name Microsoft.Exchange.Management.ExoPowershellModule -Verbose -Force;`n"        
	}

	$EXOSession = New-ExoPSSession
	Import-PSSession $EXOSession
} Get-ExoModuleInstallStatus


Get-Recipient * -ResultSize Unlimited | 
    Where-Object PrimarySmtpAddress -Match $Domain | 
    ForEach-Object {
        #If it's a mailbox, give it a quick change
        if ("UserMailbox" -eq $_.RecipientType){
            $OriginalSDN = (Get-Mailbox $_.alias).SimpleDisplayName
            Set-Mailbox $_.alias -SimpleDisplayName "Test"
            Set-Mailbox $_.alias -SimpleDisplayName $OriginalSDN
        }

        #If it's a MailUser, give it a quick change
        elseif ("MailUser" -eq $_.RecipientType){
            $OriginalSDN = (Get-MailUser $_.Name).SimpleDisplayName
            Set-MailUser $_.alias -SimpleDisplayName "Test"
            Set-MailUser $_.alias -SimpleDisplayName $OriginalSDN 
        }

        #If not, skip over that specific recipient:
        else {
            $User = $_.alias
            Write-Warning "$User not a UserMailbox, nor a MailUser. Was actually:"
            Write-Host $_.RecipientType
            Remove-Variable User
        }
}
