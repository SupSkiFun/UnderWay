<#
.SYNOPSIS
Starts a Test SRM Recovery Plan.
.DESCRIPTION
Starts a Test SRM Recovery Plan, optionally synching data.
Does not attempt if submitted plan is not in a Ready state.
.PARAMETER RecoveryPlan
SRM Recovery Plan.  VMware.VimAutomation.Srm.Views.SrmRecoveryPlan
.PARAMETER SyncData
Future:  Defaults to False.  Can be set True to Sync Data.  Believe exposed in SRM 6.5 API
.EXAMPLE
Get-SRMRecoveryPlan is from module Meadowcroft.Srm.  However, any object containing an SRMRecoveryPlan will work.
$p = Get-SRMRecoveryPlan -Name XYZ
$p | Start-SRMTest
.EXAMPLE
Future Functionality Below:
$p = Get-SRMRecoveryPlan -Name XYZ
$p | Start-SRMTest -SyncData=$False
#>

Function Start-SRMTest
{
    [CmdletBinding(SupportsShouldProcess = $true , ConfirmImpact = 'high')]
    Param
    (
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan,

        [bool] $SyncData = $False
    )

    Begin
    {
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode] $RecoveryMode = [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode]::Test
        $ReqState = "Ready"

        <#
        Below two lines for creating the option to synch or not.  Believe exposed in SRM 6.5 API
        Also modify the entry in the process block.
        $rpOpt = New-Object VMware.VimAutomation.Srm.Views.SrmRecoveryOptions
        $rpOpt.SyncData = $False
        #>

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
                    <#
                    With Synch false purposely set, API 6.5 or Higher hopefully.
                    $rp.Start($RecoveryMode,$rpOpt)
                    #>

                    $rp.Start($RecoveryMode)
                }

                else
                {
                    $mesg = "Not Starting Test of $($rpinfo.Name).  State is $($rpinfo.State).  State should be $ReqState."
                    Write-Output "`n`t`t$mesg`n"
                }
            }
        }
    }
}