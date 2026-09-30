# Active Directory User Onboarding/Offboarding Automation

PowerShell automation that provisions and deprovisions Active Directory user accounts 
from CSV input, built and tested in a self-hosted hybrid-style IT lab.

## Overview

Manually onboarding and offboarding employees in Active Directory is repetitive and 
error-prone missed group assignments, inconsistent naming, forgotten access removal 
on exit are common real-world IT risks. This project automates that process end-to-end, 
with input validation, error handling, and full audit logging.

## Lab Environment

- **Domain Controller:** Windows Server 2022, Active Directory Domain Services + DNS
- **Domain-joined client:** Windows 10 Pro, used to validate real domain authentication
- **Virtualization:** VirtualBox, isolated internal network
- **Directory structure:** Multi-tier OU hierarchy (Employees → IT/Sales/HR), 
  department-based security groups (SG-IT, SG-Sales, SG-HR)

## What the scripts do

### Onboard-Users.ps1
- Reads new-hire data from a CSV (FirstName, LastName, Department, JobTitle)
- Validates each row (missing fields, duplicate accounts, invalid/nonexistent department)
- Creates the AD user account with correct SamAccountName/UPN
- Places the account in the correct department OU
- Adds the account to the matching department security group
- Logs every action (success or skip reason) with a timestamp

### Offboard-Users.ps1
- Reads a list of departing employees (SamAccountName) from CSV
- Validates the account exists before acting
- Disables the account (does not delete — preserves audit trail)
- Removes the account from all group memberships
- Moves the account to a dedicated "Disabled Users" OU
- Logs every action with a timestamp

## Sample usage

```powershell
.\Onboard-Users.ps1
.\Offboard-Users.ps1
```

## Validation

Both scripts were tested end-to-end, including:
- Live domain authentication on a separate client machine, confirming correct 
  OU placement and group membership (verified via `whoami /groups`)
- Error-handling test cases: duplicate users, blank CSV fields, invalid department names

## Known limitations / next steps

- Entra ID / Microsoft Graph integration (cloud sync, license assignment) designed 
  but not live-tested, due to Microsoft 365 Developer Program eligibility restrictions
- Email notification step not yet implemented

## Tech stack

PowerShell, Active Directory Domain Services, Group Policy, Windows Server 2022
