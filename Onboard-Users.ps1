# Onboard-Users.ps1 - Step 2: Actually creates AD users

$newHires = Import-Csv "C:\Scripts\newhires.csv"
$logFile = "C:\Scripts\onboarding-log.txt"
$defaultPassword = "Welcome123!"

foreach ($person in $newHires) {

    $samAccountName = ($person.FirstName + "." + $person.LastName).ToLower()
    $displayName = "$($person.FirstName) $($person.LastName)"
    $upn = "$samAccountName@corp.local"
    $ouPath = "OU=$($person.Department),OU=Employees,OU=XYZ Company,DC=corp,DC=local"
    $groupName = "SG-$($person.Department)"

    try {
        New-ADUser `
            -Name $displayName `
            -GivenName $person.FirstName `
            -Surname $person.LastName `
            -SamAccountName $samAccountName `
            -UserPrincipalName $upn `
            -Path $ouPath `
            -Department $person.Department `
            -Title $person.JobTitle `
            -EmailAddress $upn `
            -AccountPassword (ConvertTo-SecureString $defaultPassword -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Add-ADGroupMember -Identity $groupName -Members $samAccountName

        $logMessage = "$(Get-Date) - SUCCESS - Created user $samAccountName in $ouPath, added to $groupName"
        Add-Content -Path $logFile -Value $logMessage
        Write-Host $logMessage -ForegroundColor Green

    } catch {
        $errorMessage = "$(Get-Date) - FAILED - Could not create $samAccountName - Error: $($_.Exception.Message)"
        Add-Content -Path $logFile -Value $errorMessage
        Write-Host $errorMessage -ForegroundColor Red
    }
}