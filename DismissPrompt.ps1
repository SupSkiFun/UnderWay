<#
.SYNOPSIS
Start a Recovery Plan action like test, recovery, cleanup, etc.

.PARAMETER RecoveryPlan
The recovery plan to start

.PARAMETER RecoveryMode
The recovery mode to invoke on the plan. May be one of "Test", "Cleanup", "Failover", "Migrate", "Reprotect"
#>
Function Send-Dismiss
{
    [cmdletbinding(SupportsShouldProcess = $True , ConfirmImpact = "High")]
    Param
    (
        [Parameter (Mandatory=$true, ValueFromPipeline=$true, Position=1)][VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan
    )

    Process 
    {
        foreach ($rp in $RecoveryPlan)
        {
            $rpinfo = $rp.GetInfo()
           
            if ($pscmdlet.ShouldProcess( $rpinfo.Name , "Dismiss Prompt" )) 
            {
                if ($rpinfo.State -eq "Prompting")
                {
                    $rp.AnswerPrompt($rp.ListPrompts().key , $false, "Dismiss")
                }

                else 
                {
                    Write-Output "Not Sending dismissal for $($rpinfo.Name).  State is $($rpinfo.State).  State should be Prompting."
                }
            }
        }
    }
}