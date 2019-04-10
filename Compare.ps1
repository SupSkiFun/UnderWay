<#
.SYNOPSIS
Compare ESXi Baseline value to value of VMHost
.DESCRIPTION
Returns an object of Reference, Comparison, ValueSource, Name and Value.  
Optimally used with a baseline source; see examples.  Alias cvs.
.PARAMETER Reference
Baseline object to compare to.  $refObj = import-csv baseline.csv
Baseline generated with Get-VmHostSetting.  See Example.
.PARAMETER Difference
Object value to compare against Reference.  Normally the output of 
Get-VmHostSetting.  SupSkiFun.VMHostSetting
.INPUTS
SupSkiFun.VMHostSetting
BaseLine Object
.OUTPUTS
SupSkiFun.VMHostSetting.Compare
.EXAMPLE
Create Baseline:  $baseline = Get-VMHostSetting -VMHost ESXi03 -Credential $creds

Modify Baseline:
    ($baseline| ? Name -eq LicenseKey).Value = "Removed"
    ($baseline| ? Name -eq Syslog.global.logHost).Value = "Varies"

Create Comparison Object:  $comObj = Get-VMHostSetting -VMHost ESXi777 -Credential $creds

Compare-VMHostSetting -Reference $baseline -Comparison $comObj

Using the alias, storing the object in a variable:  $myVar = cvs -Reference $baseline -Comparison $comObj

----------------------------------------------------------------------------

Optionally Export and later Import:

Export Baseline:  $baseline | Export-Csv D:\6.7\baseline.csv

Import Baseline:  $refObj = Import-Csv D:\6.7\baseline.csv

$comObj = Get-VMHostSetting -VMHost ESXi777 -Credential $creds

Compare-VMHostSetting -Reference $refObj -Comparison $comObj

.LINK
Get-VMHostSetting
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
        [psobject]$Comparison
    )

    Process
    {
        $d1 = Compare-Object -ReferenceObject $Reference -DifferenceObject $Comparison -Property Name , Value
        $dhost = $Comparison.Hostname.Split(".")[0]
        foreach ($d in $d1)
        {
            if ($d.SideIndicator -eq "=>")
            {
                $hname = "Comparison"
            }
            elseif ($d.SideIndicator -eq "<=") 
            {
                $hname = "Reference"
            }


            $lo = [pscustomobject]@{
                Reference = $Reference.Hostname.Split(".")[0]
                Comparison = $dhost
                ValueSource = $hname
                Name = $d.Name
                Value = $d.Value
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VMHostSetting.Compare')
            $lo
        }
    }
}