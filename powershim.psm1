function New-OutOfProcRunspace {
    $PowerShell = Start-Process PowerShell -ArgumentList @("-NoExit") -PassThru -WindowStyle Hidden

    $ci = New-Object -TypeName System.Management.Automation.Runspaces.NamedPipeConnectionInfo -ArgumentList @($PowerShell.Id)
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

function Import-WindowsPowerShellModule {
    param($Module)

    $Commands = Invoke-Shim {
        Get-Command -Module $args[0]
    } -ArgumentList $Module

    #TODO: Generate functions to stub out cmdlets
}

function Invoke-Shim {
    param($ScriptBlock, $ArgumentList)

    try {
        $PowerShell = $ScriptBlock.GetPowerShell($true, $ArgumentList)
        $PowerShell.Runspace = $PowerShellv3Runspace
        $PowerShell.Invoke()
    }
    catch {}
}

$PowerShellv3Runspace = New-OutOfProcRunspace