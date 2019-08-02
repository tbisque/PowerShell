<#
.SYNOPSIS
  Removes files older than X days

.NOTES
  Author:   Tom Biscardi
  Email:    biscardi (at) outlook (dot) com
  Date:     2/13/2018
  Modified: 2/1/2019

.DESCRIPTION
  - Looks for files in a file path older than $DaysBack.
  - Removes files in a file path that are older than $DaysBack.
#>

#Variable Definition
$CurrentDate = Get-Date
$Path = "\\exchangesrv1\c`$\inetpub\logs\LogFiles\W3SVC1"
$DaysBack = 30

Function Delete-FilesOlderThanXDays {
    [CmdletBinding()]
    param([string]$Path,
          [string]$DaysBack)

    #Calculates Date of Oldest File we'll keep
    $DatetoDelete = $CurrentDate.AddDays(-$Daysback)

    # Gets all items within a folder older than $Daysback, deletes them 
    Get-ChildItem $Path | 
        Where-Object {$_.LastWriteTime -lt $DatetoDelete} |
    Remove-Item -WhatIf
}

Delete-FilesOlderThanXDays -Path $Path -DaysBack $DaysBack
