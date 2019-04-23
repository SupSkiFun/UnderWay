Function Get-PereniallyReserved
{
    [CmdletBinding()]
    [Alias("getpr")]
    param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost
    )

    Process
    {
        Function MakeObj
		{
			param($diskdata , $hostdata)

			$loopobj = [pscustomobject]@{
				HostName = $hostdata
				Device = $diskdata.Device
				IsPerenniallyReserved =	$diskdata.IsPerenniallyReserved
			}
			$loopobj
			$loopobj.PSObject.TypeNames.Insert(0,'SupSkiFun.RDMinfo')
        }

        foreach ($vmh in $vmhost)
		{
            $x2 = Get-EsxCli -VMHost $vmh -V2
            $vd = (Get-Datastore -VMHost $vmh |
                Where-Object -Property Type -Match VMFS).ExtensionData.Info.Vmfs.Extent.Diskname
            $dl = $x2.storage.core.device.list.Invoke()
            # Remove DataStore LUNs, local MicroSd Card, Local in General, Non-Shared from the list.
            $dl = $dl |
                Where-Object{
                    $_.Device -notin $vd -and $_.Device -notmatch "^mpx" -and $_.DisplayName -notmatch "Local" -and $_.IsSharedClusterwide -eq "true"
                }
            foreach ($d in $dl)
            {
                MakeObj -diskdata $d -hostdata $vmh.Name
            }
        }
    }
}