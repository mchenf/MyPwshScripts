# Add-HostsPortInterface.ps1
# Version 1.0.0.2
# Modified 1/21/2025
# Author: mochen@foss.dk

<#
.SYNOPSIS
    向本地 windows 的 hosts 文件中注入一行记录，并且改变本地的端口代理
.DESCRIPTION
    向本地 windows 的 hosts 文件中注入一行记录，并且改变本地的端口代理
.NOTES
    向本地 windows 的 hosts 文件中注入一行记录，并且改变本地的端口代理。仅供广西农垦永新使用
.EXAMPLE
    PS> .\Add-LocalHosts.ps1
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Default
)

[string]$dirHosts = [System.IO.Path]::Combine(
    [System.Environment]::SystemDirectory,
    "drivers",
    "etc",
    "hosts"
);

Write-Host -Message "The default directory is:"
Write-Host -Message $dirHosts

if (-not [System.IO.File]::Exists($dirHosts)) {
    Write-Host -Message ">> ERROR 100! << The hosts file does not exist here, exiting..." 
    exit 100
}
Write-Host -Message "Hosts file located, continuing.." 
[string]$targetDns = "nirs.gxnkyx.com"
$lookupResolveErr = Resolve-DnsName -Name $targetDns 2>&1

if($lookupResolveErr -is [System.Management.Automation.ErrorRecord]){
    Write-Host -Message ">> NOT FOUND << Local DNS lookups CANNOT resolve $targetDns, injecting..." 
} else {
    Write-Host -Message "Local DNS lookups successfully resolved $targetDns as below:" 
    Resolve-DnsName -Name $targetDns
    Write-Host -Message "-----------------------------" 
    Write-Host -Message "Check if correct." 
    exit 200
}



Add-Content -Value "127.0.0.1      $targetDns      #Guangxi Nongken Yongxin DNS Loopback" -Path $dirHosts -Confirm