<#
    Breaking this into smaller files / methods / classes
#>

$plans = Get-SRMRecoveryPlan
$arr1 = [System.Collections.ArrayList]::new()
$arr2 = [System.Collections.ArrayList]::new()


foreach ($plan in $plans[4..7]) 
{
    $arr1.clear()
    $arr2.clear()
    $MTprg = $false
    $rpinfo = $plan.GetInfo()
    $rptype = $plan.GetType().Name
    $prgcnt = $rpinfo.ProtectionGroups.Count

    foreach ($prg in $rpinfo.ProtectionGroups) 
    {
        $prginfo = $prg.GetInfo()
        $prgvms = $prg.ListProtectedVms().VMName
        $vmprgcnt = $prgvms.count
        if ($vmprgcnt -eq 0) 
        {
            $MTprg = $true 
            [void] $arr2.add($prginfo.Name)
        } 
        
        $inlo = [pscustomobject] @{
            Name = $prginfo.Name
            Configured = $prg.CheckConfigured()
            State = $prg.GetProtectionState().ToString()
            Type = $prginfo.Type
            Category = $prg.GetType().Name
            VMCount = $vmprgcnt
            VMNames = $prgvms
        }
  
        [void]$arr1.Add($inlo.PSObject.Copy())

    }

    $lo = [pscustomobject]@{
        RecoveryPlan = $rpinfo.Name
        Description = $rpinfo.Description
        State = $rpinfo.State.ToString()
        Type = $rptype
        EmptyPG = $MTprg
        EmptyPGName = $arr2
        ProtectionGroupCount = $prgcnt
        ProtectionGroups = $arr1
    }
    $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.SOMETHING.CREATIVE.HERE')
    $lo
}