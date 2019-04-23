<#
.SYNOPSIS
Show RDMs from specified VMs or VMHosts
.DESCRIPTION
Returns an object of RDMs listing DevfsPath, Device, DisplayName, IsPerenniallyReserved, Size,
Status, VAAIStatus, Vendor, HostName and VM (if applicable) from VMs or VMHosts.  Alias srdm.
.PARAMETER VM
VMWare PowerCLI VM Object from Get-VM
VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
.PARAMETER VMHost
VMWare PowerCLI VMHost Object from Get-VMHost
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.INPUTS
VMWare PowerCLI VM or VMHost Object from Get-VM or Get-VMHost:
VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.RDM.Info
.EXAMPLE
Query one VM for RDMs:
Get-VM -Name Server01 | Show-RDM
.EXAMPLE
Query one VMHost for RDMs:
Get-VMHost -Name ESXi17 | Show-RDM
.EXAMPLE
Query multiple VMs for RDMs, returning object into a variable:
$myVar = Get-VM -Name Server50* | Show-RDM
.EXAMPLE
Query all VMHosts in a cluster using the Show-RDM alias, returning object into a variable:
$myVar = Get-VMHost -Name * -Location Cluster12 | srdm
#>
function Show-RDMTest
{
    [CmdletBinding()]
    [Alias("srdmt")]
    param
    (
        [Parameter(
			ParameterSetName = "VM",
			ValueFromPipeline = $true
		)]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]$VM,

        [Parameter(
			ParameterSetName = "VMHost",
			ValueFromPipeline = $true
		)]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost
	)

    Begin
	{
		# RDM properties to query.
		$rvals = @(
			"DevfsPath"
			"Device"
			"DisplayName"
			"IsPerenniallyReserved"
			"Size"
			"Status"
			"VAAIStatus"
			"Vendor"
		)
	}

	Process
    {
		Function vmrdm
		{
			foreach ($v in $vm)
			{
				$ds = Get-HardDisk -VM $v -DiskType "RawPhysical","RawVirtual"
				$x2 = Get-EsxCli -VMHost $v.VMHost -V2
				$dl = $x2.storage.core.device.list.Invoke()
				foreach ($d in $ds)
				{
					$rdisk = $dl |
						Where-Object -Property Device -Match $d.ScsiCanonicalName |
							Select-Object $rvals
					MakeObj -diskdata $rdisk -hostdata $v.VMHost.Name -vmdata $v.name
				}
			}
		}

		Function vmhrdm
		{
			foreach ($vmh in $vmhost)
			{
				$x2 = Get-EsxCli -VMHost $vmh -V2
				$vd = (Get-Datastore -VMHost $vmh |
					Where-Object -Property Type -Match VMFS).ExtensionData.Info.Vmfs.Extent.Diskname
				$dl = $x2.storage.core.device.list.Invoke()
				# Remove DataStore LUNs and local MicroSd Card from the list.
				$dl = $dl |
					Where-Object {$_.Device -notin $vd -and $_.Device -notmatch "^mpx"}
				foreach ($d in $dl)
				{
					MakeObj -diskdata $d -hostdata $vmh.Name
				}
			}
		}

		Function MakeObj
		{
			param($diskdata , $hostdata , $vmdata = "N/A")

			$loopobj = [pscustomobject]@{
				VM = $vmdata
				HostName = $hostdata
				DevfsPath = $diskdata.DevfsPath
				Device = $diskdata.Device
				DisplayName = $diskdata.DisplayName
				IsPerenniallyReserved =	$diskdata.IsPerenniallyReserved
				SizeGB = [Math]::Round($diskdata.Size /1kb, 2)
				Status = $diskdata.Status
				VAAIStatus = $diskdata.VAAIStatus
				Vendor = $diskdata.Vendor
			}
			$loopobj
			$loopobj.PSObject.TypeNames.Insert(0,'SupSkiFun.RDM.Info')

		}

		if ($vm)
		{
			vmrdm
		}
		elseif ($vmhost)
		{
			vmhrdm
		}
		else
		{
			Write-Output "VM or VMHost must be piped in.  Terminating"
			break
		}
    }
}