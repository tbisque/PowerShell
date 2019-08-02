Write-warning "This will take forever! I suggest taking a walk."
Get-Addresslist CGEmployeesAddressList | 
    Where-Object Name -NotMatch "All|Public|Blank|Offline" | 
    ForEach-Object{
        Get-Recipient -ResultSize Unlimited | 
            Where-Object addresslistmembership -match $_.Name | 
            Select-Object identity,alias,primarysmtpaddress,externalemailaddress,windowsLiveID,emailaddresses,`
                company,department,office,city,title,addresslistmembership,mailboxmoveremotehostname |
            Out-GridView -Title $_.Name
}
