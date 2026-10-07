# Event ID Reference

The Windows and Sysmon events this lab collects, and why each one matters during triage.

## Windows Security log

| Event ID | Meaning | Triage notes |
|---|---|---|
| 4624 | Successful logon | Check Logon Type: 2 interactive, 3 network, 7 unlock, 10 RDP, 11 cached. Type 3/10 from an unexpected source IP deserves a look. |
| 4625 | Failed logon | SubStatus: `0xC000006A` bad password, `0xC0000064` unknown user, `0xC0000234` locked out |
| 4740 | Account locked out | Commonly follows brute-force attempts |
| 4648 | Logon with explicit credentials | `runas`, lateral movement |
| 4672 | Special privileges assigned | Admin-equivalent logon |
| 4688 | Process created | Command line included (enabled by the baseline) |
| 4697 | Service installed | Persistence / remote execution |
| 4698 / 4699 / 4702 | Scheduled task created / deleted / updated | Persistence |
| 4720 / 4722 | User created / enabled | Backdoor accounts |
| 4728 / 4732 | Member added to global / local group | Privilege escalation |
| 4719 | Audit policy changed | Defense evasion |
| 1102 | Security log cleared | Escalate by default |

## Sysmon

| ID | Event | Triage notes |
|---|---|---|
| 1 | Process create | Image, command line, parent process, hashes, user |
| 3 | Network connection | Process-to-IP/port mapping |
| 5 | Process terminated | Process lifetime in timelines |
| 11 | File create | Dropped files, Startup folder, scripts |
| 12 / 13 / 14 | Registry create / set / rename | Run keys, services, Winlogon |
| 22 | DNS query | Which process resolved which domain |
| 25 | Process tampering | Hollowing / herpaderping indicators |

## Other channels

| Channel | ID | Meaning |
|---|---|---|
| PowerShell/Operational | 4104 | Script block text (logged after de-obfuscation) |
| PowerShell/Operational | 4103 | Module / pipeline execution |
| Windows PowerShell | 400 / 600 | Engine start with HostApplication (full command line) |
| TaskScheduler/Operational | 106 / 140 / 141 | Task registered / updated / deleted |
| TaskScheduler/Operational | 200 / 201 | Task action started / completed |
| System | 7045 | New service installed |
| Defender/Operational | 1116 / 1117 | Threat detected / action taken |
| Defender/Operational | 5001 / 5007 | Real-time protection disabled / configuration changed |
| Wazuh FIM | 550 / 553 / 554 | File modified / deleted / added |
