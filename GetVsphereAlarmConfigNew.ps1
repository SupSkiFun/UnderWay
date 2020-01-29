using module ./Vclasss.psm1
<# 
.SYNOPSIS 
Returns Alarm Enabled Status from VMHosts and Clusters 
.DESCRIPTION 
Returns an Alarm Enabled Status object of Name, Enabled, and Type for VMs, VMHosts and / or Clusters. 
.PARAMETER VM 
Output from VMWare PowerCLI Get-VM
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine] 
.PARAMETER VMHost 
Output from VMWare PowerCLI Get-VMHost
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost] 
.PARAMETER Cluster 
Output from VMWare PowerCLI Get-Cluster 
[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster] 
.INPUTS 
VMWare PowerCLI VM, VMHost and / or Cluster Object from Get-VM, Get-VMHost and / or Get-Cluster:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine] 
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost] 
[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster] 
.OUTPUTS 
 PSCustomObject SupSkiFun.Alarm.Config
.EXAMPLE 
Return information from several VMs: 
Get-VM -Name QA* | Get-VSphereAlarmConfig 
.EXAMPLE 
Return information from one VMHost: 
Get-VMHost -Name ESX01 | Get-VSphereAlarmConfig 
.EXAMPLE 
Return information from one Cluster using the Get-VsphereAlarmConfig alias: 
Get-Cluster -Name CLUS01 | gvsac 
.EXAMPLE 
Return information from multiple VMHosts, returning the object into a variable: 
$MyVar = Get-VMHost -Name ESX4* | Get-VsphereAlarmConfig 
.EXAMPLE 
Return information from all VMHosts and Clusters in the connected Virtual Center: 
$host = Get-VMHost -Name * 
$clus = Get-Cluster -Name * 
$MyVar = Get-VSphereAlarmConfig -VMHost $host -Cluster $clus
.LINK
Set-VSphereAlarmConfig
#>
function Get-VSphereAlarmConfigNew
{
    [CmdletBinding()]
    [Alias("gvsac")]
    param
    (
        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]] $VM,
    
        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost,

        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]] $Cluster)

    Begin
    {
        $errmsg = "VM, VMHost, and / or Cluster Object Required. Try: Help Get-VSphereAlarmConfig -full"
        If( -not ($vm -or $vmhost -or $cluster))
        {
            Write-Output $errmsg
            break
        }
     }

    Process
    {
        If ($vm)
        {
            foreach ($obj in $vm)
            {
                $lo = [Vclasss]::MakeGVSACObj($obj , "VM")
                $lo
            }
        }
        
        If ($vmhost)
        {
            foreach ($obj in $vmhost)
            {
                $lo = [Vclasss]::MakeGVSACObj($obj , "VMHost")
                $lo
            }
        }

        If ($cluster)
        {
            foreach ($obj in $cluster)
            {
                $lo = [Vclasss]::MakeGVSACObj($obj , "Cluster")
                $lo
            }
        }
    }
}