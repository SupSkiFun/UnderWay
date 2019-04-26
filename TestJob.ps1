$vv = get-vmhost *

foreach ($v in $vv)
{
    Start-Job -ScriptBlock {
        Function DoIt {
            (param $v)
            $x = Get-Esxcli -VMHost $v -V2
            $y = $x.system.version.get.Invoke()
            $lo = [PSCustomObject]@{
                HostName = $v.Name
                Build = $y.Build
                Version = $y.version
            }
            $lo
        }
    }
}
