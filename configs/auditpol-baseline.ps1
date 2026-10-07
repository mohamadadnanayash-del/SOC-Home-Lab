<#
  SOC Home Lab - Windows audit policy baseline
  Run as Administrator on WIN-ENDPOINT01.
#>

# Subcategory policy overrides legacy category policy
reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f

# Logon / authentication
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Logoff" /success:enable
auditpol /set /subcategory:"Special Logon" /success:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
auditpol /set /subcategory:"Credential Validation" /success:enable /failure:enable
auditpol /set /subcategory:"Other Logon/Logoff Events" /success:enable /failure:enable

# Account and group management
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable

# Process creation (4688) and service installation (4697)
auditpol /set /subcategory:"Process Creation" /success:enable
auditpol /set /subcategory:"Security System Extension" /success:enable

# Scheduled tasks (4698-4702) and file system (Wazuh FIM whodata)
auditpol /set /subcategory:"Other Object Access Events" /success:enable /failure:enable
auditpol /set /subcategory:"File System" /success:enable

# Audit / log tampering
auditpol /set /subcategory:"Audit Policy Change" /success:enable /failure:enable
auditpol /set /subcategory:"Security State Change" /success:enable

# Full command line in 4688
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

# Lockout policy: 5 failures -> 15 minute lockout (produces 4740)
net accounts /lockoutthreshold:5 /lockoutduration:15 /lockoutwindow:15

# Log sizes
wevtutil sl Security /ms:524288000
wevtutil sl "Microsoft-Windows-Sysmon/Operational" /ms:268435456

# Task Scheduler Operational is disabled by default
wevtutil sl "Microsoft-Windows-TaskScheduler/Operational" /e:true

# FIM test folder
New-Item C:\LabData -ItemType Directory -Force | Out-Null
"Quarterly finance figures - LAB DATA" | Out-File C:\LabData\finance-report.txt

auditpol /get /category:*
