class dClass
{
    static [pscustomobject] MakePGInfoObj ( [psobject] $pg )
    {
        $pginfo = $pg.GetInfo()
        $pgvms = $pg.ListProtectedVms().VMName
        $vmpgcnt = $pgvms.count

        $lo = [pscustomobject] @{
            ProtectionGroup = $pginfo.Name
            Description = $pginfo.Description
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
            $rpvmcnt += $qpg.Count
            if ($qpg.Name)
            {
                $arr2.add($qpg.Name)
            }
        }

        if ( $arr2 )
        {
            $MTpg = $true
        }
        #  Combine These into if / elsif ?
        if ($prgcnt -eq 0)
        {
            $MTpg = "N/A"
        }

        $lo = [pscustomobject]@{
            RecoveryPlan = $rpinfo.Name
            Description = $rpinfo.Description
            State = $rpinfo.State.ToString()
            Type = $rp.GetType().Name.ToString()
            RecoveryPlanVMCount = $rpvmcnt
            EmptyProtectionGroup = $MTpg
            EmptyProtectionGroupName = $arr2
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
            #$nom = $pgo.Name   Think this was breaking the report
            $nom = $pgo.ProtectionGroup
        }
        $hash = @{
            Name = $nom
            Count = $vmc
        }
        return $hash
    }
}
