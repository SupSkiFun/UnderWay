<# 
.SYNOPSIS 
Enables or Disables Alarms from VMHosts and Clusters 
.DESCRIPTION 
Enables or Disables Alarms from VMHosts and Clusters. 
Requires VMHosts and / or Cluster objects to be piped in or specified as a parameter. 
.PARAMETER VMHost 
Output from VMWare PowerCLI Get-VMHost 
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost] 
.PARAMETER Cluster 
Output from VMWare PowerCLI Get-Cluster 
[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster] 
.PARAMETER State 
Set for desired state of alarm; either Enabled or Disabled 
.INPUTS 
VMWare PowerCLI VMHost and / or Cluster Object from Get-VMHost and / or Get-Cluster: 
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost] 
[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster] 
.EXAMPLE 
Enable alarms for one VMHost: 
Get-VMHost -Name ESX01 | Set-VSphereAlarmConfig -State Enabled 
.EXAMPLE 
Disable alarms for one Cluster: 
Get-Cluster -Name CLUS01 | Set-VSphereAlarmConfig -State Disabled 
.EXAMPLE 
Enable alarms for multiple VMHosts bypassing confirmation prompt: 
Get-VMHost -Name ESX4* | Set-VSphereAlarmConfig -State Enabled -Confirm:$false 
.EXAMPLE 
Disable alarms for all VMHosts and Clusters in the connected Virtual Center: 
$host = Get-VMHost -Name * 
$clus = Get-Cluster -Name * 
Set-VSphereAlarmConfig -VMHost $host -Cluster $clus    -State Disabled 
.LINK
Get-VSphereAlarmConfig
#>
function Set-VSphereAlarmConfigNew
{
    [CmdletBinding(SupportsShouldProcess=$true,
        ConfirmImpact='medium')]
    param
    (
        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost,

        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]$Cluster,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Enabled" , "Disabled")]
        [string]$State
    )

    Begin
    {
        $errmsg = "VMHost or Cluster Object Required. Try: Help Set-VSphereAlarmConfig -full"
    }

    Process
    {
        If(!($vmhost -or $cluster))
        {
            Write-Output $errmsg
            break
        }
        Else
        {
            $alarmgr = Get-View AlarmManager
        }

        If($vmhost)
        {
            foreach ($vmh in $vmhost)
            {
                if($PSCmdlet.ShouldProcess("$vmh to $($state)"))
                {
                    if($state -ieq "Enabled")
                    {
                        $alarmgr.EnableAlarmActions($vmh.Extensiondata.MoRef,$true)
                    }
                    elseif($state -ieq "Disabled")
                    {
                        $alarmgr.EnableAlarmActions($vmh.Extensiondata.MoRef,$false)
                    }
                }
            }
        }

        If($cluster)
        {
            foreach ($clu in $cluster)
            {
                if($PSCmdlet.ShouldProcess("$clu to $($state)"))
                {
                    if($state -ieq "Enabled")
                    {
                        $alarmgr.EnableAlarmActions($clu.Extensiondata.MoRef,$true)
                    }
                    elseif($state -ieq "Disabled")
                    {
                        $alarmgr.EnableAlarmActions($clu.Extensiondata.MoRef,$false)
                    }
                }
            }
        }
    }
}
