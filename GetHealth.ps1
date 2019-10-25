<#
.SYNOPSIS
Produces an object of VAMI Health
.DESCRIPTION
Produces an object of VAMI Health, including Name, Status, Returns, Full Name of
load, storage, swap, softwarepackages, databasestorage, applmgmt, system, and mem monitors.
Status for softwarepackages (only) are:
Red indicates that security updates are available.
Orange indicates that non-security updates are available.
Green indicates that there are no updates available.
Gray indicates that there was an error retreiving information on software updates.
.OUTPUTS
pscustombobject SupSkiFun.VAMIHealthStatus
.EXAMPLE
Returns an object of VAMI Health into a variable:
$MyObj = Get-VAMIHealth
.EXAMPLE
Returns an object of VAMI Health into a variable, using the Get-VAMIHealth alias:
$MyObj = gvh
#>
function Get-VAMIHealth
{
    [CmdletBinding()]
    [Alias("gvh")]
    param()
    Begin
	{
		$svcs = Get-CisService -Name com.vmware.appliance.health.*
		$ti = (Get-Culture).TextInfo
	}
	Process
    {
		foreach ($svc in $svcs)
		{
 			$r = ($svc.Help.get.Returns).Trim(".",1)
			$loopobj = [pscustomobject]@{
				Name = $svc.name.Split(".")[($svc.name.Split(".").count) -1]
				Status = $svc.get()
				Returns = $ti.ToTitleCase($r)
				FullName = $svc.Name
			}
			$loopobj.PSObject.TypeNames.Insert(0,'SupSkiFun.VAMIHealthStatus')
			$loopobj
		}
	}
}