Import-Module (Join-Path $PSScriptRoot 'powershim.psm1') -Force

Measure-Command {
    1..100 | % {
        Invoke-Shim {
            Get-SmbShare 
        }
    }    
}

Measure-Command {
    1..100 | % {
        powershell -noprofile -output xml Get-SmbShare | Out-Default 
    }
}