<#
.SYNOPSIS
Provides information on Vsphere Folders
.DESCRIPTION
Returns an object of Name, Id, Path, and Type for specified Vsphere Folders.
.PARAMETER Folder
Output from VMWare PowerCLI Get-Folder.  See Examples.
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]
.INPUTS
VMWare PowerCLI Folder from Get-Folder:
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]
.OUTPUTS
[pscustomobject] SupSkiFun.VSphereFolderInfo
.EXAMPLE
Retrieve information for one folder name:
SPECIFIC EXAMPLE HERE
.EXAMPLE
Retrieve information for multiple folders:
SPECIFIC EXAMPLE HERE
.EXAMPLE
Retrieve information for all folders (this may require a few minutes):
SPECIFIC EXAMPLE HERE
#>

function GetSubFolder($fol) 
{
    
    
    foreach ($sn in $fol)
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
            Type = $sn.Type
        }
        $lo
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VSphereFolderInfo')
    }
}

#### Put in documentation / help / examples.  
## Test more - email to Luc D?


#$exNames = "Datacenters","vm","host"
#$rf = get-folder -Name d* -Type VM
#$rf = get-folder -Name d* #-Type VM
#$rf =  get-folder -Name vm
#$rf =  get-folder -Name Docker
#$rf =  get-folder -Name VDI
#$rf =  get-folder -Name *
#$rf = Get-Folder -Name CORP
#GetSubFolder($rf)
