## ByPass-MosaicX509Setting.ps1
## Author:      mochen@foss.dk
## Created:     3/30/2023
## Modified:    3/31/2023
## Version:     1.0.0.1

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ConfigFile
)
[string]$xmlFilePath = ""
try {
    $xmlFilePath = Resolve-Path $ConfigFile -ErrorAction Stop | Select-Object -ExpandProperty Path
}
catch {
    Write-Warning "File `"$ConfigFile`" does not exist. It is moved, deleted, or invalid.."
    Write-Warning "Exiting..."
    Exit;
}
$xml = New-Object xml
try {
    $xml.Load($xmlFilePath)
}
catch {
    Write-Host "`"$xmlFilePath`" is not a valid xml file. Exiting..."
}

[string]$oldstring = $xml.Configuration.Runtime.AppContextSwitchOverrides.Value

if($oldstring.Length -eq 0)
{
    Write-Warning "Configuration.Runtime.AppContextSwitchOverrides.Value does not exist."
    Write-Warning "Please check if:`r`n$xmlFilePath`r`n...is a valid mosaic.exe.config file."
    Exit
}
$oldstring = $oldstring -replace '\s', ''
[string[]]$oldVal = $oldstring -split ";"
Write-Debug $($oldVal -join ";")
$x509ByPass = "Switch.System.IdentityModel.DisableCngCertificates=false";
Write-Host "Searching for `"$x509ByPass`"..."
[bool]$needModification = $oldVal -notcontains $x509ByPass
Write-Host "...in Current AppContextSwitchOverrides Setting:"
for($i=0;$i -lt $oldVal.Length; $i++)
{
    Write-Host "[$i] $($oldVal[$i])"
}
Write-Host "`r`n`r`n"
if ($needModification) {
    "Modification is needed." | Write-Host
    $answer = ""
    while ($answer -inotmatch "(yes)|(no)") {
        $answer = Read-Host -Prompt "Change the setting file? (Yes/No)"
    }
    
    if($answer -imatch "no")
    {
        Write-Host "Nothing is done. Exiting..."
        Exit
    }
    if($answer -imatch "yes")
    {
        Write-Host "Changing Setting..."
        $oldVal += $x509ByPass;
        $xml.Configuration.Runtime.AppContextSwitchOverrides.Value = $oldVal -join ";"
        $xml.Save($xmlFilePath);
        Write-Host "Done."
    }
}
else {
    Write-Host "Setting already active, No Need to change anything for the x509 by-pass..."
    Write-Host "Exiting..."
}
# SIG # Begin signature block
# MIIGFgYJKoZIhvcNAQcCoIIGBzCCBgMCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA9BKe5e+8Ga6KC
# kMrYq4n3l2CnbPvvj3hiS6nYaGp5cKCCA2AwggNcMIICRKADAgECAhAiXJCsMViY
# t0/OhWs+Jt88MA0GCSqGSIb3DQEBCwUAMEYxJTAjBgNVBAMMHFBvd2VyU2hlbGwg
# Q29kZSBTaWduaW5nIENlcnQxHTAbBgkqhkiG9w0BCQEWDm1vY2hlbkBmb3NzLmRr
# MB4XDTIzMDMzMDEwNDE0OFoXDTI0MDMzMDExMDE0OFowRjElMCMGA1UEAwwcUG93
# ZXJTaGVsbCBDb2RlIFNpZ25pbmcgQ2VydDEdMBsGCSqGSIb3DQEJARYObW9jaGVu
# QGZvc3MuZGswggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDWheD4Ifx6
# 1RUR4B3VjrMbKsYcxFZo+Rb7yMliM2pTwh7bwClCok8vhBllNSmKnXnQjlINv6tx
# uFU9mm4zhbNmtC7DG/N1G5NB/7KMjQS6PfWRdw9nutYv6d75Dh7k4CwCd0+4hpBQ
# ohFnPj3BDS+8jT1JHossWN8EdBs4OhxhxVGrIk8vhssdSej6MKFvSnRo3xQj1Lpd
# PI1cGVOqxXxR6mfyE9qblMJk1KplGkwf9jPvVk5Z/MjEvDN58OB5aroPzm5Bixmd
# FLVPaL6DmDqWogUkkmXgKNfH7BfZFMqf+ap4k1O0kz8fRZs9qS5SYEvzo1MKHv5E
# wLapx5gr82Y9AgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAdBgNVHQ4EFgQUS8KjhwuWpd90lxM1NaJDHfxh9VowDQYJKoZIhvcN
# AQELBQADggEBANYFlNYVOZs3HI1b0+d/wgbU76hQjrqO6ZpkS3FPG5CA13HjuHrS
# iuljeaM3a5W+no8yilRsFUWAEyUYPngk/IBgOFZ0Nu901rA4kA7kMS7lEQsshUnC
# cfzbbgmoqOjP4AFknte5TPPJN8j/COFTCjw0cMLbMXjRI4VWKM/t7vepLgo8TNrC
# BjQUuzen9/Qsx14KphDjeBdhQvsKxIhVM1wr6BGc7T5aZNekhUeuPwHcTdkQoL41
# nTqwjj253lar55Vlux1TVfcSpRdIvErLwkRuvWp1OnwLQLM4t/0pytux80fArTtG
# Wcn/IKsvx6laFn/34xmmoaGiO+CuSikI+OAxggIMMIICCAIBATBaMEYxJTAjBgNV
# BAMMHFBvd2VyU2hlbGwgQ29kZSBTaWduaW5nIENlcnQxHTAbBgkqhkiG9w0BCQEW
# Dm1vY2hlbkBmb3NzLmRrAhAiXJCsMViYt0/OhWs+Jt88MA0GCWCGSAFlAwQCAQUA
# oIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcN
# AQkEMSIEIAIvKpJXf2mj1DGdLe3zQjZj3KJ0lNhpjdTCxupTLyw7MA0GCSqGSIb3
# DQEBAQUABIIBAKPS4Fa2GH9meaeVHxjqQg084dP3sIGQcApWckul83OS9jjSThrh
# KZGrCQE5S5pxLakpaTlaZnRwM1o8RH9/46aZxYPC4396mTNxuuj0V03LylGcxam0
# UXudz6VjU0CcJGeU2/7vUpJ+RzxKS2BWKBEla0It0BUTrUUpi0qe6J8e8EUmJhd9
# 8zA+GxPOtRTy+FoTH7FywRexBcJRfr3U/YXHAfct+i1Dnw+KUPRi4z+oxsBAnmSg
# 4F63ti6DKQiYSr7HxRUPmdF0VG9MidQecJ2wUp4UZ2YbEhDDkO9hgm6K+IvIEqsL
# xzzKu6V2sTJIdqhoq72gJR3ntrRhNzu+Hqw=
# SIG # End signature block
