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
$MyVar = Get-VMHost -Name ESX02 | Install-VIB -URL $u
.EXAMPLE
Update two VIBs on two VMHosts, returning an object into a variable:
$uu = 'https://www.example.com/VMware_bootbank_vsanhealth_6.5.0-2.57.9183449.vib' , 'https://www.example.com/VMware_bootbank_esx-base_6.7.0-0.20.9484548'
$MyVar = Get-VMHost -Name ESX03 , ESX04 | Install-VIB -URL $uu
#>
function Update-VIB
{
    [CmdletBinding(SupportsShouldProcess=$true,
    ConfirmImpact='high')]

    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]$VMHost,

        [Parameter(Mandatory=$true)]
        [string[]]$URL
    )

    Process
    {
        foreach ($vmh in $VMHost)
        {
            $cible = @{viburl = $URL}
            if($PSCmdlet.ShouldProcess("$vmh updating $URL"))
            {
                $xcli = get-esxcli -v2 -VMHost $vmh
                $res = $xcli.software.vib.update.invoke($cible)
                $lo = [PSCustomObject]@{
                  HostName = $vmh
                  Message = $res.Message
                  RebootRequired = $res.RebootRequired
                  VIBsInstalled = $res.VIBsInstalled
                  VIBsRemoved = $res.VIBsRemoved
                  VIBsSkipped = $res.VIBsSkipped
              }
              $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VIBinfo')
              Write-Output $lo
            }
        }
    }
}