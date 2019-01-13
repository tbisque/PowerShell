<#
.SYNOPSIS
  Process RemoteApp Logs

.NOTES
  Author: Tom Biscardi
  GitHub: tbisque
  Email:  biscardii (at) outlook (dot) com
  Date:   11/1/2018
  
.DESCRIPTION
  - Grabs the RA logs from the past month
    = Should be run on the first of the month, as a scheduled task
  - Parses them into a CSV saved to a network path ($FilePath)
#>

# Defines the name of the log
$LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'

# Saves today's date to the Year-Month-Day format
$Date = (Get-Date).tostring('yyyy-MM-dd')
$PastMonth = (Get-Date).AddMonths(-1)

# Creates the Filename and the path to export
$FileName = ($PastMonth.tostring('yyyy-MM-dd')+"_to_"+(Get-Date).ToString('yyyy-MM-dd'))
$FilePath = "\\uncpath\Scripts\Outputs\RemoteAppLogs\$FileName.csv"

# Gets the log events from the past month. Looks only for certain IDs.
$Logs = Get-WinEvent -LogName $LogName -Oldest |
    where {
        $_.TimeCreated -ge $PastMonth -and `
        $_.id -match "21|22|23|24|25"}

# Takes the logs we've obtained, formats them to xml for further processing.
$Logs | ForEach-Object {
    $entry = [xml]$_.ToXml()
    [array]$LogArray+= New-Object PSObject -Property @{
        TimeCreated = $_.TimeCreated
        User = $entry.Event.UserData.EventXML.User
        IPAddress = $entry.Event.UserData.EventXML.Address
        EventID = $entry.Event.System.EventID
    }
}

# Takes the XML and processes it to an output.
# These steps add a property called Action with the corresponding names for the IDs below
$Output += $LogArray | 
    Select TimeCreated, User, IPAddress, 
        @{Name='Action';Expression={
            if ($_.EventID -eq '21'){"logon"}
            if ($_.EventID -eq '22'){"Shell start"}
            if ($_.EventID -eq '23'){"logoff"}
            if ($_.EventID -eq '24'){"disconnected"}
            if ($_.EventID -eq '25'){"reconnection"}
            }
        }

# Takes our output, sorts it based on when it was created, and exports it.
$Output |
    Sort-Object TimeCreated -Descending |
    select TimeCreated, IPAddress, User, Action |
    Export-Csv -Path $FilePath -NoClobber -NoTypeInformation