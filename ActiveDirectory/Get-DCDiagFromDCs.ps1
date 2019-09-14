<#
.SYNOPSIS
  Gets DCDiag Report from all DCs

.NOTES
  Author:   Tom Biscardi
  Date:     5/2/2019

.DESCRIPTION
  - Gets list of DCs
  - Runs a DCDiag command on each server and exports it to 
  - Assumes Account running script has appropriate credentials for all DCs
#>

#Variable Definition
$DCDiagBackupPath = "\\Fileserver\path\DCDiags\"
$Date = Get-Date -Format "yyyy-MM-dd"

#Gets all the domains in the forest, including sub-domains
$Domains = Get-ADForest | Select-Object Domains -ExpandProperty Domains
#Gets all the DCs in the forest
$DCs = $Domains | Foreach-object {Get-ADDomainController -Filter * -Server $_}

#Backup a copy of the DCDIAG:
Invoke-Command `
    -ComputerName $DCs.name `
    -ArgumentList $Date,$DCDiagBackupPath `
    -ScriptBlock {
        $Date = $args[0]
        $DCDiagBkupLoc = $args[1]

        dcdiag /a /f:"$DCDiagBkupLoc\$Date-$env:computername-dcdiag.log"        
}