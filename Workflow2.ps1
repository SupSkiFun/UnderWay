$c = (get-vmhost *).Name

workflow Test-Vib 
{
    param 
    (
        [string]$vcenter,
        [string[]]$names,
        [string]$session
    )

    foreach -parallel($name in $names)
    {
        InlineScript
        {
            Write-Host " Starting $using:Name"
            Connect-VIServer -Server $Using:vcenter -Session $Using:session | Out-Null
            $x = Get-Esxcli -VMHost $Using:name -V2
            $y = $x.system.version.get.Invoke()

            $lo = [PSCustomObject]@{
                HostName = $x.system.hostname.get.invoke().HostName
                Build = $y.Build
                Version = $y.version
            }
            # return $lo
            $lo
        }
    }
}


Function abc {
     $r = Test-Vib -names $c -vcenter $global:DefaultVIServer.Name -session $global:DefaultVIServer.SessionSecret
     foreach ($p in $r) {
     $lobj = [pscustomobject]@{
                     HostName = $p.hostname
                     Build = $p.Build
                     Version = $p.version
     }
     $lobj
     }
     }

     $s = abc

     $s

     HostName          Build                 Version
     --------          -----                 -------
     yvr-testesx-c86n1 Releasebuild-13004448 6.7.0
     yvr-testesx-c86n2 Releasebuild-13004448 6.7.0

---------------------------------------


     $r


     HostName              : yvr-testesx-c86n1
     Build                 : Releasebuild-13004448
     Version               : 6.7.0
     PSComputerName        : localhost
     PSSourceJobInstanceId : e2d8c753-7b97-44bc-8879-c3c925e4f16b
     
     HostName              : yvr-testesx-c86n2
     Build                 : Releasebuild-13004448
     Version               : 6.7.0
     PSComputerName        : localhost
     PSSourceJobInstanceId : e2d8c753-7b97-44bc-8879-c3c925e4f16b
