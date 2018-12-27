# MakeHash is a helper which makes hash tables for VM or ESXi or DStore
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

        'fl'
        {
            $flq = Get-Datastore -Name *
            $flhash = @{}
            $script:flhash = foreach ($f in $flq)
            {
                @{
                    $f.id = $f.name
                }
            }
		}
	}
}