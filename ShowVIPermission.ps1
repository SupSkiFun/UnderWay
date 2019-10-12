class vClasss
{
    static [pscustomobject] MakePPRObj ( [psobject] $perm , [Array] $priv )
    {
        $obj = [PSCustomObject]@{
            Role = $perm.Role
            Principal = $perm.Principal
            Entity = $perm.Entity.ToString()
            EntityID = $perm.EntityId
            Propagate = $perm.Propagate
            IsGroup = $perm.IsGroup
            Privilege = $priv
        }
        $obj.PSObject.TypeNames.Insert(0,'SupSkiFun.Permissions.Info')
        return $obj
    }
}
<#
.SYNOPSIS
Outputs all Permissions and their affiliated Roles and Privileges.
.DESCRIPTION
Amalgamates all Permissions and their affiliated Roles and Privileges.  Useful for archive and/or (re)creation.
Returns an object of Role, Principal, Entity, EntityID, Propogate, IsGroup. and Privilege.
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.Permissions.Info
.EXAMPLE
Return the object into a variable:
$MyVar = Show-VIPermission
.EXAMPLE
Return JSON into a variable:
$MyVar = Show-VIPermission | ConvertTo-Json -Depth 3
.LINK
Get-VIPermission
Get-VIPrivilege
Get-VIRole
#>
Function Show-VIPermission
{
    [CmdletBinding()]
    param()

    Begin
    {
        $hh = @{}
        $qq = Get-VIPermission
        $rr = Get-VIRole
    }

    Process
    {
        Function MakePrivHash
        {
            foreach ($r in $rr)
            {
                ($p = Get-VIPrivilege -ErrorAction SilentlyContinue -Role $r).Name |
                    Out-Null
                $hh.add($r.Name,$p.Name)
            }
        }

        MakePrivHash

        foreach ($q in $qq)
        {
            $lo = [vClasss]::MakePPRObj($q , $hh.($q.Role))
            $lo
        }
    }
}