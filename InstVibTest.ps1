<#
.SYNOPSIS
Installs VIB(s) on VMHost(s).
.DESCRIPTION
Installs VIB(s) on VMHost(s) and returns an object of HostName, Message, RebootRequired, VIBSInstalled, VIBSRemoved, and VIBSSkipped.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.PARAMETER URL
URL(s) for the VIB(s).  https://www.example.com/VMware_bootbank_vsanhealth_6.5.0-2.57.9183449.vib , https://www.example.com/NetAppNasPlugin.v23.vib
.PARAMETER Parallel
If selected, will run the installations in parallel via a PowerShell WorkFlow.  If not selected, hosts will be processed serially.
Recommended when updating against many hosts (5 or more) and/or if the update runs for several minutes or longer.
For swift updates on a few hosts, parallel *could* actually take longer.  Test / verify against the number of hosts and the update type.
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.VIBinfo
.EXAMPLE
Install one VIB to one VMHost, returning an object into a variable:
$u = 'https://www.example.com/VMware_bootbank_vsanhealth_6.5.0-2.57.9183449.vib'
$MyVar = Get-VMHost -Name ESX02 | Install-VIB -URL $u
.EXAMPLE
Install two VIBs to two VMHosts, returning an object into a variable:
$uu = 'https://www.example.com/VMware_bootbank_vsanhealth_6.5.0-2.57.9183449.vib' , 'https://www.example.com/NetAppNasPlugin.v23.vib'
$MyVar = Get-VMHost -Name ESX03 , ESX04 | Install-VIB -URL $uu
.EXAMPLE
Install four VIBs to twenty-five VMHosts in parallel, returning an object into a variable:
$vv = 'https://www.example.com/Patch01.vib','https://www.example.com/Patch02.vib','https://www.example.com/Patch04.vib','https://www.example.com/Patch04.vib'
$MyVar = Get-VMHost -Name ESX[16-40] | Install-VIB -URL $vv -Parallel
#>
function Install-VIBTest
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
                    $resp = $xcli.software.vib.install.invoke($cible)
                    MakeObj -vhdata $vmh.Name -resdata $resp
                }
            }
        }

        elseif($parallel)
        {
            if($PSCmdlet.ShouldProcess("$vmhost installing $URL"))
            {
                Import-Module PSWorkflow
                workflow InstVibPar
                {
                    param (
                        [string]$vcenter,
                        [string[]]$names,
                        [string[]]$uri,
                        [string]$session
                     )

                    foreach -parallel($name in $names)
                     {
                        InlineScript
                        {
                            $cible = @{viburl = $Using:uri}
                            Connect-VIServer -Server $Using:vcenter -Session $Using:session |
                                Out-Null
                            $xcli = Get-EsxCli -VMHost $Using:name -V2
                            $resp = $xcli.software.vib.install.invoke($Using:cible)
                            $resObj = [PSCustomObject]@{
                                HostName = $Using:name
                                Response = $resp
                             }
                            $resObj
                        }
                    }
                }
                $ir = InstVibPar -names $vmhost.name -vcenter $global:DefaultVIServer.Name -session $global:DefaultVIServer.SessionSecret -uri $url
                #MakeObj -vhdata $ir.HostName -resdata $ir.Response
                foreach ($i in $ir)
                {
                    MakeObj -vhdata $i.HostName -resdata $i.Response
                }
            }
        }
    }
}