# Offboard-Users.ps1

$leavers = Import-Csv "C:\Scripts\leavers.csv"
$logFile = "C:\Scripts\offboarding-log.txt"
$disabledOU = "OU=Disabled Users,OU=XYZ Company,DC=corp,DC=local"

foreach ($person in $leavers) {

    $samAccountName = $person.SamAccountName

    # Check: does this user actually exist?
    $adUser = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue

    if (-not $adUser) {
        $logMessage = "$(Get-Date) - SKIPPED - User $samAccountName does not exist"
        Add-Content -Path $logFile -Value $logMessage
        Write-Host $logMessage -ForegroundColor Yellow
        continue
    }

    try {
        # Step 1: Disable the account
        Disable-ADAccount -Identity $samAccountName -ErrorAction Stop

        # Step 2: Remove from all groups (except Domain Users, which can't be removed)
        $groups = Get-ADUser -Identity $samAccountName -Properties MemberOf | Select-Object -ExpandProperty MemberOf
        foreach ($group in $groups) {
            Remove-ADGroupMember -Identity $group -Members $samAccountName -Confirm:$false
        }

        # Step 3: Move to Disabled Users OU
        Move-ADObject -Identity $adUser.DistinguishedName -TargetPath $disabledOU

        $logMessage = "$(Get-Date) - SUCCESS - Disabled $samAccountName, removed from all groups, moved to Disabled Users OU"
        Add-Content -Path $logFile -Value $logMessage
        Write-Host $logMessage -ForegroundColor Green

    } catch {
        $errorMessage = "$(Get-Date) - FAILED - Could not offboard $samAccountName - Error: $($_.Exception.Message)"
        Add-Content -Path $logFile -Value $errorMessage
        Write-Host $errorMessage -ForegroundColor Red
    }
}