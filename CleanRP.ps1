<#
.SYNOPSIS
Starts the SRM Cleanup Process.
.DESCRIPTION
Starts the SRM Cleanup Process for specified SRM Recovery Plans.
Does not attempt if submitted plan is not in a NeedsCleanup state.
.PARAMETER RecoveryPlan
SRM Recovery Plan.  VMware.VimAutomation.Srm.Views.SrmRecoveryPlan
.EXAMPLE
Get-SRMRecoveryPlan is from module Meadowcroft.Srm.  However, any object containing an SRMRecoveryPlan will work.
$p = Get-SRMRecoveryPlan -Name XYZ
$p | Start-SRMCleanUp
#>
Function Start-SRMCleanUp
{
    [cmdletbinding(SupportsShouldProcess = $True , ConfirmImpact = "High")]
    Param
    (
        [Parameter (Mandatory = $true , ValueFromPipeline = $true )]
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan
    )

    Begin
    {
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode] $RecoveryMode = [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode]::CleanUpTest
        $ReqState = "NeedsCleanup"
    }

    Process
    {
        foreach ($rp in $RecoveryPlan)
        {
            $rpinfo = $rp.GetInfo()

            if ($pscmdlet.ShouldProcess($rpinfo.Name, $RecoveryMode))
            {
                if ($rpinfo.State -eq $ReqState)
                {
                    $RecoveryPlan.Start($RecoveryMode)
                }

                else
                {
                    $mesg = "Not Sending dismissal for $($rpinfo.Name).  State is $($rpinfo.State).  State should be $ReqState."
                    Write-Output "`n`t`t$mesg`n"
                }
            }
        }
    }
}