#Forces all users in $users to reset their password at next login
$users = "user1","user2" #follow same format if additional users are required.
#Note: There's very likely a more efficient way to do this...

#Goes through each User in $Users, sets their accounts to 
$users | ForEach-Object {
    try {Get-aduser $_ | Set-ADUser -ChangePasswordAtLogon:$true}
    catch {Write-Warning "$_ not found"}
}