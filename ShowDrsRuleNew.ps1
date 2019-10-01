class vClasss
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

    static [pscustomobject] MakeSDRObj ( [Array] $VName , [PSObject] $Rule )
    {
        $obj = [pscustomobject]@{
            Name = $rule.Name
            Cluster = $rule.cluster.ToSTring()
            VMId = $rule.VMIds
            VM = $vname
            Type = $rule.Type.ToString()
            Enabled = $rule.Enabled.ToString()
        }
        $obj.PSObject.TypeNames.Insert(0,'SupSkiFun.DrsRuleInfo')
        return $obj
    }
}

<#
.SYNOPSIS
Outputs DRS rules for specified clusters
.DESCRIPTION
Outputs an object of DRS Rule Name, cluster, VMIds, VM Name, Type and Enabled for specified clusters.
Alias = sdr
.PARAMETER Cluster
Mandatory. Cluster(s) to query for DRS rules. Can manually enter or pipe output from VmWare Get-Cluster.
.OUTPUTS
PSCUSTOMOBJECT SupSkiFun.PortGroupInfo
.EXAMPLE
Retrieve DRS rule for one cluster, placing the object into a variable:
$MyVar = Show-DrsRule -Cluster cluster09
.EXAMPLE
Retrieve DRS rules for all clusters, using the Show-DrsRule alias, placing the object into a variable:
$MyVar = Get-Cluster -Name * | sdr
#>
function Show-DrsRuleNew
{
    [CmdletBinding()]
    [Alias("sdr")]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true, 
            ValueFromPipeline = $true, Mandatory=$true)]
        [Alias("Name")]
        $Cluster
    )

    Begin
    {
        $vmhash = [vClasss]::MakeHash('vm')
    }

    Process
    {
        $drule = Get-DrsRule -Cluster $Cluster
        foreach ($rule in $drule)
        {
            $vname = foreach ($vn in $rule.vmids)
            {
                $vmhash.$vn
            }
            $lo = [vClasss]::MakeSDRObj($vname , $rule)
            $lo
            $vname = $null
        }
    }
}