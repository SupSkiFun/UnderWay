<#
.SYNOPSIS
Queries for VMs with a USB Controller Installed
.DESCRIPTION
Returns an object of VM, Notes, VMHost and USB from VMs with a USB Controller Installed
.PARAMETER VM
Output from VMWare PowerCLI Get-VM.  See Examples.
[VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl]
.EXAMPLE
Query one VM for USB Controller:
Get-VM -Name VM01 | Show-USBController
.EXAMPLE
Query all VMs for USB Controller, returning object into a variable:
$myVar = Get-VM -Name * | Show-USBController
.INPUTS
VMWare PowerCLI VMHost from Get-VM:
[VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl]
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.USB.Info
#>
function Show-USBController
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl[]]$VM
    )

    Process
    {
        foreach ($v in $VM)
        {
            if ($v.ExtensionData.Config.Hardware.Device.deviceinfo.label -imatch "USB")
            {
                $usbd = ($v.ExtensionData.Config.Hardware.Device.deviceinfo |
                    Where-Object -Property label -match "USB").label

                    $lo = [pscustomobject]@{
					VM = $v.Name
					Notes = $v.Notes
					VMHost = $v.VMHost
					USB = $usbd
                }

                $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.USB.Info')
                $lo
            }
        }
    }
}