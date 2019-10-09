<#
.SYNOPSIS
  Change printer port IP for multiple printers isntalled on a print server

.NOTES
  Author:  Tom Biscardi
  Email:   biscardi (at) outlook.com
  Date:    10/17/2017
  Updated: 10/9/2019

.DESCRIPTION
    - Saves CSV to variable
        = Easiest way to do this is to export a list from MMC Print Management
    - Creates a list of servers to perform the actions on
    - Starts a PowerShell session into them
    - Runs a script block of code on each server (via Invoke-Command)
        = Add a new printer port for the new IP
        = Change existing printer to use the newly added port associated with it
        = Deletes the old, now unused port (Future: Confirm it's not used first)

.Inputs
    $CsvPath containing the following headers: ServerName,PrinterName,CurrentIP,FutureIP
#>

#Variable Definitons:
$Servers = "Server1","Server2","Server3","Server4"
$UserCredential = Get-Credential -Message "Enter Admin Credentials for $Servers"
$ServerSessions = New-PSSession -ComputerName $Servers -Credential $UserCredential
$CsvPath = "\\fileserver\it\scripts\Printers.csv"
$Printers = Import-Csv -Path $CsvPath

#Runs a Powershell command within the Sessions we connected above
Invoke-Command -Session $ServerSessions -ArgumentList $CSVPrinters -ScriptBlock {

    #ScriptBlock Variable Definitions:
    $Printers = $args[0]

    #Goes through each line of the CSV. Sees if that line is for this specific server.
    #If so, it adds the new printer port for the new IP, assigns the printer to that IP, and deletes the old port.
    $Printers | ForEach-Object {
        if ($_.ServerName -match $env:COMPUTERNAME){

            try{Add-PrinterPort -Name $_.FutureIP -PrinterHostAddress $_.FutureIP}
            catch{Write-Warning "Failed to create printer port:" $_.FutureIP}
            
            try{Set-Printer -Name $_.PrinterName -PortName $_.FutureIP}
            catch{Write-Warning "Failed to reassign Port on:" $_.PrinterName}

            #Comment out these next two lines to keep the old IP port on the server.
            try{Remove-PrinterPort -Name $_.CurrentPort}
            catch{Write-Warning "Failed to remove old port on:" $_.PrinterName}
        }
    }
}
