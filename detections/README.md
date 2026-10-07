# Detections

Custom Wazuh rules live in [`rules/soc_lab_rules.xml`](rules/soc_lab_rules.xml) (ID range 100100-100199, group `soc_lab`). Each rule chains off a built-in Wazuh parent (`sysmon_event1`, `sysmon_event_13`, `91802`), so it inherits the built-in decoding.

| Rule ID | Name | Data source | Level | ATT&CK |
|---|---|---|---|---|
| 100101 | PowerShell encoded command | Sysmon 1 | 10 | T1059.001, T1027 |
| 100102 | Suspicious PowerShell script block | PowerShell 4104 | 8 | T1059.001 |
| 100103 | Registry Run key modification | Sysmon 13 | 10 | T1547.001 |
| 100104 | Scheduled task created via schtasks | Sysmon 1 | 8 | T1053.005 |
| 100105 | Executable run from user-writable path | Sysmon 1 | 7 | n/a |
| 100106 | Discovery command executed | Sysmon 1 | 4 | T1033, T1082 |
| 100107 | Discovery command burst (correlation) | Sysmon 1 | 10 | T1033, T1082 |

## Validation

Each rule was tested on WIN-ENDPOINT01 with benign activity:

| Rule | Test |
|---|---|
| 100101 | `powershell -enc <base64 of Write-Output "SOC-LAB encoded test">` |
| 100102 | `Invoke-Expression "Write-Output 'SOC-LAB 4104 test'"` |
| 100103 | `reg add HKCU\...\CurrentVersion\Run /v SOCLabTest ...` (then removed) |
| 100104 | `schtasks /create /tn "SOCLab-Test" ...` (then deleted) |
| 100105 | Copied `whoami.exe` to `C:\Users\Public\labtest.exe` and ran it |
| 100106/100107 | `whoami; ipconfig; systeminfo; net user; tasklist` within 2 minutes |

Detailed per-rule write-ups (logic, false positives, triage steps) are added in the detection engineering phase. See also the [Event ID reference](event-id-reference.md).
