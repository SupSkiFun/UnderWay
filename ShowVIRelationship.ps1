Function Show-VIRelationship
{
    $hh = @{}
    $qq = Get-VIPermission
    $rr = Get-VIRole
    foreach ($r in $rr) 
    {
        ($p = Get-VIPrivilege -ErrorAction SilentlyContinue -Role $r).Name | Out-Null 
        $hh.add($r.Name,$p.Name) 
    }
    foreach ($q in $qq)
    {
        $lo = [PSCustomObject]@{
            Role = $q.Role
            Principal = $q.Principal
            Entity = $q.Entity.ToString()
            EntityID = $q.EntityId
            Propagate = $q.Propagate
            IsGroup = $q.IsGroup
            Permission = $hh.($q.Role)
        }
        $lo
    }
}