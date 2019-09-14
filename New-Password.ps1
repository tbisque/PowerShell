function New-Password {
    
    [array]$PWChars = [char[]](63..78+80..90+97..107+109+110+112..122+48..57+35..38+42+33+61)
    [string]$PW = 0..9 | % {$PWChars | Get-Random}
    $global:PW = $PW.Replace(" ","")
    $global:PW
}
