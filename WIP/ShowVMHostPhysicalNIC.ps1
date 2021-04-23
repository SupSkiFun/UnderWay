Class FizNic
{
    static [pscustomobject] MakeObj ( [psobject] $n)
    {
        $lo = [pscustomobject]@{
            VMHost = $n.VmHost.Name
            NIC = $n.Name
            Speed = $n.extensiondata.linkspeed.SpeedMB
            Duplex = $n.extensiondata.linkspeed.Duplex
        }
        return $lo
    }
}

Function Show-VMHostPhysicalNIC
{
    [cmdletbinding()]
    Param
    (
        [Parameter(ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost
    )

    Process
    {
        $vmn = $VMHost | 
            Get-VMHostNetworkAdapter -Physical
        foreach ($n in $vmn)
        {
            $lo = [FizNic]::MakeObj($n)
            $lo
        }
    }
}