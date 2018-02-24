Import-Module (Join-Path $PSScriptRoot 'powershim.psm1') -Force

Invoke-Shim -ScriptBlock { 
    $PSVersionTable
 }

 $VMs = Invoke-Shim -ScriptBlock {
    Import-Module "Hyper-V"
    Get-VM
 }

 $VMs
