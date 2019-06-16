<#
$srmED =  $global:DefaultSrmServers.ExtensionData
$plans = $srmED.Recovery.ListPlans()
$plans[0].GetInfo().ProtectionGroups.GetInfo()
$srmED.Protection.ListProtectedVMs()
$groups = $srmed.Protection.ListProtectionGroups()
$groups[0].ListProtectedDatastores()
$groups[0].ListRecoveryPlans()
$groups[0].     ProtectVms  UnprotectVms    ListProtectedVms
#>


Function Get-SrmRecoveryPlanJoe
{

    [cmdletbinding()]

    Param
    (
        [Parameter()] [string[]] $Name
    )

    Begin
    {
        $srmED =  $DefaultSrmServers.ExtensionData
        #$srmED =  $global:DefaultSrmServers.ExtensionData
        $plans = $srmED.Recovery.ListPlans()
    }

    Process
    {
        foreach ($plan in $plans)
        {
            $pnom = $plan.GetInfo().Name
            Add-Member -InputObject $plan -MemberType NoteProperty -Name "Name" -Value $pnom
        }
    }

    End
    {
        $plans
    }
}