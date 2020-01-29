<#
.SYNOPSIS
Enables or Disables Alarms from VMs, VMHosts and / or Clusters
.DESCRIPTION
Enables or Disables Alarms from VMs, VMHosts and / or Clusters
Requires VMs, VMHosts and / or Cluster objects to be piped in.
.PARAMETER VM
Output from VMWare PowerCLI Get-VM
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.PARAMETER Cluster
Output from VMWare PowerCLI Get-Cluster
[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]
.PARAMETER State
Set for desired state of alarm; either Enabled or Disabled
.INPUTS
VMWare PowerCLI VM, VMHost and / or Cluster Object from Get-VM, Get-VMHost and / or Get-Cluster:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]
.EXAMPLE
Disable alarms for two VMs:
Get-VM -Name Server01 , Server18 | Set-VSphereAlarmConfig -State Disabled
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
Set-VSphereAlarmConfig -VMHost $host -Cluster $clus -State Disabled
.LINK
Get-VSphereAlarmConfig
#>
function Set-VSphereAlarmConfigNew  # Remove trailing New
{
    [CmdletBinding(SupportsShouldProcess=$true,
        ConfirmImpact='medium')]
    param
    (
        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]] $VM,

        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost,

        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]] $Cluster,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Enabled" , "Disabled")]
        [string] $State
    )

    Begin
    {
        $errmsg = "VM, VMHost, and / or Cluster Object Required. Try: Help Set-VSphereAlarmConfig -full"
    }

    Process
    {
        If ( -not ($vm -or $vmhost -or $cluster))
        {
            Write-Output $errmsg
            break
        }
        Else
        {
            $alarmgr = Get-View AlarmManager
        }

        Function SetState
        {
            param($Item , $State)
            if ($state -eq "Enabled")
            {
                $state = $true
            }
            elseif ($state -eq "Disabled")
            {
                $state = $false
            }
            $alarmgr.EnableAlarmActions($item , $state)
        }

        If ($vm)
        {
            foreach ($v in $vm)
            {
                if($PSCmdlet.ShouldProcess("$v to $($state)"))
                {
                    SetState -Item $v.Extensiondata.MoRef -State $State
                }
            }
        }

        If ($vmhost)
        {
            foreach ($vmh in $vmhost)
            {
                if($PSCmdlet.ShouldProcess("$vmh to $($state)"))
                {
                    SetState -Item $vmh.Extensiondata.MoRef -State $State
                }
            }
        }

        If ($cluster)
        {
            foreach ($clu in $cluster)
            {
                if($PSCmdlet.ShouldProcess("$clu to $($state)"))
                {
                    SetState -Item $clu.Extensiondata.MoRef -State $State
                }

            }
        }
    }
}