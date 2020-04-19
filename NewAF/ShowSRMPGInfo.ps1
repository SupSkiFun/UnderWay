using module .\dClass.psm1

<#
    Change all instances of dClass to sClass
#>

<#
.SYNOPSIS
Shows Protection Group Detailed Information
.DESCRIPTION
Shows Protection Group Detailed Information for submitted Protection Groups.  If no Protection Groups
or parameters are specified, returns detailed information for all Protection Groups.  See Examples.
Can be run on recovery or protected site.
.NOTES
1. See examples!
2. Show-SRMProtectionGroupInfo (is equivalent to) Show-SRMProtectionGroupInfo -All
3. By default a subset of info is displayed. Use Select * , Format-List * , etc. to view all info.
4. All properties can be output in JSON using the ScriptMethod .Json()
.PARAMETER All
Optional.  If specified returns detailed information for all Protection Groups.
.PARAMETER ProtectionGroup
Optional.  Protection Group Object.  See Examples.
[VMware.VimAutomation.Srm.Views.SrmProtectionGroup]
.INPUTS
[VMware.VimAutomation.Srm.Views.SrmProtectionGroup]
.OUTPUTS
[pscustomobject] SupSkiFun.SRM.Protection.Group.Info
.EXAMPLE
See Below:
Return all SRM Protection Groups into a variable:
$allPG = Show-SRMProtectionGroupInfo

Default Output:
$allPG

Extended Output:
$allPG | Format-List -Property *
        or
$allPG | Select-Object -Property *
.EXAMPLE
See Below:
Return specific SRM Protection Group(s) matching a criteria into a variable:
$myPG = Get-SRMProtectionGroup | Where-Object -Property Name -Match "EX07*"
$MyVar = $myPG | Show-SRMProtectionGroupInfo
$MyVar
.EXAMPLE
See Below:
Output SRM Protection Group Object in JSON:
$allPG = Show-SRMProtectionGroupInfo
$allPG.json()
.LINK
Get-SRMProtectionGroup
Show-SRMRecoveryPlanInfo
#>

Function Show-SRMProtectionGroupInfo
{
    [CmdletBinding(DefaultParameterSetName = "All")]

    Param
    (
        [Parameter(ParameterSetName = "All")]
        [switch]
        $All,

        [Parameter(ParameterSetName = "PG", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Srm.Views.SrmProtectionGroup[]]
        $ProtectionGroup
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

        if ($ProtectionGroup)
        {
            $pgs = $ProtectionGroup
        }
        else
        {
            $pgs = $srmED.Protection.ListProtectionGroups()
        }

        foreach ($pg in $pgs)
        {
            $lo = [dClass]::MakePGInfoObj($pg)
            $lo
        }
    }

    End
    {
        $TypeName = 'SupSkiFun.SRM.Protection.Group.Info'

        $TypeData1 = @{
            TypeName = $TypeName
            MemberType = 'ScriptMethod'
            MemberName = 'Json'
            Value = {$this | ConvertTo-Json -Depth 4}
        }

        $TypeData2 = @{
            TypeName = $TypeName
            DefaultDisplayPropertySet = (
                "ProtectionGroup" ,
                "Configured" ,
                "State" ,
                "VMCount" ,
                "VMNames"
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