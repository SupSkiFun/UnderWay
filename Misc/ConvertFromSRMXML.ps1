class XtoJ
{
    [hashtable] Static GetDataStoreInfo ( [psobject] $bxml , [bool] $lval)
    {
        <# Want (local = True) for local Backup and (Local = False) for Remote Backup #>
        $allds = (($bxml.configurablesWrapper.data.Object |
            Where-Object -Property type -match Inventory).Attributes.InventoryTree |
                Where-Object -Property local -eq $lval).root.Datacenter.DataStore
        $thash = @{}
            foreach ($a in $allds)
            {
                $tobj = [PSCustomObject]@{
                    Name = $a.name
                    MoRef = $a.id.substring(2)
                }
                $thash.Add($a.Id, $tobj)
            }
        return $thash
    }

    [bool] Static GetLocalValue ( [psobject] $bxml )
    {
        $lval = $null
        $sxml = $bxml.configurablesWrapper.data.Object.where({$_.type -match "ProtectionGroups"})
        $sval = $sxml.Attributes.Folder.VmProtectionGroup[0].protectedSiteLocal

        if ($sval -eq "true")
        {
            [bool] $lval = $true
        }
        elseif ($sval -eq "false")
        {
            [bool] $lval = $false
        }
        else
        {
            Write-Host "Terminating.  Unable to Determine Local or Remote Site."
        }

        return $lval
    }

    [hashtable] Static GetNetWorkInfo ( [psobject] $bxml , [bool] $rval)
    {
        <# Want (local = False) for local Backup and (Local = True) for Remote Backup #>
        $allnt = (($bxml.configurablesWrapper.data.Object |
            Where-Object -Property type -match Inventory).Attributes.InventoryTree |
                Where-Object -Property local -eq $rval).root.Datacenter.Network |
                    Select-Object -Property id, name, @{n="number";e={$_.Name.Split("-")[-1]}}
        $thash = @{}
        foreach ($a in $allnt)
        {
            $tobj = [PSCustomObject]@{
                Name = $a.name
                MoRef = $a.id.substring(2)
                Number = $a.number
            }
            $thash.Add($a.Id, $tobj)
        }
        return $thash
    }

    [hashtable] Static GetProtGrpInfo ( [psobject] $bxml)
    {
        $allpg = ($bxml.configurablesWrapper.data.Object |
            Where-Object -Property type -match ProtectionGroups).Attributes.Folder.VmProtectionGroup |
                Sort-Object -Property Name
        $thash = @{}
        foreach ($a in $allpg)
        {
            $tobj = [PSCustomObject]@{
                Name = $a.name
                Description = $a.description
                MoRef = $a.id.substring(2)
                DataStores = $a.DataStores
            }
            $thash.Add($a.Id, $tobj)
        }
        return $thash
    }

    [psobject] Static GetRecPlanInfo ( [psobject] $bxml)
    {
        $allrp = ($bxml.configurablesWrapper.data.Object |
            Where-Object -Property type -match RecoveryPlans).Attributes.Folder.RecoveryPlan  |
                Sort-Object -Property Name
        return $allrp
    }

    [xml] Static GetXML ( [string] $file )
    {
        $err = $null

        try
        {
            [xml] $bxml = Get-Content -Path $file -ErrorAction SilentlyContinue -ErrorVariable err
        }
        catch
        {
            Write-Host "Terminating.  Problem Converting XML.  Error Below."
            Write-Host $_
            break
        }

        if ($err)
        {
            Write-Host "Terminating.  Problem Reading File.  Error Below."
            Write-Host $err.Exception.Message
            break
        }

        return $bxml
    }

    [pscustomobject] Static MakeDSObj ( [psobject] $dsa )
    {
        $dso = [PSCustomObject]@{
            Name = $dsa.Name
            #MoRef = $dsa.MoRef
        }
        return $dso
    }

    [pscustomobject] Static MakeNetObj ( [psobject] $nta )
    {
        $nto = [PSCustomObject]@{
            #Name = $nta.Name
            #MoRef = $nta.MoRef
            Number = $nta.Number
        }
        return $nto
    }

    [pscustomobject] Static MakePGObj ( [psobject] $nta , [array] $dsarr )
    {
        $pgo = [PSCustomObject]@{
            Name = $nta.Name
            Description = $nta.Description
            Datastores = $dsarr.Clone()
        }
        return $pgo
    }

}

<#
.SYNOPSIS
Converts Exported SRM Configuation (XML) to a PSCUSTOMOBJECT.
.DESCRIPTION
Converts Exported Site Recovery Manager (SRM) Configuation (XML) to a PSCUSTOMOBJECT.  SRM XML
file is produced by the SRM Configuration Import/Export Tool.  See Notes and Link.
.NOTES
Source XML file is produced by the SRM Configuration Import/Export Tool.
Exported SRM file can be from either the protected or recovery site.
Information produced is oriented  as follows:
    RecoveryPlan
    Description
    ProtectionGroups
        Name
        Description
        DataStores
            Name
    VlanMaps
No reverse mappping (Recovery ==> Protected) occurs.
.PARAMETER File
Full path and file name to exported XML file.  E.g. C:\MyDir\MyFile.xml
.INPUTS
XML File Produced by the SRM Configuration Import/Export Tool
.OUTPUTS
[pscustomobject] SupSkiFun.SRM.XML.Info
.EXAMPLE
Process the exported SRM File:
$myVar = ConvertFrom-SrmXML -File C:\MyDir\MyFile.xml

Examine all Records
$myVar | Format-List

Examine the First Record
$myVar[0] | Format-List

Drill Deeper into the First Record:
$myVar[0].RecoveryPlan
$myVar[0].ProtectionGroups
$myVar[0].ProtectionGroups.DataStores
$myVar[0].VlanMaps

View the First Record in JSON:
$myVar[0] | ConvertTo-Json -Depth 8

Export all the gleaned information into JSON:
$myVar | ConvertTo-Json -Depth 8 | Out-File -FilePath C:\MyDir\MyFile.json

.LINK
https://docs.vmware.com/en/Site-Recovery-Manager/8.2/com.vmware.srm.install_config.doc/GUID-B374BC22-FD8E-46EE-8ECF-99E01905A350.html
#>

Function ConvertFrom-SrmXML
{
    [cmdletbinding()]
    param
    (
        [Parameter (Mandatory = $true)]
        [string] $File
    )

    Process
    {
        $bxml = [XtoJ]::GetXML($file)
        $lval = [XtoJ]::GetLocalValue($bxml)
        $rval = !$lval

        $dshash = [XtoJ]::GetDataStoreInfo($bxml,$lval)
        $nthash = [XtoJ]::GetNetworkInfo($bxml,$rval)
        $pghash = [XtoJ]::GetProtGrpInfo($bxml)
        $allrps = [XtoJ]::GetRecPlanInfo($bxml)

        $pgarr = [System.Collections.ArrayList]::new()
        $dsarr = [System.Collections.ArrayList]::new()
        $ntarr = [System.Collections.ArrayList]::new()

        foreach ($allrp in $allrps)
        {
            $pgarr.clear()
            $ntarr.clear()
            foreach ($pg in $allrp.ProtectionGroups)
            {
                $pga = $pghash.$pg
                foreach ($ds in $pga.Datastores)
                {
                    $dso = [XtoJ]::MakeDSObj($dshash.$ds)
                    [void] $dsarr.add($dso)
                }
                $pgo = [XtoJ]::MakePGObj($pga , $dsarr)
                [void] $pgarr.add($pgo)
                $dsarr.clear()
            }

            foreach ($nt in $allrp.TestNetworkMapping.Primary)
            {
                $nto  = [XtoJ]::MakeNetObj($nthash.$nt)
                [void] $ntarr.add($nto)
            }

            if ($ntarr.count -eq 0)
            {
                $ntval = $null
            }
            else
            {
                $ntval = ($ntarr.number | Sort-Object )# -join " , "
            }

            $lo = [PSCustomObject]@{
                RecoveryPlan = $allrp.name
                Description = $allrp.Description
                ProtectionGroups = $pgarr.clone()
                VlanMaps = $ntval
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.SRM.XML.Info')
            $lo
        }
    }
}