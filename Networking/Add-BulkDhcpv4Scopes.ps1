<#
.SYNOPSIS
  Bulk Add DHCP Scopes & Options

.NOTES
  Author:  Tom Biscardi
  Email:   biscardi (at) outlook.com
  Date:    10/9/2019

.DESCRIPTION
    - Imports a CSV to variable
    - Creates a list of servers to perform the actions on
    - Starts a PowerShell session into them
    - Runs a script block of code on each server (via Invoke-Command)
        = Add a new printer port for the new IP
        = Change existing printer to use the newly added port associated with it
        = Deletes the old, now unused port (Future: Confirm it's not used first)

.Inputs
    $CsvPath containing the following headers: Name (for the scope name), Description, StartRange, EndRange, SubnetMask, LeaseDuration, ScopeOption (Define Splat Variable for all appropriate options)
#>

#Variable Definitons:
$DhcpServer = "Server1"
$CsvPath = "\\fileserver\it\scripts\DHCP.csv"
$Scopes = Import-Csv -Path $CsvPath

#Variables for splatting Scope Options
$WirelessScopeOptions = @{
    Name = "Wireless"
    Description = ""
    OptionId = ""
    Type = "String"
    VendorClass = $null
    ComputerName = $DhcpServer
}

$PhoneScopeOptions = @{
    Name = "Phone"
    Description = ""
    OptionId = ""
    Type = "String"
    VendorClass = $null
    ComputerName = $DhcpServer
}



$Scopes | ForEach-Object {
    Add-DhcpServerv4Scope `
        -ComputerName $DhcpServer `
        -Name $_.Name `
        -Description $_.Description `
        -StartRange $_.StartRange `
        -EndRange $_.EndRange `
        -SubnetMask $_.SubnetMask ` 
        -LeaseDuration $_.LeaseDuration ` #in the format day.hrs:mins:secs (example & Default: 8.00:00:00)
        -State Active
}

$Scopes | ForEach-Object {
    if ($_.ScopeOption -eq "Phone"){
        Set-DhcpServerv4OptionDefinition $_.Name $PhoneScopeOptions 
    }
    elseif ($_.ScopeOption -eq "Wireless"){
        Set-DhcpServerv4OptionDefinition $_.Name $WirelessScopeOptions
    }
    else{
        Write-Warning "No scope options defined for the following scope:" $_.Name
    }
}
