<#
.SYNOPSIS
Short description
.DESCRIPTION
Long description
.PARAMETER
soft. Gives the VMX process a chance to shut down cleanly (like kill or kill -SIGTERM)
hard. Stops the VMX process immediately (like kill -9 or kill -SIGKILL)
force. Stops the VMX process when other options do not work.

.PARAMETER
Param Info
.EXAMPLE
Example of how to use this cmdlet
.EXAMPLE
Another example of how to use this cmdlet
.INPUTS
Inputs to this cmdlet (if any)
.OUTPUTS
Output from this cmdlet (if any)
#>
function Stop-VMpid
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'high')]

    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]$VM,

        [Parameter(Mandatory = $true)]
        [ValidateSet("soft", "hard", "force")]$Type
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
                HostName = $v.VMHost.Name
                Result = $resdata
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VIB.Info')
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