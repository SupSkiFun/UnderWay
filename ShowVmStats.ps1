Class STclass
{
    static [hashtable] RoundEm ( [psobject] $rdata )
    {
        $ht = @{
            Average = [Math]::Round($rdata.Average , 2)
            Minimum = [Math]::Round($rdata.Minimum , 2)
            Maximum = [Math]::Round($rdata.Maximum , 2)
        }
        return $ht
    }

    static [hashtable] NoData ( [string] $nd )
    {
        $ht = @{
            Average = $nd
            Minimum = $nd
            Maximum = $nd
        }
        return $ht
    }

    static [pscustomobject] MakeSTObj( [string] $vdata , [hashtable] $c2, [hashtable] $m2 , [hashtable] $n2 )
    {
        $lo = [PSCustomObject]@{
            VM = $vdata
            CPUaverage = $c2.Average
            MEMaverage = $m2.Average
            NETaverage = $n2.Average
            CPUminimum = $c2.Minimum
            MEMminimum = $m2.Minimum
            NETminimum = $n2.Minimum
            CPUmaximum = $c2.Maximum
            MEMmaximum = $m2.Maximum
            NETmaximum = $n2.Maximum
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VM.Stat.Info')
        return $lo
    }
}

<#
.SYNOPSIS
Retrieves Memory, CPU, and NET statistics
.DESCRIPTION
Retrieves Memory, CPU, and NET statistics as PerCentAge.  Returns an object of VM, CPUaverage,
MEMaverage, NETaverage, CPUminimum, MEMminimum, NETminimum, CPUmaximum, MEMmaximum, and NETmaximum.
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
        $st = @(
            ( $s1 = 'cpu.usage.average' )
            ( $s2 = 'mem.usage.average' )
            ( $s3 = 'net.usage.average' )
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
        <#
            Test Help, Validate Set, Overall working, need Try/Catch for Get-Stat?
            Process switch block is kinda long.....rework into something more concise?
        #>

        foreach ($v in $vm)
        {
            #  Need a try / catch here?  Seems ok without.
            #  Why the () around $v below?
            $r1 = Get-Stat -Entity ($v) @sp
            switch ($st)
            {
                $s1
                {
                    $c1 = $r1 |
                        Where-Object -Property MetricID -Match $s1 |
                            Measure-Object -Property Value -Average -Maximum -Minimum
                    if ($c1)
                    {
                       $c2 = [STclass]::RoundEm($c1)
                    }
                    else
                    {
                       $c2 = [STclass]::NoData($nd)
                    }
                }

                $s2
                {
                    $m1 = $r1 |
                        Where-Object -Property MetricID -Match $s2 |
                            Measure-Object -Property value -Average -Maximum -Minimum
                    if ($m1)
                    {
                        $m2 = [STclass]::RoundEm($m1)
                    }
                    else
                    {
                        $m2 = [STclass]::NoData($nd)
                    }
                }

                $s3
                {
                    $n1 = $r1 |
                        Where-Object -Property MetricID -Match $s3 |
                            Measure-Object -Property value -Average -Maximum -Minimum
                    if ($n1)
                    {
                        $n2 = [STclass]::RoundEm($n1)
                    }
                    else
                    {
                        $n2 = [STclass]::NoData($nd)
                    }
                }
            }

            $lo = [STclass]::MakeSTObj($v.Name , $c2 , $m2 , $n2)
            $lo
            $r1 , $c1 , $m1 , $n1 , $c2 , $m2 , $n2 = $null
        }
    }
}