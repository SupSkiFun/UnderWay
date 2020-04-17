$plans = Get-SRMRecoveryPlan
$arr = [System.Collections.ArrayList]::new()


foreach ($plan in $plans[1..3]) 
{
    $arr.clear()
    $rpinfo = $plan.GetInfo()
    $rptype = $plan.GetType().Name
    $MTprg = $false
 
    foreach ($prg in $rpinfo.ProtectionGroups) 
    {
        $prginfo = $prg.GetInfo()
        $prgvms = $prg.ListProtectedVms().VMName
        $prgcnt = $prgvms.count
        if ($prgcnt -eq 0) 
        {
            $MTprg = $true 
            $b += $prginfo.Name
        }  # Make this niftier
        
        $inh = [pscustomobject]@{
        Name = $prginfo.Name
        Configured = $prg.CheckConfigured()
        State = $prg.GetProtectionState().ToString()
        Type = $prginfo.Type
        Category = $prg.GetType().Name
        VMCount = $prgcnt
        VMNames = $prgvms
        }
        
        [void] $arr.add($hash.clone())
    }

    $lo = [pscustomobject]@{
    RecoveryPlan = $rpinfo.Name
    EmptyPG = $MTprg
    EmptyPGName = $b
    Description = $rpinfo.Description
    State = $rpinfo.State.ToString()
    ProtectionGroups = $arr
    }
    $lo
}

