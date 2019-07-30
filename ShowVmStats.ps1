Class STclass
{
    static [pscustomobject] MakeSTObj( [string] $vdata , [hashtable] $ohash )
    {
        $lo = [PSCustomObject]@{
            VM = $vdata
            CPUavg = $ohash.CPUavg
            MEMavg = $ohash.MEMavg
            NETavg = $ohash.NETavg
            CPUmax = $ohash.CPUmax
            MEMmax = $ohash.MEMmax
            NETmax = $ohash.NETmax
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VM.Stat.Info')
        return $lo
    }
}

<#
.SYNOPSIS
Retrieves Memory, CPU, and NET statistics
.DESCRIPTION
Retrieves Memory, CPU, and NET statistics.  Memory and CPU are in PerCentAge; NET is in KBps.  Returns an object of
VM, CPUaverage, MEMaverage, NETaverage, CPUmaximum, MEMmaximum, and NETmaximum.
.PARAMETER VM
Output from VMWare PowerCLI Get-VM. See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.PARAMETER Days
Number of Past Days to check.  Defaults to 30.  1 - 45 accepted.
.EXAMPLE
Retrieve statistical information of one VM, returning the object into a variable:
$myVar = Get-VM -Name SYS01 | Show-VMStat
.EXAMPLE
Retrieve statistical information of two VMs, returning the object into a variable:
$myVar = Get-VM -Name SYS02 , SYS03 | Show-VMStat
.INPUTS
VMWare PowerCLI VM from Get-VM:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.OUTPUTS
[pscustomobject] SupSkiFun.VM.Stat.Info
.LINK
Get-Stat
Get-StatType
Get-StatInterval
#>
function Show-VMStat
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]] $VM,

        [Parameter()][ValidateRange(1,45)] [int32] $Days = 30
    )

    Begin
    {
        $dt = Get-Date
        $nd = "No Data"
        $ohash = @{}
        $st = @(
            'cpu.usage.average' 
            'mem.usage.average' 
            'net.usage.average' 
        )
        $sp = @{
            Start = ($dt).AddDays(-$days)
            Finish = $dt
            MaxSamples = 10000
            Stat = $st
        }
    }

    Process
    {
        foreach ($v in $vm)
        {
            $ohash.Clear()
            $r1 , $c1 , $t1 = $null
            $r1 = Get-Stat -Entity $v @sp
            foreach ($s in $st)
            {
                $t1 = $s.Split(".")[0].ToUpper()
                $c1 = $r1 |
                    Where-Object -Property MetricID -Match $s |
                            Measure-Object -Property Value -Average -Maximum 
                if ($c1)
                {
                    $ohash.Add($($t1+"avg"),[math]::Round($c1.Average,2))
                    $ohash.Add($($t1+"max"),[math]::Round($c1.Maximum,2))
                }
                else
                {
                    $ohash.Add($($t1+"avg"),$nd)
                    $ohash.Add($($t1+"max"),$nd)
                }
            }
            $lo = [STclass]::MakeSTObj($v.Name , $ohash)
            $lo
            $r1 , $c1 , $t1 = $null
        }
    }
}