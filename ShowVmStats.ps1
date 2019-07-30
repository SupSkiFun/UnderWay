Class STclass
{
    # Roundem should return a hashtable
    # No Data should return a hashtable
    # Make Obj returns a PsObject
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

        [Parameter()][ValidateRange(1,45)]$Days = 30
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
            Test Help, Validate Set
            Make Class with Methods for Rounding and Object Creation
            If using rounding use an array to loop thru values?  Avg, min, max
            Need to test for null before calling rounding / obj creation?
        #>

        Function MakeObj
        {
            param($vdata,$cdata,$mdata,$ndata)

            $lo = [PSCustomObject]@{
                VM = $vdata
                CPUaverage = [Math]::Round($cdata.Average , 2)
                MEMaverage = [Math]::Round($mdata.Average , 2)
                NETaverage = [Math]::Round($ndata.Average , 2)
                CPUminimum = [Math]::Round($cdata.Minimum , 2)
                MEMminimum = [Math]::Round($mdata.Minimum , 2)
                NETminimum = [Math]::Round($ndata.Minimum , 2)
                CPUmaximum = [Math]::Round($cdata.Maximum , 2)
                MEMmaximum = [Math]::Round($mdata.Maximum , 2)
                NETmaximum = [Math]::Round($ndata.Maximum , 2)
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VM.Stat.Info')
            $lo
        }

        foreach ($v in $vm)
        {
            $r1 = Get-Stat -Entity ($v) @sp
            switch ($st)
            {
                $s1
                {
                    $c1 = $r1 |
                    Where-Object -Property MetricID -Match $s1 |
                        Measure-Object -Property value -Average -Maximum -Minimum
                    if ($c1)
                    {
                       $c2 =  "call RoundEm "
                    }
                    else
                    {
                       $c2 =  "make Hash of No Data"
                       $nd
                    }
                }

                $s2
                {
                    $m1 = $r1 |
                    Where-Object -Property MetricID -Match $s2 |
                        Measure-Object -Property value -Average -Maximum -Minimum
                }

                $s3
                {
                    $n1 = $r1 |
                    Where-Object -Property MetricID -Match $s3 |
                        Measure-Object -Property value -Average -Maximum -Minimum
                }
            }

            MakeObj -vdata $v.Name -cdata $c1 -mdata $m1 -ndata $n1
            $r1 , $c1 , $m1 , $n1 , $c2 , $m2 , $n2 = $null
        }
    }
}