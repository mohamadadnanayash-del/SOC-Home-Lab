# Setup: Sysmon

Sysmon gives process-level detail that native Windows logs don't: parent/child relationships, full command lines, file hashes, and per-process network, registry and DNS activity.

## Install

```powershell
New-Item -ItemType Directory -Path C:\Tools\Sysmon -Force | Out-Null
cd C:\Tools\Sysmon
Invoke-WebRequest https://download.sysinternals.com/files/Sysmon.zip -OutFile Sysmon.zip
Expand-Archive Sysmon.zip -DestinationPath . -Force
Invoke-WebRequest https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml -OutFile sysmonconfig.xml
.\Sysmon64.exe -accepteula -i .\sysmonconfig.xml
```

## Configuration choice

The lab uses the [SwiftOnSecurity sysmon-config](https://github.com/SwiftOnSecurity/sysmon-config) baseline. It logs the high-value events and filters most routine Windows noise, which keeps a single-endpoint lab readable.

| Sysmon ID | Event | Coverage in this config |
|---|---|---|
| 1 | Process create | Yes, with noise exclusions |
| 3 | Network connection | Selective (suspicious binaries and ports) |
| 11 | File create | Risky paths (Startup, Tasks, Temp, scripts) |
| 12/13/14 | Registry | Persistence-related keys |
| 22 | DNS query | Yes, common Microsoft domains excluded |

To apply config changes:

```powershell
C:\Tools\Sysmon\Sysmon64.exe -c C:\Tools\Sysmon\sysmonconfig.xml
```

## Forwarding to Wazuh

The Sysmon channel is collected through the central agent config (`configs/agent.conf`):

```xml
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

## Verify

```powershell
Get-Service Sysmon64
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
```

In the dashboard (Threat Hunting):

```
agent.name:WIN-ENDPOINT01 and data.win.system.channel:"Microsoft-Windows-Sysmon/Operational"
```

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| "Failed to open configuration file" | Bad path or an incomplete download. Re-download the XML. |
| Events on the host but not in Wazuh | Channel name typo (it's case-sensitive), agent not restarted, or the event didn't match a rule. Check `wazuh-archives-*`. |
| Agent won't start after config edits | Broken XML in `ossec.conf` / `agent.conf` |
