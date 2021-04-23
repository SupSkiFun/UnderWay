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
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VMHost.Physical.NIC.Info')
        return $lo
    }
}

<#
.SYNOPSIS
Returns VMHost physical NIC properties
.DESCRIPTION
Returns an object of VMHost physical NIC properties
.PARAMETER VMHost
VMWare PowerCLI VMHost Object from Get-VMHost
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.INPUTS
VMHost Object from Get-VMHost:
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.VMHost.Physical.NIC.Info
.EXAMPLE
Query one VMHost for Physical NIC Info:
Get-VMHost -Name ESXi17 | Show-VMHostPhysicalNIC
.EXAMPLE
Query multiple hosts for Physical NIC Info returning the object into a variable:
$MyObj = Get-VMHost -Name ESX0* | Show-VMHostPhysicalNIC
#>

Function Show-VMHostPhysicalNIC
{
    [cmdletbinding()]
    Param
    (
        [Parameter(ValueFromPipeline = $true , Mandatory = $true)]
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