<# 
.SYNOPSIS 
Sets PereniallyReserved value of RDMs from specified VMHost. 
.DESCRIPTION 
Sets PereniallyReserved value of RDMs from specified VMHost to either true or false. Alias setpr. 
Returns nothing. Use Get-PereniallyReserved to query values. 
.PARAMETER VMHost 
VMWare PowerCLI VMHost Object from Get-VMHost 
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost 
.PARAMETER State 
Value of PereniallyReserved to set. Either True or False 
.INPUTS 
VMWare PowerCLI VMHost Object from Get-VMHost: 
VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost 
.EXAMPLE 
Set all RDMs PereniallyReserved value to False for one VMHost: 
Get-VMHost -Name ESXi17 | Set-PereniallyReserved -State False 
.EXAMPLE 
Set all RDMs PereniallyReserved value to True for all VMHosts in a Cluster using the Set-PereniallyReserved alias: 
Get-VMHost -Name * -Location Cluster12 | setpr -State True 
.LINK 
Get-PereniallyReserved 
#>

function Set-PereniallyReservedNew      # remove the trailing NEW
{
    [CmdletBinding(SupportsShouldProcess = $true , ConfirmImpact = 'high')]
    [Alias("setpr")]
    param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost,

        [Parameter(Mandatory = $true)]
        # [ValidateSet('true' , 'false' , IgnoreCase = $false)]
        [ValidateSet('True' , 'False')]
        [string] $State
    )

    Process
    {
        foreach ($vmh in $vmhost)
        {
            if ($pscmdlet.ShouldProcess("$vmh all RDMs to $state"))
            {
                $x2 = Get-EsxCli -VMHost $vmh -V2
                $vd = (Get-Datastore -VMHost $vmh |
                    Where-Object -Property Type -Match VMFS).ExtensionData.Info.Vmfs.Extent.Diskname
                $dl = $x2.storage.core.device.list.Invoke()
                # Remove DataStore LUNs, local MicroSd Card, Local Named, Non-Shared from the list.
                $dl = $dl |
                    Where-Object {
                        $_.Device -notin $vd -and $_.Device -notmatch "^mpx" -and $_.DisplayName -notmatch "Local" -and $_.IsSharedClusterwide -eq "true"
                    }
                foreach ($d in $dl)
                {
                    $z2 = $x2.storage.core.device.setconfig.CreateArgs()
                    $z2.device = $d.device
                    $z2.perenniallyreserved = $state.ToLower()
                    [void] $x2.storage.core.device.setconfig.Invoke($z2)
                }
            }
        }
    }
}