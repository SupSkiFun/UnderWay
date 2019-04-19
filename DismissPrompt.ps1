<#
.SYNOPSIS
Sends a Dismiss command to a SRM Recovery Plan
.DESCRIPTION
Sends a Dismiss command to a SRM Recovery Plan Prompt to continue plan execution.
Does not attempt if submitted plan is not in a Prompting state.
.PARAMETER RecoveryPlan
SRM Recovery Plan.  VMware.VimAutomation.Srm.Views.SrmRecoveryPlan
.EXAMPLE
Get-SRMRecoveryPlan is from module Meadowcroft.Srm.  However, any object containing an SRMRecoveryPlan will work.
$p = Get-SRMRecoveryPlan -Name XYZ
$p | Send-SRMDismiss
#>
Function Send-SRMDismiss
{
    [cmdletbinding(SupportsShouldProcess = $True , ConfirmImpact = "High")]
    Param
    (
        [Parameter (Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan
    )

    Begin
    {
        $ReqState = "Prompting"
    }
    Process
    {
        foreach ($rp in $RecoveryPlan)
        {
            $rpinfo = $rp.GetInfo()

            if ($pscmdlet.ShouldProcess( $rpinfo.Name , "Dismiss Prompt" ))
            {
                if ($rpinfo.State -eq $ReqState)
                {
                    $rp.AnswerPrompt($rp.ListPrompts().key , $false, "Dismiss")
                }

                else
                {
                    $mesg = "Not Sending Dismissal for $($rpinfo.Name).  State is $($rpinfo.State).  State should be $ReqState."
                    Write-Output "`n`t`t$mesg`n"
                }
            }
        }
    }
}