<#
.SYNOPSIS
  Provides location info for a specific IP

.NOTES
  Author: Tom Biscardi
  Email:   biscardi (at) outlook.com
  Date:    12/10/2018

.DESCRIPTION
  - Gives location information of a provided IP
#>

#Function Definitions 
#Note: Start-Rerun has to be defined first since it's called in the Get-GeoIpInfo function.)
Function Start-Rerun {
        $IP = Read-Host "`nEnter an IP address to search"
        
        #Calls the Function (Again)
        Get-GeoIpInfo -IP $IP
}

function Get-GeoIpInfo{
    [CmdletBinding()]
    param([string]$IP)

    $IP | % {
        #Builds a URL with an API that'll give you more info for an IP.
        $IPLookupURL = "https://ipapi.co/$IP/json"

        <#Other options in the event of API Shutdown:
            https://ipapi.co/_._._._/json  | http://www.geoplugin.net/json.gp?ip=_._._._
            http://ip-api.com/json/_._._._ | https://extreme-ip-lookup.com/json/_._._._     
            https://api.snoopi.io/_._._._  | https://www.iplocate.io/api/lookup/_._._._    
        #>

        #Calls the API, saves results to a variable
        $IPInfo = Invoke-RestMethod -Uri $IPLookupURL -ContentType "application/json" 

        #Let the user know we've gathered some info on the IP:
        Write-Host -f Yellow "More info on the IP you've provided:"
        $IPInfo | Out-Host   #Displays the info in gathered from the API
    }

    #Asks the user if the script should be rerun for an additional IP
    $Rerun = Read-Host "Rerun for new IP? (y/n)"
    if (($Rerun -eq "y") -or ($Rerun -eq "Y")){
        Start-Rerun
    }
}

#Tells the script operator the purpose of the script
Write-Host -f Cyan "`nPurpose:"
    "This function takes an IP address and displays location information associated with it."
$IP = Read-Host "`nEnter an IP address to search"

#Calls the Function
Get-GeoIpInfo -IP $IP