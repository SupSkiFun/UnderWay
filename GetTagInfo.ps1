<#
.SYNOPSIS
Retrieves assigned tag information for VM or VMHost
.DESCRIPTION
Retrieves assigned tag information for VM or VMHost.
.PARAMETER VM
VMWare PowerCLI VM Object from Get-VM
VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
.PARAMETER VMHost
VMWare PowerCLI VMHost Object from Get-VMHost
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.EXAMPLE
Example of how to use this cmdlet
.EXAMPLE
Another example of how to use this cmdlet
.INPUTS
VMWare PowerCLI VM or VMHost Object from Get-VM or Get-VMHost:
VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.Tag.Assignment.Info
#>
function Get-Started
{
    [CmdletBinding()]
    [Alias()]

    param
    (
        [Parameter(ParameterSetName = "VM" , ValueFromPipeline = $true)]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]$VM,

        [Parameter(ParameterSetName = "VMHost" , ValueFromPipeline = $true)]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost
	)

    Begin
    {
        $nd = @{Tag = "No Tag Assignment Found"}
    }
    
    Process
    {
        Function MakeObj
        {
            param($vdata,$tdata=$nd)

            $lo = [PSCustomObject]@{
                Entity = $vdata.Name
                Tag = $tdata.Tag
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
    }

}