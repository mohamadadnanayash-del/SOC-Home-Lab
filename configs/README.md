# Configs

| File | Applied on | Purpose |
|---|---|---|
| `auditpol-baseline.ps1` | WIN-ENDPOINT01 | Advanced audit policy, command-line logging, lockout policy, log sizes |
| `powershell-logging.ps1` | WIN-ENDPOINT01 | Script Block, Module and Transcription logging |
| `agent.conf` | soc-wazuh (`/var/ossec/etc/shared/default/`) | Central agent config: event channels and FIM |

The Sysmon configuration is the unmodified [SwiftOnSecurity sysmon-config](https://github.com/SwiftOnSecurity/sysmon-config) (`sysmonconfig-export.xml`). See `setup/sysmon.md` for install steps.
