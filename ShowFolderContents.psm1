# MakeHash is a helper which makes hash tables for VM or ESXi or DStore or Folder or Cluster
Function MakeHashT([string]$quoi)
{
	switch ($quoi)
	{
		'vm'
		{
			$vmq = Get-VM -Name *
			$vmhash = @{}
			$script:vmhash = foreach ($v in $vmq)
			{
				@{
					$v.id = $v.name
				}
			}
		}

		'ex'
		{
			$exq = Get-VMHost -Name *
			$exhash = @{}
			$script:exhash = foreach ($e in $exq)
			{
				@{
					$e.id = $e.name
				}
			}
		}

		'ds'
		{
			$dsq = Get-Datastore -Name *
			$dshash = @{}
			$script:dshash = foreach ($d in $dsq)
			{
				@{
					$d.id = $d.name
				}
            }
        }

        'fl'
        {
            $flq = Get-Folder -Name *
            $flhash = @{}
            $script:flhash = foreach ($f in $flq)
            {
                @{
                    $f.id = $f.name
                }
            }
        }

        'cl'
        {
            $clq = Get-Cluster -Name *
            $clhash = @{}
            $script:clhash = foreach ($c in $clq)
            {
                @{
                    $c.id = $c.name
                }
            }
        }
        
        'trop'
        {
            <# 
                Done this way as a template ID reflects a VM; e.g. VirtualMachine-vm-733 is the id for a template. To avoid confusion,
                the specific command for each item is issued and then populates the hash with the specific type. 
                The $chose values are used for both the Get command and assigning a type to the items.
                Hash results in (Name = The Items Id) and (Value = The Items Name and Type) 
            #>
            
            $chose =
            (
                "Cluster",
                "DataCenter",
                "DataStore",
                "Folder",
                "Template",
                "VM",
                "VMHost"
            )

            #$trophash = @{}
            $script:trophash = @{}
            foreach ($ch in $chose)
            {

                $tropq = Invoke-Expression -Command ("Get-$ch  -Name *")
                foreach ($tr in $tropq)
                {
                    #$trophash.add($tr.id , ($tr.name, $ch))
                    $script:trophash.add($tr.id , ($tr.name, $ch))
                }
            }
        }
	}
}

<#
.SYNOPSIS
Provides contents of Vsphere Folders
.DESCRIPTION
Returns an object of FolderName, FolderID, ItemName, ItemId, and ItemType of a Vsphere Folder's contents.  
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

    Begin
    {
        MakeHashT 'trop'
        $empty = "Empty"
    }
    
    Process
    {
        foreach ($f in $folder)
        {
            $kids = $f.ExtensionData.ChildEntity
            if(!($kids))
            {
                # Make a seperate function here?
                $lo = [PSCustomObject]@{
                    FolderName = $f.Name
                    FolderID = $f.Id
                    ItemName = $empty
                    ItemType = $empty
                    ItemId = $empty
                }
                $lo
                $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VSphereFolderInfo')
            }
            
            else
            {
                foreach ($k in $kids)
                {
                    $k2 = $k.ToString()
                    if ($trophash.ContainsKey($k2))
                    {
                        $kname = $trophash.($k2)[0]
                        $ktype = $trophash.($k2)[1]                    
                    }
                    else
                    {
                        $kname = $k.Value
                        $ktype = $k.Type
                    }
                
                    # Make a seperate function here?
                    $lo = [PSCustomObject]@{
                        FolderName = $f.Name
                        FolderID = $f.Id
                        ItemName = $kname
                        ItemType = $ktype
                        ItemId = $k2
                    }
                    $lo
                    $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VSphereFolderInfo')
                }
            }
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