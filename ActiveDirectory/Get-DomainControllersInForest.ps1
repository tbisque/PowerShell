#Gets all the domains in the forest, including sub-domains
$Domains = Get-ADForest | Select-Object Domains -ExpandProperty Domains

#Gets all the DCs in the forest
$DCs = $Domains | Foreach-object {
    Get-ADDomainController -Filter * -Server $_
}
