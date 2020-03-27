Function Show-FolderPathTesT #Remove!
{
    [CmdletBinding()]
    
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder[]] $Folder
    )

    Process
    {
        foreach ($sn in $folder)
        {
            $sne = $sn.ExtensionData
            $fp = $sn.name
            while ($sne.Parent)
            {
                $sne = Get-View $sne.Parent
                $fp  = Join-Path -Path $sne.name -ChildPath $fp
            }

            $lo = [PSCustomObject]@{
                Name = $sn.Name
                Id = $sn.id
                Path = $fp
                Type = $sn.Type.ToString()
            }
            $lo
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VSphereFolder.Info')
        }
    }
}