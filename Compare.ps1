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
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Compare.VMHostSetting')
            $lo
        }
    }
}