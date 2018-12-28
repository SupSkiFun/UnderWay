# MakeHash is a helper which makes hash tables for VM or ESXi or DStore or Folder or Cluster
Function MakeHash([string]$quoi)
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
            $chose =
            (
                "Cluster",
                "DataCenter",
                "DataStore",
                "Folder",
                "Template",
                "VM"
            )

            $trophash = @{}
            #$script:trophash = @{}
            foreach ($ch in $chose)
            {
                $tropq = Invoke-Expression -Command ("Get-$ch  -Name *")
                foreach ($tr in $tropq)
                {
                    $trophash.add($tr.id , ($tr.name, $ch))
                    #$script:trophash.add($tr.id , ($tr.name, $ch))
                }
            }
            $trophash
            #$script:trophash  SHOULDN'T BE NEEDED
        }
	}
}

MakeHash "trop"