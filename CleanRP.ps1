<#
.SYNOPSIS
Start a Recovery Plan action like test, recovery, cleanup, etc.

.PARAMETER RecoveryPlan
The recovery plan to start

.PARAMETER RecoveryMode
The recovery mode to invoke on the plan. May be one of "Test", "Cleanup", "Failover", "Migrate", "Reprotect"
#>
Function Start-RecoveryPlan {
    [cmdletbinding(SupportsShouldProcess=$True, ConfirmImpact="High")]
    Param(
        [Parameter (Mandatory=$true, ValueFromPipeline=$true, Position=1)][VMware.VimAutomation.Srm.Views.SrmRecoveryPlan] $RecoveryPlan,
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode] $RecoveryMode = [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode]::Test,
        [bool] $SyncData = $True
    )

    # Validate with informative error messages
    $rpinfo = $RecoveryPlan.GetInfo()

    # Create recovery options
    $rpOpt = New-Object VMware.VimAutomation.Srm.Views.SrmRecoveryOptions
    $rpOpt.SyncData = $SyncData

    # Prompt the user to confirm they want to execute the action
    if ($pscmdlet.ShouldProcess($rpinfo.Name, $RecoveryMode)) {
        if ($rpinfo.State -eq 'Protecting') {
            throw "This recovery plan action needs to be initiated from the other SRM instance"
        }

        $RecoveryPlan.Start($RecoveryMode, $rpOpt)
    }
}