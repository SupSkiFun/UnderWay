<#
.SYNOPSIS
Compare ESXi Baseline value to value of VMHost
.DESCRIPTION
Returns an object of ValueSource, ComparedSystem, Name and Value.  
Optimally used with a baseline source; see examples.  Alias cvs.
.PARAMETER Reference
Baseline object to compare to.  $refobj = import-csv baseline.csv

.PARAMETER Difference
Object value to compare against Reference.  Normally the output of 
Get-VmHostSetting.  SupSkiFun.VMHostSetting
.INPUTS
SupSkiFun.VMHostSetting
BaseLine Object
.OUTPUTS
SupSkiFun.VMHostSetting.Compar
.EXAMPLE
Query one VM for RDMs:

.EXAMPLE
Query one VMHost for RDMs:


#>

Function Compare-VMHostSetting
{
    [CmdletBinding()]
    [Alias("cvs")]

    param
    (
        [Parameter(Mandatory = $True)]
        [psobject]$Reference,

        [Parameter(Mandatory = $True , ValueFromPipeline = $True)]
        [psobject]$Difference
    )

    Process
    {
        $d1 = Compare-Object -ReferenceObject $Reference -DifferenceObject $Difference -Property Name , Value
        $dhost = $Difference.Hostname.Split(".")[0]
        foreach ($d in $d1)
        {
            if ($d.SideIndicator -eq "=>")
            {
                $hname = "Reference"
            }
            else
            {
                $hname = $dhost
            }

            $lo = [pscustomobject]@{
                ValueSource = $hname
                ComparedSystem = $dhost
                Name = $d.Name
                Value = $d.Value
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VMHostSetting.Compare')
            $lo
        }
    }
}