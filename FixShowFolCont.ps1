Function Show-FolderContent
{
    [CmdletBinding()]
    
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder[]] $Folder,

        [Switch]$Recurse
    )

    Begin
    {
        $mt = "Empty Folder"
        $ei = @{
            Name = $mt
            MoRef = $mt
        }
    }

    Process
    {
        Function MakeObj
        {
            param ($item, $type)

            $lo = [pscustomobject]@{
                ItemName = $item.Name
                ItemType = $type
                ItemMoRef = $item.MoRef.ToString()
                FolderName = $fol.Name
                FolderID = $fol.ID
                FolderPath = ($fol | Show-FolderPath).Path
            }
            $lo
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VSphereFolder.Info')
        }

        Function GetInfo ($fol)
        {
            foreach ($x in $fol.ExtensionData.ChildEntity)
            {
                $t = $x.type
                $q = Get-view $x |
                    Select-Object -Property Name, Moref

                if ($Recurse -and $t -eq "Folder")
                {
                    $nfol = Get-Folder -id $q.MoRef
                    MakeObj -item $q -type $t
                    GetInfo ($nfol)
                }

                else
                {
                    MakeObj -item $q -type $t
                }
            }
        }

        foreach ($fol in $folder)
        {
            if ($fol.ExtensionData.ChildEntity)
            {
                GetInfo $fol
            }
            else
            {
                MakeObj -item $ei -type $mt
            }
        }
    }
}