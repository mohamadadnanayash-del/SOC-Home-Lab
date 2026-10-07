# Setup: Windows 11 Endpoint

## VM

`WIN-ENDPOINT01`: Windows 11 Enterprise Evaluation, 2 vCPU, 4 GB RAM, 64 GB disk, EFI + TPM 2.0, NAT Network `SOC-LAB`. A local account was created with "Domain join instead".

## Network and hostname

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.10.20 -PrefixLength 24 -DefaultGateway 10.10.10.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 1.1.1.1,8.8.8.8
New-NetFirewallRule -DisplayName "LAB - Allow ICMPv4 In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -RemoteAddress 10.10.10.0/24
Set-TimeZone -Id "Arabian Standard Time"
Rename-Computer -NewName "WIN-ENDPOINT01" -Restart
```

## Wazuh agent

The install command is generated in the dashboard (Agents management → Deploy new agent) with manager `10.10.10.10` and agent name `WIN-ENDPOINT01`:

```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-<version>-1.msi -OutFile $env:tmp\wazuh-agent
msiexec.exe /i $env:tmp\wazuh-agent /q WAZUH_MANAGER='10.10.10.10' WAZUH_AGENT_NAME='WIN-ENDPOINT01'
NET START Wazuh
```

Verify with:

```powershell
Get-Service WazuhSvc
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 20   # "Connected to the server"
```

## Audit policy and PowerShell logging

These are applied with the scripts in `configs/`:

| Script | What it enables |
|---|---|
| `configs/auditpol-baseline.ps1` | Logon/logoff, account management, process creation with command line, scheduled tasks, service installs, audit-policy changes, account lockout policy, larger Security log |
| `configs/powershell-logging.ps1` | Script Block Logging (4104), Module Logging (4103), transcription to `C:\PSTranscripts` |

The scripts also enable the Task Scheduler Operational log, which is off by default, and create `C:\LabData` as the FIM-monitored folder.

## Snapshots

| Snapshot | State |
|---|---|
| `01-windows-clean-install` | Fresh OS, network configured |
| `02-windows-agent-sysmon` | Wazuh agent + Sysmon |
| `03-logging-complete` | Audit policy, PowerShell logging, central agent config |
