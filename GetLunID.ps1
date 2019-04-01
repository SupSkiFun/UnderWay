# MakeHash is a helper which makes hash tables for VM or ESXi or DStore
Function MakeHash([string]$quoi)
{
        switch ($quoi)
        {
                'vm'
                {
                        $vmq = Get-VM -Name *
                        $vmhash = @{}
                        $script:vmhash = foreach ($v in $vmq)
                        {
                            @{
                                    $v.id = $v.name
                            }
                        }
                }

                'ex'
                {
                        $exq = Get-VMHost -Name *
                        $exhash = @{}
                        $script:exhash = foreach ($e in $exq)
                        {
                            @{
                                    $e.id = $e.name
                            }
                        }
                }

                'ds'
                {
                        $dsq = Get-Datastore -Name *
                        $dshash = @{}
                        $script:dshash = foreach ($d in $dsq)
                        {
                            @{
                                    $d.id = $d.name
                            }
                        }
                }
        }
}
<#
.SYNOPSIS
Obtains LUN of DataStore(s).
.DESCRIPTION
Returns an object of Name, LUN, WorkingPaths, PathSelectionPolicy, Device and DeviceDisplayName of Datastore(s).
Requires Pipleline input from VmWare Get-Datastore.
.PARAMETER Name
Requires Pipleline input from VmWare PowerCLI Get-Datastore.  Only VMFS DataStores accepted.
VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.VmfsDatastore
.INPUTS
VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.VmfsDatastore
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.LUNinfo
.EXAMPLE
Retrieve information from one VMFS DataStore:
Get-DataStore -Name Dstore01 | Get-DataStoreLunID
.EXAMPLE
Return an object of multiple VMFS DataStores into a variable, using the Get-DataStoreLunID alias:
$MyVar = Get-Datastore -Name Dstore* | Where-Object -Property Type -Match "VMFS" | gdli
.EXAMPLE
Query all VMFS DataStores of an ESX host, returning the object into a variable:
$MyVar = Get-Datastore -VMHost ESX01 | Where-Object -Property Type -Match "VMFS" | Get-DataStoreLunID
#>
function Get-DataStoreLunIDTest
{
    [CmdletBinding()]
    [Alias("gdlit")]
    param
    (
    [Parameter(ValueFromPipeline=$true, Mandatory = $true)]
	[VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.VmfsDatastore[]]$Name
	)

    Process
    {
		function MakeObj
		{
        param ($lun, $luninfo=$null)

        $loopobj = [pscustomobject]@{
            Name = $n.Name
            Lun = $lun
            WorkingPaths = $luninfo.WorkingPaths
            PathSelectionPolicy = $luninfo.PathSelectionPolicy
            Device = $luninfo.Device
            DeviceDisplayName = $luninfo.DeviceDisplayName
        }
        $loopobj.PSObject.TypeNames.Insert(0,'SupSkiFun.LUNinfo')
        $loopobj
		}

        MakeHash "ex"

		foreach ($n in $name)
		{
            $ds, $e2, $hs, $li, $ld = $null
            $hs = $n.ExtensionData.host
            foreach ($h in $hs)
            {
                $e2 = Get-EsxCli -v2 -VMHost $exhash.$($h.key) -ErrorAction SilentlyContinue
                if ($e2)
                {
                    $ds = $n.ExtensionData.Info.Vmfs.Extent[0].DiskName
                    $li = $e2.storage.nmp.device.list.Invoke((@{'device'=$ds}))

                    if ($li.WorkingPaths.count -eq 1)
                    {
                        $ld = $li.WorkingPaths.ToString().Split(":")[3].Replace("L","")
                    }
                    else
                    {
                        $ld = $li.WorkingPaths[0].ToString().Split(":")[3].Replace("L","")
                    }

                    MakeObj -lun $ld -luninfo $li
                    break
                }

                $ld = "Error Connecting to VMHosts"
                MakeObj -lun $ld -luninfo $li
            }
		}
	}
}