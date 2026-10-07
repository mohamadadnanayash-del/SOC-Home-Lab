<#
  SOC Home Lab - PowerShell logging
  Run as Administrator on WIN-ENDPOINT01. Applies to new PowerShell sessions.
#>

$base = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"

# Script Block Logging -> Event 4104
New-Item "$base\ScriptBlockLogging" -Force | Out-Null
Set-ItemProperty "$base\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1

# Module Logging -> Event 4103
New-Item "$base\ModuleLogging\ModuleNames" -Force | Out-Null
Set-ItemProperty "$base\ModuleLogging" -Name EnableModuleLogging -Value 1
Set-ItemProperty "$base\ModuleLogging\ModuleNames" -Name "*" -Value "*"

# Transcription
New-Item C:\PSTranscripts -ItemType Directory -Force | Out-Null
New-Item "$base\Transcription" -Force | Out-Null
Set-ItemProperty "$base\Transcription" -Name EnableTranscripting -Value 1
Set-ItemProperty "$base\Transcription" -Name EnableInvocationHeader -Value 1
Set-ItemProperty "$base\Transcription" -Name OutputDirectory -Value "C:\PSTranscripts"

wevtutil sl "Microsoft-Windows-PowerShell/Operational" /ms:268435456
