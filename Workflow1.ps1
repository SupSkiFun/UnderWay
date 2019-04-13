# Copied From http://www.lucd.info/2015/03/17/powercli-and-powershell-workflows/
workflow test {
   param(
      [string]$vcenter,
      [string[]]$names,
      [string]$session
   )
   foreach -parallel($name in $names){
      $vm = InlineScript{
         Connect-VIServer -Server $Using:vcenter -Session $Using:session | Out-Null
         Get-VM -Name $Using:name
      }
      $vm.Name
   }
}

$vmNames = 'vm1','vm2','vm3'
test -names $vmNames -vcenter $global:DefaultVIServer.Name -session $global:DefaultVIServer.SessionSecret
#########################################################

# My Test Workflow

workflow Test-Vib {
    param (
        [string]$vcenter,
        [string[]]$names,
        [string]$session
     )

    foreach -parallel($name in $names)
     {
        InlineScript
        {
            Connect-VIServer -Server $Using:vcenter -Session $Using:session | Out-Null
            $x = Get-Esxcli -VMHost $Using:name -V2
            $y = $x.system.version.get.Invoke() 

            $lo = [PSCustomObject]@{
                HostName = $x.system.hostname.get.invoke().HostName
                Build = $y.Build
                Version = $y.version
            }
            
            # return $lo
            $lo
        }
    }
}

########################################################

# My Test Function

function Test-Vib2 {

    param ( [string[]]$names)

    foreach ($name in $names) {
    $x = Get-Esxcli -VMHost $name -V2
                $y = $x.system.version.get.Invoke()

                $lo = [PSCustomObject]@{
                    HostName = $x.system.hostname.get.invoke().HostName
                    Build = $y.Build
                    Version = $y.version
                }

                # return $lo
                $lo
    }
}
 

<#
Test Results Below


$c = (get-vmhost *).Name
$c.count 38 

measure-command {$rr = Test-Vib -names $c -vcenter $global:DefaultVIServer.Name -session $global:DefaultVIServer.SessionSecret}

    Minutes           : 0
    Seconds           : 36
    Milliseconds      : 299    




measure-command {$tt = Test-Vib2 -names $c}
    
    Minutes           : 0
    Seconds           : 13
    Milliseconds      : 232


Parallel Workflow ran 23 seconds slower, gave this error twice:

WARNING: [localhost]:The process cannot access the file 'C:\Users\ja0310\AppData\Roaming\VMware\PowerCLI\RecentServerList.xml' because it is being used by another
process.

And put these unwanted fields into my custom object:

PSComputerName        : localhost
PSSourceJobInstanceId : e5d42c45-ba88-45fd-a2c8-ddfb6cb0d3b8

Likely could just use (return $valuesfromqueries) and make the psobject outside the WorkFlow.

So far it seems like all the overhead of reconnecting to the Vcenter outweigh the parallel execution.

Would have to be a job with lots of systems to hit, or a long running job on each system (maybe VIB patching?)
The task has to outweigh the overhead of converting PowerShell to XAML AND the overhead of connecting to VCenter
for each and every task ran in parallel.

#>