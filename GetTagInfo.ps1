<#
.SYNOPSIS
Retrieves assigned tag information for VM or VMHost
.DESCRIPTION
Retrieves assigned tag information for VM or VMHost, returning an object of
Entity, Name, Category, and Description.
.PARAMETER VM
VMWare PowerCLI VM Object from Get-VM
VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
.PARAMETER VMHost
VMWare PowerCLI VMHost Object from Get-VMHost
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.EXAMPLE
Retrieve tag information of one VM, returning the object into a variable:
$myVar = Get-VM -Name SYS01 | Get-TagInfo
.EXAMPLE
Retrieve tag information of two VMs, returning the object into a variable:
$myVar = Get-VM -Name SYS02 , SYS03 | Get-TagInfo -Type
.EXAMPLE
Retrieve tag information of one VMHost, returning the object into a variable:
$myVar = Get-VMHost -Name ESX01 | Get-TagInfo
.EXAMPLE
Retrieve tag information of two VMHosts, returning the object into a variable:
$myVar = Get-VMHost -Name ESX02 , ESX03 | Get-TagInfo -Type
.INPUTS
VMWare PowerCLI VM or VMHost Object from Get-VM or Get-VMHost:
VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.Tag.Assignment.Info
#>
function Get-TagInfo
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
        $h1 = @{Name = "No Tag Assignment Found"}
        $nd = @{Tag = $h1}
    }

    Process
    {
        Function MakeObj
        {
            param($vdata,$tdata)

            $lo = [PSCustomObject]@{
                Entity = $vdata.Name
                Name = $tdata.Tag.Name
                Category = $tdata.Tag.Category
                Description = $tdata.Tag.Description
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Tag.Assignment.Info')
            $lo
        }

        Function GetTagInfo($ces)
        {
            foreach ($ce in $ces)
            {
                $il = $ce | Get-TagAssignment
                if($il)
                {
                    foreach ($i in $il)
                    {
                        MakeObj -vdata $ce -tdata $i
                    }
                }

                else
                {
                    MakeObj -vdata $ce -tdata $nd
                }
            }
        }

        if ($vm)
        {
            GetTagInfo($vm)
        }

        elseif ($vmhost)
        {
            GetTagInfo($vmhost)
        }
    }
}