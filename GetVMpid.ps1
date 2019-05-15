<#
.SYNOPSIS
Short description
.DESCRIPTION
Long description
.PARAMETER
Param Info
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
                HostName = $v.VMHost.Name
                PowerState = $v.PowerState
                DisplayName = $resdata.DisplayName
                WorldID = $resdata.WorldID
                VMXCartelID = $resdata.VMXCartelID
                ConfigFile = $resdata.ConfigFile
                UUID = $resdata.UUID
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VIB.Info')
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