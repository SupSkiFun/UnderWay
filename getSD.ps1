<#
.SYNOPSIS
Returns an Object of SnapShot Data for specified VMs
.DESCRIPTION
Returns an object of VM, SnapName, Description, SizeGB, UserName, Created, and File of a snapshot.
Snapshot input must be piped from Get-SnapShot.  See Examples.
Note:  Time occassionally skews a few seconds between VIevent (log) and Snapshot (actual) info.
Ergo, this advanced function creates an 11 second window to correlate log information with actual information.
Snapshots taken on the same VM within 10 seconds of each other may produce innaccurate results.  Optionally,
the 11 second window can be adjusted from 0 to 61 seconds by using the PreSeconds and PostSeconds parameters.
.PARAMETER Name
Pipe the Snapshot object.  See Examples.
.PARAMETER PreSeconds
Number of seconds to capture VIEvents, before the SnapShot.  Default value is 5.
.PARAMETER PostSeconds
Number of seconds to capture VIEvents, after the SnapShot.  Default value is 5.
.INPUTS
VMWare SnapShot Object from Get-SnapShot
VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.SnapShot.Data
.EXAMPLE
Obtain Snapshot Data from one VM:
Get-SnapShot -VM Guest01 | Get-SnapShotData
.EXAMPLE
Obtain Snapshot Data from multiple VMs, using the Get-SnapShotData alias, placing the object into a variable:
$MyVar = Get-Snapshot -VM *WEB* | gsd
.EXAMPLE
Obtain Snapshot Data from one VM, increasing the VIEvent window to 31 seconds by setting both the PreSeconds and PostSeconds parameters to 15:
Get-SnapShot -VM Guest01 | Get-SnapShotData -PreSeconds 15 -PostSeconds 15
#>
function Get-SnapShotData
{
	[CmdLetBinding()]
	[Alias("gsd")]

	param
	(
		[Parameter(ValueFromPipeline = $true, Mandatory = $true)]
		[VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]$Name,

		[Parameter(Mandatory = $false)]
		[ValidateRange(0,30)]
		[Int]$PreSeconds = 5,

		[Parameter(Mandatory = $false)]
		[ValidateRange(0,30)]
		[Int]$PostSeconds = 5
	)

	Process
	{
		foreach ($snap in $name)
		{
			<#
			Create a 10 second window of VI events because snapshot
			creation time can skew a few seconds from the log entry
			#>
			$presec = $snap.Created.AddSeconds(( - $preseconds))
			$postsec = $snap.Created.AddSeconds(( + $postseconds))
			$files = ((Get-VM -Name $snap.VM).ExtensionData.LayoutEx.File |
				Where-Object {$_.type -match "snapshotData"}).Name
			$evnts = Get-VIEvent -Entity $snap.VM.Name -Start $presec -Finish $postsec
			$entry = $evnts |
				Where-Object {$_.FullFormattedMessage -match $ffm }
			$loopobj = [pscustomobject]@{
				VM = $snap.VM.Name
				SnapName = $snap.Name
				Description = $snap.Description
				SizeGB = [math]::Round($snap.SizeGB, 3)
				UserName = $entry.UserName
				Created = $snap.Created
				File = $files
			}
			$loopobj.PSObject.TypeNames.Insert(0,'SupSkiFun.SnapShot.Data')
			$loopobj
		}
	}
}