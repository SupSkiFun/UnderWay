<#
.SYNOPSIS
Updates VIB(s) on VMHost(s).
.DESCRIPTION
Updates VIB(s) on VMHost(s) and returns an object of HostName, Message, RebootRequired, VIBSInstalled, VIBSRemoved, and VIBSSkipped.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.PARAMETER URL
URL(s) for the VIB(s).  https://www.example.com/VMware_bootbank_vsanhealth_6.5.0-2.57.9183449.vib , https://www.example.com/VMware_bootbank_esx-base_6.7.0-0.20.9484548
.PARAMETER Parallel
If selected, will run the updates in parallel via a PowerShell WorkFlow.  If not selected, hosts will be processed serially.
Recommended when updating against many hosts (5+) and/or if the update runs for several minutes or longer.
For swift updates on a few hosts, parallel *could* actually take longer.  Test / verify against the number of hosts and the update type.
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.VIBinfo
.EXAMPLE
Update one VIB on one VMHost, returning an object into a variable:
$u = 'https://www.example.com/VMware_bootbank_vsanhealth_6.5.0-2.57.9183449.vib'
$MyVar = Get-VMHost -Name ESX02 | Update-VIB -URL $u
.EXAMPLE
Update two VIBs on two VMHosts, returning an object into a variable:
$uu = 'https://www.example.com/VMware_bootbank_vsanhealth_6.5.0-2.57.9183449.vib' , 'https://www.example.com/VMware_bootbank_esx-base_6.7.0-0.20.9484548'
$MyVar = Get-VMHost -Name ESX03 , ESX04 | Update-VIB -URL $uu
.EXAMPLE
Updates four VIBs on twenty-five VMHosts in parallel, returning an object into a variable:
$vv = 'https://www.example.com/Patch01.vib','https://www.example.com/Patch02.vib','https://www.example.com/Patch04.vib','https://www.example.com/Patch04.vib'
$MyVar = Get-VMHost -Name ESX[16-40] | Update-VIB -URL $vv -Parallel
#>
function Update-VIBTest
{
    [CmdletBinding(SupportsShouldProcess=$true,
    ConfirmImpact='high')]

    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost,

        [Parameter(Mandatory=$true)]
        [string[]]$URL,

        [switch]$Parallel
    )

    Process
    {
        Function MakeObj
        {
            param($vhdata,$resdata)

            $lo = [PSCustomObject]@{
                HostName = $vhdata
                Message = $resdata.Message
                RebootRequired = $resdata.RebootRequired
                VIBsInstalled = $resdata.VIBsInstalled
                VIBsRemoved = $resdata.VIBsRemoved
                VIBsSkipped = $resdata.VIBsSkipped
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VIBinfo')
            $lo
        }

        if(!($parallel))
        {
            $cible = @{viburl = $URL}
            foreach ($vmh in $VMHost)
            {
                if($PSCmdlet.ShouldProcess("$vmh installing $URL"))
                {
                    $xcli = Get-EsxCli -v2 -VMHost $vmh
                    $resp = $xcli.software.vib.update.invoke($cible)
                    MakeObj -vhdata $vmh.Name -resdata $resp
                }
            }
        }

        elseif($parallel)
        {
            if($PSCmdlet.ShouldProcess("$vmhost updating $URL"))
            {
                Import-Module PSWorkflow
                $vcenter = $DefaultVIServer
                workflow UpVibPar
                {
                    param (
                        [string]$vcenter,
                        [string[]]$names,
                        [string[]]$url,
                        [string]$session
                     )

                    foreach -parallel($name in $names)
                     {
                        InlineScript
                        {
                            [string[]]$uu = $Using:url  # Necessary or WorkFlow would fail with -gt 1 vib
                            $cible = @{viburl = $uu}
                            Connect-VIServer -Server $Using:vcenter -Session $Using:session |
                                Out-Null
                            $xcli = Get-EsxCli -VMHost $Using:name -V2
                            $resp = $xcli.software.vib.update.invoke($cible)
                            $resObj = [PSCustomObject]@{
                                HostName = $Using:name
                                Response = $resp
                             }
                            $resObj
                        }
                    }
                }
                $ir = UpVibPar -names $vmhost.Name -vcenter $vcenter.Name -session $vcenter.SessionSecret -url $url
                #MakeObj -vhdata $ir.HostName -resdata $ir.Response
                foreach ($i in $ir)
                {
                    MakeObj -vhdata $i.HostName -resdata $i.Response
                }
            }
        }
    }
}