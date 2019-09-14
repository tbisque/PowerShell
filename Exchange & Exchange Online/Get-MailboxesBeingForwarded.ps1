#.Requires PSSnapin for Exchange, or Exchange Online POSH Connection.

#Goes through each mailbox, and looks for accounts with forwarding enabled
Get-Mailbox | 
	Where-Object {$_.ForwardingAddress -ne $null} | 
	Select-Object Name, PrimarySmtpAddress, ForwardingAddress
