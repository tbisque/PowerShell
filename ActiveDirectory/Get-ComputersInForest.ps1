<# 
.SYNOPSIS
  Provides a list of all Domain-Joined Computers within the Forest

.NOTES
  Author:   Tom Biscardi
  Date:     1/23/18
  Modified: 9/14/19

.DESCRIPTION
  - Get all Domain-joined Computers in each domain in the forest
#>

# Imports the PowerShell Module needed to talk to AD.
Import-Module ActiveDirectory

#Gets all the domains in the forest, including sub-domains
$Domains = Get-ADForest | Select-Object Domains -ExpandProperty Domains

#Gets all the Computers in the forest
$Computers = $Domains | Foreach-object {
  Get-ADComputer -filter * -Server $_ -Properties operatingsystem | 
  Where-Object {$_.operatingsystem -notmatch "Server"}
}
