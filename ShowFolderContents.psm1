ShowFolderContents
Take folder input
Parse by Type / calling MakeHash
Return object
Possible recurse option?

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