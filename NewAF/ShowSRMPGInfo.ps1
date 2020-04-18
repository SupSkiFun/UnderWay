using module .\dClass.psm1

<#
    Change all instances of dClass to sClass
#>

<#
.SYNOPSIS
Shows Protection Group Detailed Information
.DESCRIPTION
Shows Protection Group Detailed Information for submitted Protection Groups.  If no Protection Groups
or parameters are specified, returns detailed information for all Protection Groups.  See Examples.
Can be run on recovery or protected site.
.NOTES
1. $allPG = Show-SRMProtectionGroupInfo (is equivalent to) $allPG = Show-SRMProtectionGroupInfo -All
        NEED INFO HERE

.PARAMETER All
Optional.  If specified returns detailed information for all Protection Groups.
.PARAMETER ProtectionGroup
Optional.  Protection Group Object.  See Examples.
[VMware.VimAutomation.Srm.Views.SrmProtectionGroup]
.INPUTS
[VMware.VimAutomation.Srm.Views.SrmProtectionGroup]
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.SRM.Protection.Group.Info
.EXAMPLE
Return all SRM Protection Groups into a variable:
$allPG = Show-SRMProtectionGroupInfo
.EXAMPLE
Return specific SRM Protection Group(s) matching a criteria into a variable:
$myPG = Get-SRMProtectionGroup | Where-Object -Property Name -Match "EX07*"
$MyVar = $myPG | Show-SRMProtectionGroupInfo
.EXAMPLE

        NEED INFO HERE

.EXAMPLE

        NEED INFO HERE


.EXAMPLE

        NEED INFO HERE

.LINK
Get-SRMProtectionGroup
Show-SRMRecoveryPlanInfo
#>





<#
    Update all above Help
#>

Function Show-SRMProtectionGroupInfo
{
    [CmdletBinding(DefaultParameterSetName = "All")]

    Param
    (
        [Parameter(ParameterSetName = "All")]
        [switch] $All,

        [Parameter(ParameterSetName = "PG", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Srm.Views.SrmProtectionGroup[]] $ProtectionGroup
    )

    Begin
    {
        $srmED =  $DefaultSrmServers.ExtensionData

        if(!$srmED)
        {
            Write-Output "Terminating. Session is not connected to a SRM server."
            break
        }
    }

    Process
    {

        if ($ProtectionGroup)
        {
            $pgs = $ProtectionGroup
        }
        else
        {
            $pgs = $srmED.Protection.ListProtectionGroups()
        }

        foreach ($pg in $pgs)
        {
            $lo = [dClass]::MakePGInfoObj($pg)
            $lo
        }
    }
}