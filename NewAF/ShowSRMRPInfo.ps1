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
1. See examples!
2. $allRP = Show-SRMRecoveryPlanInfo (is equivalent to) $allRP = Show-SRMRecoveryPlanInfo -All
3. By default a subset of info is displayed. Use Select * , Format-List * , etc. to view all info.
4. Access Embedded SRM Protection Groups using property .ProtectionGroups
5. All properties can be output in JSON using the ScriptMethod .Json().  This is for terminal-viewing-convenience.
.Json() outputs a series of objects not a list of objects.  For output in a list / to a file, use ConvertTo-Json. 
.PARAMETER All
Optional.  If specified returns detailed information for all Recovery Plans.
.PARAMETER RecoveryPlan
Optional.  SRM Recovery Plan Object.  See Examples.
[VMware.VimAutomation.Srm.Views.SrmRecoveryPlan].
.INPUTS
[VMware.VimAutomation.Srm.Views.SrmRecoveryPlan]
.OUTPUTS
[pscustomobject] SupSkiFun.SRM.Recovery.Plan.Info with embedded [pscustomobject] SupSkiFun.SRM.Protection.Group.Info
.EXAMPLE
See Below:
Return all SRM Recovery Plans into a variable:
$allRP = Show-SRMRecoveryPlanInfo

Default Output:
$allRP

Extended Output:
$allRP | Format-List -Property *
        or
$allRP | Select-Object -Property *
.EXAMPLE
See Below:
Return specific SRM Recovery Plan(s) matching a criteria into a variable:
$myRP = Get-SRMRecoveryPlan | Where-Object -Property Name -Match "EX07*"
$MyVar = $myRP | Show-SRMRecoveryPlanInfo

Default Output:
$MyVar

Embedded Protection Group Output:
$MyVar.ProtectionGroups
.EXAMPLE
Experimental.  See Notes and Below:
Output SRM Recovery Plan Object in JSON:
$allRP = Show-SRMRecoveryPlanInfo
$allRP.Json()
.LINK
Get-SRMRecoveryPlan
Show-SRMProtectionGroupInfo
#>

Function Show-SRMRecoveryPlanInfo
{
    [CmdletBinding(DefaultParameterSetName = "All")]
    Param
    (
        [Parameter(ParameterSetName = "All")]
        [switch]
        $All,

        [Parameter(ParameterSetName = "RP", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Srm.Views.SrmRecoveryPlan[]]
        $RecoveryPlan
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

        if ($RecoveryPlan)
        {
            $rps = $RecoveryPlan
        }
        else
        {
            $rps = $srmED.Recovery.ListPlans()
        }

        foreach ($rp in $rps)
        {
            $lo = [dClass]::MakeRPInfoObj($rp)
            $lo
        }
    }

    End
    {
        $TypeName = 'SupSkiFun.SRM.Recovery.Plan.Info'

        $TypeData1 = @{
            TypeName = $TypeName
            MemberType = 'ScriptMethod'
            MemberName = 'Json'
            Value = {$this | ConvertTo-Json -Depth 4}
        }

        $TypeData2 = @{
            TypeName = $TypeName
            DefaultDisplayPropertySet = (
                "RecoveryPlan" ,
                "State" ,
                "RecoveryPlanVMCount" ,
                "EmptyProtectionGroup" ,
                "EmptyProtectionGroupName" ,
                "ProtectionGroupCount" ,
                "ProtectionGroups"
            )
        }

        $TypeData3 = @{
            TypeName = $TypeName
            DefaultDisplayProperty = "Name"
        }

        Update-TypeData @TypeData1 -Force
        Update-TypeData @TypeData2 -Force
        Update-TypeData @TypeData3 -Force
    }
}
