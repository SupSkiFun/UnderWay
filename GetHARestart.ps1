Class NewVClass
{
    static [pscustomobject] ParseInfo( [psobject] $line )
    {
        # Need to RegEx this; below relies on error message always being the same.
        $y = $line.FullFormattedMessage.Substring(37).split()
        # Need to make ErrorVariable and actions for it.
        $v = Get-VM -Name $y[0].trim() -ErrorAction SilentlyContinue
        $lo = [pscustomobject]@{
            VM = $v.Name
            Notes = $v.Notes
            NewHost = $y[3].trim()
            DateTime = $line.CreatedTime
            FullMessage = $line.FullFormattedMessage
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.HA.Restart.Info')
        return $lo
    }
}

<# 
.SYNOPSIS 
Finds VM associated with an HA Restart
.DESCRIPTION 
Returns an object of VM, Notes, NewHost, DateTime and FullMessage for each VM
affected by an HA Restart
.PARAMETER Days
Number of Days back (from current day) to check.  Defaults to 1 if not specified.
.PARAMETER MaxSamples
Number of Samples to check.  Defaults to 100000 if not specified.
.OUTPUTS 
[pscustomobject] SupSkiFun.HA.Restart.Info
.EXAMPLE 
Return HA Restart object into a variable, using default values: 
$MyVar = Get-HARestartInfo
.EXAMPLE 
Return HA Restart object into a variable, searching back 3 Days, with a maximum of 5000 samples: 
$MyVar = Get-HARestartInfo -Days 3 -MaxSamples 5000
#>
Function Get-HARestartInfo
{
    [CmdletBinding()]
    param 
    (
        [Int16] $Days = 1 ,
        [int32] $MaxSamples = 1000000
    )

    Begin
    {
        $zz = Get-VIEvent -MaxSamples $MaxSamples -Start (Get-Date).AddDays(-$Days) -Type Warning | 
            Where-Object -Property FullFormattedMessage -match "vSphere HA restarted" | 
                Select-Object -Property CreatedTime , FullFormattedMessage | 
                    Sort-Object -Property CreatedTime -Descending

        if (-not ($zz))
        {
            Write-Output "No results found"
            break
        }
    }

    Process
    {
        foreach ($z in $zz)
        {
            $lo = [NewVClass]::ParseInfo($z)
            $lo
        }

    }
}

<#
    Example output of $z.FullFormattedMessage above looks akin to:
    vSphere HA restarted virtual machine MyFine on host ESX-Server-O1.example.com in cluster PROD-17
#>