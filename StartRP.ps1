<#
.SYNOPSIS
Starts a Test SRM Recovery Plan.
.DESCRIPTION
Starts a Test SRM Recovery Plan, optionally synching data.
Does not attempt if submitted plan is not in a Ready state.
.PARAMETER RecoveryPlan
SRM Recovery Plan.  VMware.VimAutomation.Srm.Views.SrmRecoveryPlan
.PARAMETER SyncData
Defaults to False.  Can be set True to Sync Data.
.EXAMPLE
Get-SRMRecoveryPlan is from module Meadowcroft.Srm.  However, any object containing an SRMRecoveryPlan will work.
$p = Get-SRMRecoveryPlan -Name XYZ
$p | Start-SRMRecoveryPlanTest
#>

Function Start-SRMRecoveryPlanTest
{
    [cmdletbinding(SupportsShouldProcess = $True , ConfirmImpact = "High")]
    Param
    (
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan,

        [bool] $SyncData = $False
    )

    Begin
    {
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode] $RecoveryMode = [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode]::Test
        $rpOpt = New-Object VMware.VimAutomation.Srm.Views.SrmRecoveryOptions
        $rpOpt.SyncData = $False
        $ReqState = "Ready"
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
                    <#  Actual execution  Steps Below

                    Try with SyncData Set - if failure
                    Just run without it.

                    Just Trying Plain Jane
                    $RecoveryPlan.Start($RecoveryMode)

                    With the no Synch purposely set
                    $RecoveryPlan.Start($RecoveryMode, $rpOpt)


                    #>
                    Write-Output "Simulating Start"
                    "Name $($rpinfo.Name)"
                    "State $($rpinfo.State)"
                    "Recovery Mode $RecoveryMode"
                    "Options $rpOpt"
                    "Synch Data $SyncData"
                    $RecoveryMode
                    $rpOpt
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