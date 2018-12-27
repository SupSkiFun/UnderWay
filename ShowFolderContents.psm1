ShowFolderContents
Take folder input
Parse by Type / calling MakeHash
Returning an object
Possible recurse option?


<#
.SYNOPSIS
Provides information on Vsphere Folders
.DESCRIPTION
Returns an object of Name, Id, Path, and Type for specified Vsphere Folders.  If multiple folders have the same name,
they will all be returned with differing Ids and Paths listed.
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
Get-Folder -Name TEMP | Show-FolderContents
.EXAMPLE
Retrieve information for multiple folders, returning object into a variable:
$myVar = Get-Folder -Name UAT , QA | Show-FolderContents
.EXAMPLE
Retrieve information for all folders, returning object into a variable (this may require a few minutes):
$MyVar = Get-Folder -Name * | Show-FolderContents
#>

Function Show-FolderContents
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl[]]$Folder
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
                Type = $sn.Type
            }
            $lo
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VSphereFolderInfo')
        }
    }
}








<#
 Process
    {
                $drule = Get-DrsRule -Cluster $Cluster
                foreach ($rule in $drule)
                {
                        $vname = foreach ($vn in $rule.vmids)
                        {
                                $vmhash.$vn
                        }
                        $loopobj = [pscustomobject]@{
                                Name = $rule.Name
                                Cluster = $rule.cluster
                                VMId = $rule.VMIds
                                VM = $vname
                                Type = $rule.Type
                                Enabled = $rule.Enabled
                        }
                        $loopobj.PSObject.TypeNames.Insert(0,'SupSkiFun.DrsRuleInfo')
                        $loopobj
                        $vname = $null
                }
    }
#>