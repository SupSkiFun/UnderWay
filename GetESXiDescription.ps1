<#
.SYNOPSIS
Retrieves the description of an ESXi image installed on a VMHost.
.DESCRIPTION
Retrieves the description of an ESXi image installed on a VMHost.
Returns an object of HostName, Profile, and Description.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.ESXi.Info
.EXAMPLE
Retrieve an image description from one VMHost, returning an object into a variable:
$MyVar = Get-VMHost -Name ESX01 | Get-ESXiDescription
.EXAMPLE
Retrieve an image description from two VMHosts, returning an object into a variable:
$MyVar = Get-VMHost -Name ESX02 , ESX03 | Get-ESXiDescription
#>
function Get-ESXiDescription
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost
    )

    Process
    {
        Function MakeObj
        {
            param($vhdata,$resdata)

            $lo = [PSCustomObject]@{
                HostName = $vhdata
                Profile = $resdata.Profile
                Description = $resdata.Description
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.ESXi.Info')
            $lo
        }

        foreach ($vmh in $VMHost)
        {
                $xcli = Get-EsxCli -V2 -VMHost $vmh
                $resp = $xcli.software.profile.get.Invoke()
                MakeObj -vhdata $vmh.Name -resdata $resp
        }
    }
}