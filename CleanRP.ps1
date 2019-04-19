<#
.SYNOPSIS
Start a Recovery Plan action like test, recovery, cleanup, etc.

.PARAMETER RecoveryPlan
The recovery plan to start

.PARAMETER RecoveryMode
The recovery mode to invoke on the plan. May be one of "Test", "Cleanup", "Failover", "Migrate", "Reprotect"
#>
Function Start-RPCleaning
{
    [cmdletbinding(SupportsShouldProcess = $True , ConfirmImpact = "High")]
    Param
    (
        [Parameter (Mandatory=$true, ValueFromPipeline=$true, Position=1)][VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan
    )

    Begin
    {
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode] $RecoveryMode = [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode]::CleanUpTest
    }

    Process 
    {
        foreach ($rp in $RecoveryPlan)
        {
            $rpinfo = $rp.GetInfo()
           
            if ($pscmdlet.ShouldProcess($rpinfo.Name, $RecoveryMode)) 
            {
                if ($rpinfo.State -eq "NeedsCleanup")
                {
                    $RecoveryPlan.Start($RecoveryMode)
                    <#
                    Write-Output "Simulating Start"
                    "Name $($rpinfo.Name)"
                    "State $($rpinfo.State)"
                    "Recovery Mode $RecoveryMode"
                    $RecoveryMode
                    #>
                }

                else 
                {
                    Write-Output "Not Starting Cleanup for $($rpinfo.Name).  State is $($rpinfo.State).  State should be NeedsCleanup."
                }
            }
        }
    }
}