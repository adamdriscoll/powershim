function New-OutOfProcRunspace {
    param($ProcessId)

    $ci = New-Object -TypeName System.Management.Automation.Runspaces.NamedPipeConnectionInfo -ArgumentList @($ProcessId)
    $tt = [System.Management.Automation.Runspaces.TypeTable]::LoadDefaultTypeFiles()

    $Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($ci, $Host, $tt)

    $Runspace.Open()
    
    $PowerShell = $null
    try {
        $PowerShell = [System.Management.Automation.PowerShell]::Create()
        $PowerShell.Runspace = $Runspace
        $PowerShell.AddScript("`$Env:PSModulePath = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').GetValue('PSModulePath')") | Out-Null

        $PowerShell.Invoke()
    }
    finally {
        $PowerShell.Dispose()
    }

    $Runspace
}

function Invoke-Shim {
    param($ScriptBlock, $ArgumentList)

    $PowerShell = $null
    try {
        $PowerShell = $ScriptBlock.GetPowerShell()
        $PowerShell.Runspace = $Runspace
        $PowerShell.Invoke()
    }
    finally {
        $PowerShell.Dispose()
    }
}

$Process = Start-Process PowerShell -ArgumentList @("-NoExit") -PassThru -WindowStyle Hidden
$Runspace = New-OutOfProcRunspace -ProcessId $Process.Id