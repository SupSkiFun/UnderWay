function Get-TagInfo
{
    [CmdletBinding()]

    param
    (
        [Parameter(ParameterSetName = "VM" , ValueFromPipeline = $true)]
                [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]] $VM,

        [Parameter(ParameterSetName = "VMHost" , ValueFromPipeline = $true)]
                [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost
    )

    Begin
    {
        $nd = @{Tag = @{Name = "No Tag Assignment Found"}}
    }

    Process
    {
        Function MakeObj
        {
            param($vdata,$tdata)
            $lo = [PSCustomObject]@{
                Entity = $vdata
                Name = $tdata.Tag.Name
                Category = $tdata.Tag.Category.Name
                Description = $tdata.Tag.Description
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Tag.Assignment.Info')
            $lo
        }

        Function GetTagInfo($ces)
        {
            foreach ($ce in $ces)
            {
                $il = $ce | Get-TagAssignment
                if($il)
                {
                    foreach ($i in $il)
                    {
                        MakeObj -vdata $ce.Name.ToSTring() -tdata $i
                    }
                }
                else
                {
                    MakeObj -vdata $ce.Name.ToSTring() -tdata $nd
                }
            }
        }

        if ($vm)
        {
            GetTagInfo($vm)
        }

        elseif ($vmhost)
        {
            GetTagInfo($vmhost)
        }
    }
}