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

            $script:trophash = @{}
            foreach ($ch in $chose)
            {

                $tropq = Invoke-Expression -Command ("Get-$ch  -Name *")
                foreach ($tr in $tropq)
                {
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
Retrieve contents for one folder name:
Get-Folder -Name TEMP | Show-FolderContent
.EXAMPLE
Retrieve contents for multiple folders, returning object into a variable:
$myVar = Get-Folder -Name UAT , QA | Show-FolderContent
.EXAMPLE
Retrieve contents for all folders, returning object into a variable (this may require a few minutes):
$MyVar = Get-Folder -Name * | Show-FolderContent
#>

Function Show-FolderContent
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl[]]$Folder
    )

    Begin
    {
       <#
        ##  Put in logic here to build the hash if it doesn't exist or if refresh is requested; actually to use
        ##  a parameter I might need to put it in the process block.  Getting too complex?
        ##  Which means a refresh parameter needs to be created.
        ##  Which means that $folder mandatory should be set false and logic to catch no input created.
        ##  Help needs to be updated with the above + examples to refresh the hash.
        ##  Make a weird-ass-name for the hash as well.  Get-Random?  Actually won't work - how check for it if random?
        #MakeHashT 'trop'

        ## OK this is getting ugly.  Psscript analyzer doesn't like a) the global variable and b) the invoke-expression.  
        ## Revisit and fix

        TropHashSupSkiFun  - I like that!

        function ql  {$args}
  25 $l = ql a b c d e f g h i j k l m n o p q r s t u v w x y z
  $m = $l |get-random -count 12

        if ($trophash){"yes"} else {"no"}

        #>
        $empty = "Empty"
    }

    Process
    {
        Function JuicyO ($p1 , $p2 , $p3 = $empty , $p4 = $empty , $p5 = $empty)
        {
            $lo = [PSCustomObject]@{

                ItemName = $p3
                ItemType = $p4
                ItemId = $p5
                FolderName = $p1
                FolderID = $p2
            }
            $lo
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VSphereFolderInfo')
        }


        foreach ($f in $folder)
        {
            $kids = $f.ExtensionData.ChildEntity

            if(!($kids))
            {
                JuicyO $f.name $f.id
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

                    JuicyO $f.name $f.id $kname $ktype $k2
                }
            }
        }
    }
}