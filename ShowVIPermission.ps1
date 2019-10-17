class vClasss
{
    static [pscustomobject] MakePPRObj ( [psobject] $perm , [Array] $priv )
    {
        $obj = [PSCustomObject]@{
            Role = $perm.Role
            RoleIsSystem = $priv[0]
            Principal = $perm.Principal
            Entity = $perm.Entity.ToString()
            EntityID = $perm.EntityId
            Propagate = $perm.Propagate
            PrincipalIsGroup = $perm.IsGroup
            Privilege = $priv[1]
        }
        $obj.PSObject.TypeNames.Insert(0,'SupSkiFun.Permissions.Info')
        return $obj
    }
}
<#
.SYNOPSIS
Outputs all Permissions with their affiliated Role and Privileges.
.DESCRIPTION
Amalgamates all Permissions with their affiliated Role and Privileges.
Returns an object of Role, RoleIsSystem, Principal, Entity, EntityID, Propogate, PrincipalIsGroup, and Privilege.
.NOTES
Optimal for archiving and for (re)creating roles and permissions.  Convertable to JSON (see example).
A privilege defines right(s) to perform actions and read properties.
A role is a set of privileges.
A permission gives a Principal (user or group) a role for a specific entity.
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
New-VIPermission
#>
Function Show-VIPermission
{
    [CmdletBinding()]
    Param()

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
                # hash with array value.  [0] is true/false. [1] is array of privileges
                $hh.add($r.Name,@($r.IsSystem,$p.Name))
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