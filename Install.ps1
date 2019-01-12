if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


if (-not (Get-Module -Name "MSStore")) {
    Install-Module -Name MSStore
}

if (-not (Get-Module -Name "AzureADPreview")) {
    Install-Module -Name AzureADPreview
}

if (-not (Get-Module -Name "MSOnline")) {
    Install-Module -Name MSOnline
}
