<#
.SYNOPSIS
Retrieves HPe 650FLB Firmware and VIBs from VMHost(s).
.DESCRIPTION
Queries a VmHost for the firmware and drivers (elxnet , brcmfcoe) of a 650FLB Adapter.
Returns an object of HostName, FirmwareVersion, NicName, NicDescription, NicDriverName, NicDriverVersion,
NicDriverDescription, NicDriverID, HbaDriverName, HbaDriverVersion, HbaDriverDescription, and HbaID from VMHost(s).
Specific to HPe and 650FLB.  Will not query other Hardware Brands or NICs.  If you get an error read it.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost.  See Examples.
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.Info.650FLB
.EXAMPLE
Retrieve info from two VMHosts, storing the results into a variable:
$MyVar = Get-VMHost -Name ESX01 , ESX02 | Get-Info650
.EXAMPLE
Retrieve info from all VMHosts in a cluster, storing the results into a variable:
$MyVar = Get-VMHost -Location Cluster07 | Get-Info650
.EXAMPLE
Retrieve info from all connected VMHosts, storing the results into a variable:
$MyVar = Get-VMHost -Name * | Get-Info650
#>
function Get-Info650
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMHost
	)

    begin
    {
        $vend = "HP"                            # Used to only query HP/HPe systems.
        $flex = "650FLB"                        # Used to query only 650FLB NICs
        $vib1 = @{"vibname" = "elxnet"}         # Vib to Query
        $vib2 = @{"vibname" = "brcmfcoe"}       # Vib to Query
    }

    process
    {
        Function JuicyO
        {
            param ($dfirm, $dnic, $dv1, $dv2)

            $lo = [pscustomobject]@{
                    HostName = $vmh.Name
                    FirmwareVersion = $dfirm
                    NicName = $dnic.Name
                    NicDescription = $dnic.Description
                    NicDriverName = $dv1.Name
                    NicDriverVersion = $dv1.Version
                    NicDriverDescription = $dv1.Description
                    NicDriverID = $dv1.ID
                    HbaDriverName = $dv2.Name
                    HbaDriverVersion = $dv2.Version
                    HbaDriverDescription = $dv2.Description
                    HbaDriverID = $dv2.ID
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Info.650FLB')
            $lo
        }

        foreach ($vmh in $VMHost)
        {
            $c2, $f1, $h1, $n1, $nic0, $v1, $v2 = $null
            $c2 = Get-EsxCli -V2 -VMHost $vmh
            $h1 = $c2.hardware.platform.get.Invoke().VendorName
            $n1 = $c2.network.nic.list.invoke() |
                Select-Object -First 1

            if ($h1 -inotmatch $vend)
            {
                $f1 = "Not Processed.  VendorName is $h1.  VendorName must match $vend."
                JuicyO -dfirm $f1  -dnic $n1
            }

            elseif ($n1.Description -inotmatch $flex)
            {
                $f1 = "Not Processed.  NicDescription does not match $flex."
                JuicyO -dfirm $f1  -dnic $n1
            }

            else
            {
                $nic0 = @{"nicname" = $n1.Name}
                $f1 = $c2.network.nic.get.Invoke($nic0).DriverInfo.FirmwareVersion
                $v1 = $c2.software.vib.get.Invoke($vib1)
                $v2 = $c2.software.vib.get.Invoke($vib2)
                JuicyO -dfirm $f1 -dnic $n1 -dv1 $v1  -dv2 $v2
            }
        }
    }
}