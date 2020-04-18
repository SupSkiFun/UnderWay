using module .\dClass.psm1

<#
    Change all instances of dClass to sClass
#>

<#
.SYNOPSIS
Shows Recovery Plan Detailed Information
.DESCRIPTION
Shows Recovery Plan Detailed Information for submitted Recovery Plans including detailed information of
affiliated Protection Groups.  If no Recovery Plans or parameters are specified, returns detailed information
for all Recovery Plans.  See Examples.  Can be run on recovery or protected site.
.NOTES
1. $allRP = Show-SRMRecoveryPlanInfo (is equivalent to) $allRP = Show-SRMRecoveryPlanInfo -All.
2.
        NEED INFO HERE

.PARAMETER All
Optional.  If specified returns detailed information for all Recovery Plans.
.PARAMETER RecoveryPlan
Optional.  SRM Recovery Plan Object.  See Examples.
[VMware.VimAutomation.Srm.Views.SrmRecoveryPlan].
.INPUTS
[VMware.VimAutomation.Srm.Views.SrmRecoveryPlan]
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.SRM.Recovery.Plan.Info with embedded PSCUSTOMOBJECT SupSkiFun.SRM.Protection.Group.Info
.EXAMPLE
Return all SRM Recovery Plans into a variable:
$allRP = Show-SRMRecoveryPlanInfo
.EXAMPLE
Return specific SRM Recovery Plan(s) matching a criteria into a variable:
$myRP = Get-SRMRecoveryPlan | Where-Object -Property Name -Match "EX07*"
$MyVar = $myRP | Show-SRMRecoveryPlanInfo
.EXAMPLE

        NEED INFO HERE

.EXAMPLE

        NEED INFO HERE


.EXAMPLE

        NEED INFO HERE

.LINK
Get-SRMRecoveryPlan
Show-SRMProtectionGroupInfo
#>





<#
    Update all above Help
#>

Function Show-SRMRecoveryPlanInfo
{
    [CmdletBinding(DefaultParameterSetName = "All")]
    param (
        [Parameter(ParameterSetName = "All")]
        [switch] $All,

        [Parameter(ParameterSetName = "RP", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan
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
            $rps = $RecoveryPlan
        }
        else
        {
            $rps = $srmED.Protection.ListProtectionGroups()
        }

        foreach ($rp in $rps)
        {
            $lo = [dClass]::MakeRPInfoObj($rp)
            $lo
        }
    }
}
