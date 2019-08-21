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
PSCUSTOMOBJECT SupSkiFun.ESXi.FileSystem.Info
.EXAMPLE 
Returns an object of one VMHost: 
Get-VMHost -Name ESX01 
.EXAMPLE 
Get-VMHost Name ESX01
.EXAMPLE 
Returns an object of two VMHosts, 
Get-VMHost -Name ESX02 , ESX03 
.EXAMPLE
#>
Function Get-ESXiFileSystem
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost
    )

    Begin
    {
        Function MakeObj
        {
            param ($Name, $Info)

            $lo = [pscustomobject]@{
                HostName = $name
                MountPoint = $info.MountPoint
                PercentFree = $info.Free
                Maximum = $info.Maximum
                Used = $info.Used
                RamDiskName = $info.RamdiskName
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.ESXi.FileSystem.Info')
            $lo
        }

    }

    Process
    {
        foreach ($vmh in $vmhost)
        {
            $x2 = Get-EsxCli -V2 -VMHost $vmh
            # Maybe just check them all? - use parameter for specific?
            $z2 = $x2.system.visorfs.ramdisk.list.Invoke()
            #$z2 = $x2.system.visorfs.ramdisk.list.Invoke().where({$_.MountPoint -match "var" -or $_.MountPoint -match "tmp"})
            # $z2 = $x2.system.visorfs.ramdisk.list.Invoke()   Modify to use $fs array
            foreach ($z in $z2)
            {
                MakeObj -Name $vmh.Name -Info $z
            }
        }
    }
}