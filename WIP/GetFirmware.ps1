Class DellFirm
{
    static $firm = @(
        'BIOS' ,
        'BOSS-S1' ,
        'Broadcom' ,
        'Disk' ,
        'Integrated' ,
        'Dell 12Gbps HBA'
    )

    static [pscustomobject] MakeObj ( [psobject] $fval , [string] $hname )
    {
        $lo = [pscustomobject]@{
            ElementName = $fval.ElementName
            FQDD = $fval.FQDD
            Status = $fval.Status
            Version = $fval.VersionString
            Updateable = $fval.Updateable
            HostName = $hname
            ComponentID = $fval.ComponentID
            DeviceID = $fval.DeviceID
            VendorID = $fval.VendorID
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Dell.Firmware.Info')
        return $lo
    }
}

<#
    Needs Parameters, error checking, etc.  Working - fun test!
    Document ElementName, FQDD , Version, HostName are the default view
    Not all fields will be populated in the pscustomobject - depends on item.
#>

Function Get-Firmware
{
    [cmdletbinding()]
    Param()

    Begin
    {
        $firm = [DellFirm]::firm
        $env:ANSIBLE_STDOUT_CALLBACK="json"
        $pl =  ansible-playbook -i /home/ansible/YAML/inventory /home/ansible/YAML/GetFirmware.yml --ask-vault-password
        $jj = $pl |
            ConvertFrom-Json
        <# For Testing:  $jj = Get-Content ./all.json | ConvertFrom-Json #>
        $hh = $jj.plays.tasks.hosts.psobject.properties.Where({$_.MemberType -match 'NoteProperty'}).Name
        $kk = $jj.plays.tasks.hosts
    }

    Process
    {
        foreach ($m in $hh)
        {
            $ff = $kk.$($m).firmware_info.Firmware
            $gg = foreach ($a in $firm)
            {
                $ff.Where({$_.ElementName -match "^$a"})
            }
            foreach ($f in $gg)
            {
                $lo = [DellFirm]::MakeObj( $f , $m )
                $lo
            }
        }
    }

    End
    {
        $TypeData = @{
            TypeName = 'SupSkiFun.Dell.Firmware.Info'
            DefaultDisplayPropertySet = "ElementName","FQDD" ,"Version","HostName"
        }
        Update-TypeData @TypeData -Force
    }
}

