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
#>
function Update-VIBTest
{
    [CmdletBinding(SupportsShouldProcess = $true , ConfirmImpact = 'high')]

    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost,

        [Parameter(Mandatory = $true)]
        [string[]]$URL
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
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VIB.Info')
            $lo
        }

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
}