#Generates a password between 64 and 75 characters with numbers and special characters

function New-Password {
    
	$length = Get-Random -Minimum 64 -Maximum 75
	
	[array]$pwchars = [char[]](33..126)

	[string]$PW = 0..$length | Foreach-Object {$PwChars | Get-Random}

	$PW = $PW.Replace(" ","")
	
	return $pw
}
