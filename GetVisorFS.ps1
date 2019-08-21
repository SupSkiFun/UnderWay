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
        $obj.PSObject.TypeNames.Insert(0,'SupSkiFun.ESXi.VisorFS.Info')
        return $obj
    }
}
<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost. See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.ESXi.VisorFS.Info
.EXAMPLE
Returns an       object of one VMHost:
Get-VMHost -Name ESX01
.EXAMPLE
Need some detaillll ?
Get-VMHost Name ESX01
.EXAMPLE
Returns an       object of two VMHosts,
Get-VMHost -Name ESX02 , ESX03
.EXAMPLE
#>
Function Get-ESXiVisorFS
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