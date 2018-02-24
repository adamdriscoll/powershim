Import-Module (Join-Path $PSScriptRoot 'powershim.psm1') -Force

Get-SmbShare 

Invoke-Shim {
    Get-SmbShare 
}

Get-VM 

Invoke-Shim {
    Get-VM
}