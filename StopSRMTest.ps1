<#
.SYNOPSIS
Stops / cancels an SRM Test.
.DESCRIPTION
Stops / cancels an SRM Test for specified SRM Recovery Plans.
Does not attempt if submitted plan is not in a Running or Prompting state.
.PARAMETER RecoveryPlan
SRM Recovery Plan.  VMware.VimAutomation.Srm.Views.SrmRecoveryPlan
.EXAMPLE
Get-SRMRecoveryPlan is from module Meadowcroft.Srm.  However, any object containing an SRMRecoveryPlan will work.
$p = Get-SRMRecoveryPlan -Name XYZ
$p | Stop-SRMTest
#>
Function Stop-SRMTest
{
    [cmdletbinding(SupportsShouldProcess = $True , ConfirmImpact = "High")]
    Param
    (
        [Parameter (Mandatory = $true , ValueFromPipeline = $true )]
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan
    )

    Begin
    {
        $ReqState = "Running" , "Prompting"
    }

    Process
    {
        foreach ($rp in $RecoveryPlan)
        {
            $rpinfo = $rp.GetInfo()

            if ($pscmdlet.ShouldProcess($rpinfo.Name, 'Cancel'))
            {
                if ($rpinfo.State -in $ReqState)
                {
                    $rp.Cancel()
                }

                else
                {
                    $mesg = "Not Stopping $($rpinfo.Name).  State is $($rpinfo.State).  State should be $($ReqState  -join " or ")."
                    Write-Output "`n`t`t$mesg`n"
                }
            }
        }
    }
}