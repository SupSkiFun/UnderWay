<#
.SYNOPSIS
Rescans and Refreshes HBA(s)
.DESCRIPTION
Rescans and Refreshes HBA(s) for specified VMHosts(s) or Cluster(s). No Output by Default.
Either VMHost(s) or Cluster(s) need to be piped into Invoke-VMHostHBARescan.  See Examples.
.PARAMETER Cluster
Piped output of Get-Cluster from Vmware.PowerCLI
.PARAMETER VMHost
Piped output of Get-VMHost from Vmware.PowerCLI
.INPUTS
Results of Get-VMHost or Get-Cluster from Vmware.PowerCLI
VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl
VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl
.OUTPUTS
None
.EXAMPLE
Rescans and Refreshes the HBAs on one ESX Host:
Get-VMHost -Name ESX12 | Invoke-VMHostHBARescan
.EXAMPLE
Rescans and Refreshes the HBAs on two ESX Hosts, using the Invoke-VMHostHBARescan alias:
Get-VMHost -Name ESX01 , ESX03 | ivhr
.EXAMPLE
Rescans and Refreshes the HBAs on all ESX Hosts in a Cluster:
Get-Cluster -Name PROD01 | Invoke-VMHostHBARescan
.NOTES
Alias ivhr.
Parameter Sets restrict to either Cluster input or VMHost input.  Not both.
#>

function Invoke-VMHostHBARescan
{
    [CmdletBinding()]
    [Alias("ivhr")]
    param
    (
        [Parameter(ParameterSetName="Cluster",
			ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl[]]$Cluster,

		[Parameter(ParameterSetName="VMHost",
			ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMHost
	)

	Process
    {
		if ($Cluster)
		{
			$vhs = Get-VMHost -Location $Cluster
			foreach ($vh in $vhs)
			{
				Get-VMHostStorage -VMHost $vh -RescanAllHba -Refresh |
                    Out-Null
            }
        }

		elseif ($vmhost)
		{
			foreach ($vmh in $vmhost)
			{
				Get-VMHostStorage -VMHost $vmh -RescanAllHba -Refresh |
					Out-Null
    		}
		}
    }
}