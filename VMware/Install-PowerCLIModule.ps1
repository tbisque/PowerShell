#Must have and internet connection & Must manually be approved to be installed
Install-Module -Name VMware.PowerCLI –Scope CurrentUser -AllowClobber

Set-PowerCLIConfiguration -InvalidCertificateAction Prompt

#Alternatively, to prompt the person running for the name of the server:
$Server = Read-Host "Please Enter the vSphere server name"

Connect-VIServer `
    -Server $Server `
    -Credential (Get-Credential -Message "Enter vSphere root creds" -UserName root) `
    -AllLinked