<#
.SYNOPSIS
  Gets Accounts in the Local Administrator Group

.NOTES
  Author: Tom Biscardi
  Email:   biscardi (at) outlook (at) com
  Date:    05/04/2018

.DESCRIPTION
  - Creates a folder for exports at a specified UNC Path 
  - Grabs all non-servers computer objects from AD
  - Finds Local  & Domain accounts within the Local Administrators Group on each workstation
  - Exports results
  - Filters out the IT accounts, exports those results
  - Compares our initial results to the computers we found from AD, and finds which computers didn't ping
  - Exports the failures
#>

# Gets the Current date, in a specific format, saves it to a variable
$Date = (Get-Date).tostring('yyyy-MM-dd')

# Defining a folder we'll create for this Round's Procedure
$ExportRoot = "\\UNCPATH\Scripts\Outputs\Admin Rights\$Date"

# Variables defining where we will Export
$ExportFileSrv = "$ExportRoot\LocalUsers-$Date.csv"
$ExportNonIT = "$ExportRoot\NonITLocalAdmins-$Date.csv"
$ExportFailures = "$ExportRoot\FailedComputers-$Date.csv"

# Builds root directory for our all our variables
New-Item -Path $ExportRoot -ItemType Directory -ErrorAction SilentlyContinue -ErrorVariable e| out-null

#Tests to ensure the directory was built
$TestDir = Test-Path $ExportRoot 

# If the path was created successfully:
If ($TestDir -eq $true){
    # Tells the User the path was created
    Write-Host "`n`nSuccessfully created: `n$ExportRoot`n"
}
# If the path wasn't created successfully:
else {
    # Error checking. Pauses the script if the directory isn't created
    Write-Warning "Failed to create: $ExportRoot. `nIt may already exist, but please investigate before continuing.`n`n"
    Pause
}

# Queries AD to find all Windows 7 or windows 10 computers
$Comps = Get-ADComputer `
    -filter 'operatingsystem -notmatch "Server"' `
    -Properties operatingsystem, primarygroup, description

#Counter Variables
$c = 0
$total = $Comps.Count
$Percentage=0

# Tells the Admin running script how many computers it's being run against
# Also adds in a few lines for formatting after to show content below our progress bar
Write-Host "Now Processing" $Comps.count "Computers`n`n`n`n`n"

#Goes through all of our computers, and performs the action between the {} on each of them
$Comps.Name | % {

    #Updates the admin running script on progress
    Write-Host "Now Processing: "$_ -f Green

    #Sets a variable for this name to be the current computer name. Sometimes $_ (what we're passing through via the | ) doesn't 
    $ThisName = $_
    
    # Calculates a percentage to display in a progress bar. Puts it in a nicely formatted number.
    $Percentage = $Percentage| %{$_.ToString('#.##')}
    
    # Shows a Progress Bar
    Write-progress -Activity "Obtaining Admin Group from Each Computer" `
        -PercentComplete $Percentage `
        -Status "$Percentage% Complete. $c of $total Computers Processed"

    # Test Connection (Ping) the computer we're working on
    $PingTest = Test-Connection -Count 1 -ComputerName $ThisName -Quiet
    
    # If the ping fails, 
    if ($PingTest -eq $false){
        Write-Warning "$ThisName is offline"
        $Failed += $ThisName
    }
    else{
        $LocAdminGroup = [ADSI] "WinNT://$ThisName/Administrators,Group"
        $LocAdmins = $locAdminGroup.Members() | ForEach-Object {
            $_.GetType().InvokeMember("Name", "GetProperty", $NULL, $_, $NULL)
        }
        # Adding to the Global List
        $AllAdmins += $LocAdmins | Select-Object `
            @{Name="ComputerName"; Expression={$ThisName}}, `
            @{Name="Member"; Expression={$_}}
    }
    
    #Increments the counter
    $c ++
    #Calculates the percentage
    $Percentage=($c/$total)*100
    #Closes our Progress bar if we're done
    if ($c -eq $total){Write-progress -Activity "Obtaining Admin Group from Each Computer" -Completed}
}# foreach

#Takes our results, exports them to a network path we've already defined
$AllAdmins | Export-Csv -NoTypeInformation $ExportFileSrv

# Test to see if there is a file where we attempted to export. If so, we tell the user
$TestExportPath = Test-Path $ExportFileSrv 
If ($TestExportPath -eq $true){
    Write-Host "`nSuccessfully Exported to: `n$ExportFileSrv"
}

# Copies Admins to NonIT
$NonIT = $AllAdmins

# Filters out the IT Members from our original list
$NonIT = $NonIT | Where-Object {
    $_.Member -notmatch `
        "Administrator|Domain Admins|LaptopAdmin|ServerAdministrators|sqlserviceaccnt|RemoteControlGateway"
}

# Takes our filtered list, exports it to a path we've already defined
$NonIT | Export-Csv -NoTypeInformation $ExportNonIT

# Compares Script Results (computer names specifically) to the computer list we obtained from AD. 
# Saves all of it to a variable with only the computer names
$NotScanned = Compare-Object -DifferenceObject $AllAdmins.ComputerName -ReferenceObject $Comps.Name `
    | Where-Object {$_.SideIndicator -eq "<="} | select InputObject -ExpandProperty InputObject

If ($NotScanned -ne $null){
    $FailedCount = $NotScanned.Count
    Write-Warning "The Following Computers were not scanned:`n"
    Write-Host $NotScanned -Separator "`n" -BackgroundColor Black -ForegroundColor Yellow 
    Write-Warning "$FailedCount computers were not scanned successfully. See them above."
    $NotScanned | Export-Csv $ExportFailures -NoTypeInformation
}