<#
.SYNOPSIS
Retrieves install information from a running ESXi image on a VMHost.
.DESCRIPTION
Retrieves install information from a running ESXi image on a VMHost.
Returns an object of HostName, Profile, Created, Vendor, Description, and Vibs.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.ESXi.Info
.EXAMPLE
Retrieve information from one VMHost, returning an object into a variable:
$MyVar = Get-VMHost -Name ESX01 | Get-ESXiInfo
.EXAMPLE
Retrieve information from two VMHosts, returning an object into a variable:
$MyVar = Get-VMHost -Name ESX02 , ESX03 | Get-ESXiInfo
#>
function Get-ESXiInfo
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
                Profile = $resdata.Name.Replace("(Updated)","").Trim()
                Created = $resdata.CreationTime
                Vendor = $resdata.Vendor
                Description = $resdata.Description
                Vibs = $resdata.Vibs
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