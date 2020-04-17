Class CliObj
{
    [bool] $HasData
    [pscustomobject] $Info
    [string] $VMHost

    CliObj($VMHost)
    {
        $this.VMHost = $VMHost
        $this.HasData = $false
        $this.Info = $null
    }
    
    [void] GetInfo()
    {
        $x = Get-Esxcli -VMHost $this.VMHost -V2
        $y = $x.system.version.get.Invoke()
        $lo = [PSCustomObject]@{
            #HostName = $this.VMHost
            Build = $y.Build
            Version = $y.version
        }
        $this.HasData = $true
        Start-Sleep -Seconds 15
        $this.Info = $lo
    }
}

# Make  Start Install and  getinfo methods


 
