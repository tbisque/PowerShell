
#Great Info on Event ID 4624:
#https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4624

# Imports the PowerShell Module needed to talk to AD.
Import-Module ActiveDirectory

#Gets all the domains in the forest, including sub-domains
$Domains = Get-ADForest | Select-Object Domains -ExpandProperty Domains

#Gets all the DCs in the forest
$DCs = $Domains | Foreach-object {
    Get-ADDomainController -Filter * -Server $_
}

$DCs | ForEach-Object {
    Get-WinEvent -ComputerName $_
}