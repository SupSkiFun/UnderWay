<#
.SYNOPSIS
Retrieves VM process information
.DESCRIPTION
Retrieves VM process information, returning an object of VM, PowerState,
DisplayName, WorldID, VMXCartelID, ConfigFile, UUID, and VMHost.
.PARAMETER VM
Output from VMWare PowerCLI Get-VM.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.EXAMPLE
Retrieve process information of one VM, returning the object into a variable:
$myVar = Get-VM -Name SYS01 | Get-VMpid
.EXAMPLE
Retrieve process information of two VMs, returning the object into a variable:
$myVar = Get-VM -Name SYS02 , SYS03 | Get-VMpid -Type
.INPUTS
VMWare PowerCLI VM from Get-VM:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.OUTPUTS
[pscustomobject] SupSkiFun.VM.PID.Info
.LINK
Stop-VMpid
#>
function Get-VMpid
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]$VM
    )

    Process
    {
        Function MakeObj
        {
            param($vdata,$resdata)

            $lo = [PSCustomObject]@{
                VM = $v.Name
                PowerState = $v.PowerState
                DisplayName = $resdata.DisplayName
                WorldID = $resdata.WorldID
                VMXCartelID = $resdata.VMXCartelID
                ConfigFile = $resdata.ConfigFile
                UUID = $resdata.UUID
                VMHost = $v.VMHost.Name
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VM.PID.Info')
            $lo
        }

        foreach ($v in $vm)
        {
            $x2 = Get-EsxCli -V2 -VMHost $v.vmhost.Name
            $r1 = $x2.vm.process.list.Invoke() |
                Where-Object -Property DisplayName -eq $v.Name
            MakeObj -vdata $v -resdata $r1
        }
    }
}