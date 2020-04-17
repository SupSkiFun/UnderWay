class dClass
{
    static [pscustomobject] MakePGInfoObj ([psobject] $prg)
    {
        $prginfo = $prg.GetInfo()
        $prgvms = $prg.ListProtectedVms().VMName
        $vmprgcnt = $prgvms.count
        if ($vmprgcnt -eq 0) {}
        
        $lo = [pscustomobject] @{
            Name = $prginfo.Name
            Configured = $prg.CheckConfigured()
            State = $prg.GetProtectionState().ToString()
            Type = $prginfo.Type
            Category = $prg.GetType().Name
            VMCount = $vmprgcnt
            VMNames = $prgvms
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.SOMETHING.CREATIVE.HERE')
        return $lo
    }  
}

Function TryIt
{
    $pgall = Get-SRMProtectionGroup
    foreach ($prg in $pgall)
    {
        [dClass]::M
    }
}