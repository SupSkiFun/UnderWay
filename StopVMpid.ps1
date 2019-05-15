<#
.SYNOPSIS
Kills VM Process
.DESCRIPTION
Kills VM Process, returning an object of VM, Result, and VMHost.
.PARAMETER VM
Output from VMWare PowerCLI Get-VM.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.PARAMETER Type
Either soft, hard or force.
soft - Gives the VMX process a chance to shut down cleanly (like kill or kill -SIGTERM)
hard - Stops the VMX process immediately (like kill -9 or kill -SIGKILL)
force - Stops the VMX process when other options do not work.  Last Resort.
.EXAMPLE
Perform a soft kill of one VM, returning the object into a variable:
$myVar = Get-VM -Name SYS01 | Stop-VMpid -Type soft
.EXAMPLE
Perform a hard kill of two VMs, returning the object into a variable:
$myVar = Get-VM -Name SYS02 , SYS03 | Stop-VMpid -Type hard
.INPUTS
VMWare PowerCLI VM from Get-VM:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.OUTPUTS
[pscustomobject] SupSkiFun.VM.PID.Info
.LINK
Get-VMpid
#>
function Stop-VMpid
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'high')]

    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]$VM,

        [Parameter(Mandatory = $true)]
        [ValidateSet("soft", "hard", "force")]
        [string]$Type
    )

    Begin
    {

    }

    Process
    {
        Function MakeObj
        {
            param($vdata,$resdata)

            $lo = [PSCustomObject]@{
                VM = $v.Name
                Result = $resdata
                VMHost = $v.VMHost.Name
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VM.PID.Info')
            $lo
        }

        foreach ($v in $vm)
        {
            if($PSCmdlet.ShouldProcess("$v with kill type $($type)"))
            {
                if ($v.PowerState -eq "PoweredOn")
                {
                    $x2 = Get-EsxCli -V2 -VMHost $v.vmhost.Name
                    $r1 = $x2.vm.process.list.Invoke() |
                        Where-Object -Property DisplayName -eq $v.Name
                    $z2 = $x2.vm.process.kill.CreateArgs()
                    $z2.type = $Type
                    $z2.worldid = $r1.WorldID
                    $r2 = $x2.vm.process.kill.Invoke($z2)
                    MakeObj -vdata $v -resdata $r2
                }

                else
                {
                    $np = "Not Attempted; VM Power state is $($v.PowerState)"
                    MakeObj -vdata $v -resdata $np
                }
            }
        }
    }
}