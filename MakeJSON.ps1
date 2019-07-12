class myClass
{
    static [hashtable] MakeHash( [string] $quoi )
    {
        $src = $null
        $shash = @{}

        switch ($quoi)
        {
            ds { $src = Get-Datastore -Name * }
            ex { $src = Get-VMHost -Name * }
            vm { $src = Get-VM -Name * }
        }

        foreach ($s in $src)
        {
            $shash.add($s.Id , $s.Name)
        }
        return $shash
    }
}

$recplans = Get-SRMRecoveryPlan |
    Sort-Object -Property Name
$dstores = [myClass]::MakeHash("ds")

foreach ($plan in $recplans)
{
    $lo = [System.Collections.Specialized.OrderedDictionary]::new()
    $lo.add("RecoveryPlan",$plan.Name)
    $plist = [System.Collections.ArrayList]::new()
    $pgroups = $plan.GetInfo().ProtectionGroups
    foreach ($p in $pgroups)
    {
        $pgname = $p.GetInfo().Name
        $dsmoref = $p.ListProtectedDatastores().MoRef.ToString()
        #put if statment for contains here
        $dsname = $dstores.$dsmoref
        $pginfo = @{
            Name = $pgname
            DataStore = $dsname
            DataStoreMoref = $dsmoref
        }
        [void]$plist.add($pginfo)
    }
    $lo.add("ProtectionGroup",$plist)
    $lo.add("VlanMaps",$null)
    $lo
}


