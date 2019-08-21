<#
To Do.
1. Better Object Name for Maximum and Used?  Maybe return in KB, rounded?
SizeKB, UsedKB?  Verify Maximum, PercentFree and Used values!!  If Object Names
Change, also change Help.
2. Test Pattern parameter.
3. Change name to Get-VMHostHyperVisorFS ???  Examples and function....
#>

Class VFSclass
{
    static [pscustomobject] MakeVFSObj ( [string] $Name , [PSObject] $Info )
    {
        $obj = [pscustomobject]@{
            HostName = $name
            MountPoint = $info.MountPoint
            PercentFree = $info.Free
            Maximum = $info.Maximum
            Used = $info.Used
            RamDiskName = $info.RamdiskName
        }
        $obj.PSObject.TypeNames.Insert(0,'SupSkiFun.ESXi.HyperVisorFS.Info')
        return $obj
    }
}
<#
.SYNOPSIS
Retrieves file systems of the VMHost HyperVisor.
.DESCRIPTION
By default, retrieves file systems of the VMHost HyperVisor.  If an optional pattern is specified
only file systems matching the pattern are retrieved.  Returns an object of:
HostName, MountPoint, PercentFree, Maximum, Used, and RamDiskName.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost. See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.PARAMETER Pattern
Optional.  If specified only returns mount points matching the pattern.  See Examples.
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.ESXi.HyperVisorFS.Info
.EXAMPLE
Returns an object of all HyperVisor File Systems from one VMHost:
Get-VMHost -Name ESX01 | Get-ESXiHyperVisorFS
.EXAMPLE
Returns an object of HyperVisor File Systems with a mount point matching "tmp" from two VMHosts:
Get-VMHost -Name ESX02, ESX03 | Get-ESXiHyperVisorFS -Pattern tmp
.EXAMPLE
Returns an object of all HyperVisor File Systems from all VMHosts in a cluster, into a variable:
$myVar = Get-VMHost -Location CLUS01 | Get-ESXiHyperVisorFS
.EXAMPLE
#>
Function Get-ESXiHyperVisorFS
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost,

        [string] $Pattern
    )

    Process
    {
        foreach ($vmh in $vmhost)
        {
            $x2 = Get-EsxCli -V2 -VMHost $vmh

            if (-not($pattern))
            {
                $z2 = $x2.system.visorfs.ramdisk.list.Invoke()
            }
            else
            {
                $z2 = $x2.system.visorfs.ramdisk.list.Invoke().where({$_.MountPoint -match $Pattern})
            }

            foreach ($z in $z2)
            {
                $lo = [VFSclass]::MakeVFSObj($vmh.Name , $z)
                $lo
            }
        }
    }
}