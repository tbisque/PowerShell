# Imports the PowerShell Module needed to talk to AD.
Import-Module ActiveDirectory

#Gets all the domains in the forest, including sub-domains
$Domains = Get-ADForest | Select-Object Domains -ExpandProperty Domains

#Gets all the Servers in the forest
$Servers = $Domains | 
    Foreach-object {
        Get-ADComputer -filter * -Server $_ -Properties operatingsystem | 
        Where-Object {$_.operatingsystem -match "Server"}
    }
