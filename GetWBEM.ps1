<#
.SYNOPSIS
Retrieves status and settings of the WBEM Process from VMHost(s).
.DESCRIPTION
Returns an object containing WBEM Process settings, status, and HostName.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost. See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.WBEM.Info
.EXAMPLE
Retrieve WBEM Process information from two VMHosts, storing the object in a variable:
$MyVar = Get-VMHost -Name ESX01 , ESX02 | Get-WBEMState
.EXAMPLE
Retrieve WBEM Process information from all VMHosts in a cluster, storing the object in a variable:
$MyVar = Get-VMHost -Location Cluster15 | Get-WBEMState
.LINK
Set-WBEMState
#>

Function Get-WBEMState
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost
    )

    Process
    {
        ForEach ($vmh in $VMHost)
        {
            $x2 = Get-EsxCli -V2 -VMHost $vmh
            $v2 = $x2.system.wbem.get.Invoke()
            $v2 |
                Add-Member -Type NoteProperty -Name HostName -Value $vmh.name
            $v2.PSObject.TypeNames.Insert(0,'SupSkiFun.WBEM.Info')
            $v2
        }
    }
}