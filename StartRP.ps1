<#
.SYNOPSIS
Start a Recovery Plan action like test, recovery, cleanup, etc.

.PARAMETER RecoveryPlan
The recovery plan to start

.PARAMETER RecoveryMode
The recovery mode to invoke on the plan. May be one of "Test", "Cleanup", "Failover", "Migrate", "Reprotect"
#>
Function Start-RP
{
    [cmdletbinding(SupportsShouldProcess = $True , ConfirmImpact = "High")]
    Param
    (
        [Parameter (Mandatory=$true, ValueFromPipeline=$true, Position=1)][VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]] $RecoveryPlan,
        [bool] $SyncData = $False
    )

    Begin
    {
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode] $RecoveryMode = [VMware.VimAutomation.Srm.Views.SrmRecoveryPlanRecoveryMode]::Test
    }

    Process 
    {
        foreach ($rp in $RecoveryPlan)
        {
            $rpinfo = $rp.GetInfo()
            $rpOpt = New-Object VMware.VimAutomation.Srm.Views.SrmRecoveryOptions
            $rpOpt.SyncData = $False
            
            if ($pscmdlet.ShouldProcess($rpinfo.Name, $RecoveryMode)) 
            {
                if ($rpinfo.State -eq 'Ready') 
                {
                    <#  Actual execution  Steps Below
                    
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
                    Write-Output "Not Starting Test of $($rpinfo.Name).  State is $($rpinfo.State).  State should be Ready."
                }
            }
        }
    }
}