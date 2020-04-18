class dClass
{
    static [pscustomobject] MakePGInfoObj ( [psobject] $pg )
    {
        $pginfo = $pg.GetInfo()
        $pgvms = $pg.ListProtectedVms().VMName
        $vmpgcnt = $pgvms.count

        $lo = [pscustomobject] @{
            Name = $pginfo.Name
            Configured = $pg.CheckConfigured()
            State = $pg.GetProtectionState().ToString()
            Type = $pginfo.Type.ToString()
            Category = $pg.GetType().Name
            VMCount = $vmpgcnt
            VMNames = $pgvms
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.SRM.Protection.Group.Info')
        return $lo
    }

    static [pscustomobject] MakeRPInfoObj ( [psobject] $rp )
    {
        $arr1 = [System.Collections.Arraylist]::new()
        $arr2 = [System.Collections.Arraylist]::new()
        $MTpg = $false
        [int] $rpvmcnt = 0
        $rpinfo = $rp.GetInfo()
        $prgcnt = $rpinfo.ProtectionGroups.Count
        foreach ($pg in $rpinfo.ProtectionGroups)
        {
            $pgo = [dClass]::MakePGInfoObj($pg)
            $arr1.add($pgo)
            $qpg = [dClass]::QueryPGObj($pgo)
            $rpvmcnt += $qpg.'Count'        #  Need the 'Count' or remove the quotes?
            if ($qpg.Name)
            {
                $arr2.add($qpg.Name)
            }
        }

        if ( $arr2 )
        {
            $MTpg = $true
        }

        $lo = [pscustomobject]@{
            RecoveryPlan = $rpinfo.Name
            Description = $rpinfo.Description
            State = $rpinfo.State.ToString()
            Type = $rp.GetType().Name.ToString()
            RecoveryPlanVMCount = $rpvmcnt
            EmptyProtectionGroup = $MTpg
            EmptyPGName = $arr2
            ProtectionGroupCount = $prgcnt
            ProtectionGroups = $arr1
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.SRM.Recovery.Plan.Info')
        return $lo
    }

    static [hashtable] QueryPGObj ( [psobject] $pgo )
    {
        $nom = ""
        $vmc = $pgo.VMCount
        if ($vmc -eq 0)
        #if ($vmc -lt 12)   # Just for testing
        {
            $nom = $pgo.Name
        }
        $hash = @{
            Name = $nom
            Count = $vmc
        }
        return $hash
    }
}

Function Get-SRMProtectionGroupInfo
{
    $pgall = Get-SRMProtectionGroup # | Select-Object -First 5  #   Just for testing - needs to be a parameter
    foreach ($pg in $pgall)
    {
        $lo = [dClass]::MakePGInfoObj($pg)
        $lo
    }
}

Function Get-SRMRecoveryPlanInfo
{
    $rpall = Get-SRMRecoveryPlan # | Select-Object  -First 5   # Just for testing - needs to be a parameter
    foreach ($rp in $rpall)
    {
        $lo = [dClass]::MakeRPInfoObj($rp)
        $lo
    }
}

#Get-SRMProtectionGroupInfo
Get-SRMRecoveryPlanInfo