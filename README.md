# PowerShim 

## Invoke Windows PowerShell from PowerShell Core

There are a lot of modules that do not yet support PowerShell Core. To work around this, you can use PowerShim to execute Windows PowerShell cmdlets and return the results to PowerShell Core. 

Thie module executes code in an out-of-proc Windows PowerShell instance and uses PowerShell Remoting to communicate with it from PowerShell Core. This uses the same protocol as Enter-PSHostProcess.

This isn't perfect. Some script blocks won't work but should allow you to call cmdlets you wouldn't normally be able to call in PowerShell Core.

Cmdlet return values are serialized over PowerShell remoting so you will have objects returned by Invoke-Shim.

## Give it a shot

![](./images/powershim.gif)

```
PS> Import-Module PowerShim
PS> Get-SmbShare
PS> Invoke-Shim {
    Get-SmbShare
}
```

## Why? 

You can also achieve this by just calling PowerShell.

```
powershell -NoProfile -Output XML Get-SmbShare | Out-Default
```

The main reason is likely performance. Assume you run the following test. 

```
Measure-Command {
    1..100 | % {
        Get-SmbShare 
    }    
}

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
```

The result would be: 

```

# Get-SmbShare in Windows PowerShell

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 1
Milliseconds      : 402
Ticks             : 14026910
TotalDays         : 1.6234849537037E-05
TotalHours        : 0.000389636388888889
TotalMinutes      : 0.0233781833333333
TotalSeconds      : 1.402691
TotalMilliseconds : 1402.691

# Get-SmbShare using Invoke-Shim

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 8
Milliseconds      : 260
Ticks             : 82605931
TotalDays         : 9.56087164351852E-05
TotalHours        : 0.00229460919444444
TotalMinutes      : 0.137676551666667
TotalSeconds      : 8.2605931
TotalMilliseconds : 8260.5931

# Get-SmbShare using PowerShell.exe

Days              : 0
Hours             : 0
Minutes           : 2
Seconds           : 17
Milliseconds      : 305
Ticks             : 1373050396
TotalDays         : 0.00158917869907407
TotalHours        : 0.0381402887777778
TotalMinutes      : 2.28841732666667
TotalSeconds      : 137.3050396
TotalMilliseconds : 137305.0396
```


## An idea for the future

Import a Windows PowerShell module into PowerShell Core and generate function wrappers around Invoke-Shim to call into Windows PowerShell. 

```
Import-WindowsPowerShellModule Hyper-V 

$Vms = Get-VM 
```

The above would generate all the functions in the Hyper-V module like: 

```
function Get-VM {
    param(...)

    Invoke-Shim {
        Get-VM $args...
    } -ArgumentList @(...)
}
```


