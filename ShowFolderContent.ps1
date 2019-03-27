<#
.SYNOPSIS
Provides contents of Vsphere Folders
.DESCRIPTION
Returns an object of ItemName, ItemType, ItemMoRef, FolderName, FolderId, and FolderPath of specified Vsphere Folders.
Item properties are the contents of the folder.  Folder properties elucidate folder information.
.PARAMETER Folder
Output from VMWare PowerCLI Get-Folder.  See Examples.
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]
.PARAMETER Recurse
If specified will recurse all subfolders of specified folder.
.INPUTS
VMWare PowerCLI Folder from Get-Folder:
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]
.OUTPUTS
[pscustomobject] SupSkiFun.VSphereFolderInfo
.EXAMPLE
Retrieve contents of one folder:
Get-Folder -Name TEMP | Show-FolderContent
.EXAMPLE
Retrieve contents of one folder and all of its subfolders:
Get-Folder -Name TEMP | Show-FolderContent -Recurse
.EXAMPLE
Retrieve content of multiple folders, returning object into a variable:
$myVar = Get-Folder -Name UAT , QA | Show-FolderContent
.EXAMPLE
Retrieve content from all folders, returning object into a variable (this may require a few minutes):
$MyVar = Get-Folder -Name * | Show-FolderContent
.LINK
Get-Folder
Show-FolderPath
#>

Function Show-FolderContent
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl[]]$Folder,

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
                ItemMoRef = $item.MoRef
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