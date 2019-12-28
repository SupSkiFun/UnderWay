Class NewVClass
{
    static [pscustomobject] ParseInfo( [psobject] $line )
    {
        <#
            $y line - Regex in case of message change?
            $v line - Make ErrorVariable with actions?
            Method performs two actions?  Split it out?  Less efficient split out?
        #>

        $y = $line.FullFormattedMessage.Substring(37).split()
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
Retrieves HA restart events.
.DESCRIPTION
Returns an object of VM, Notes, NewHost, DateTime, and FullMessage for VMs restarted via HA.
By default, searches back one day through 100,000 entires, for HA restart events from connected Virtual Center.
Can be adjusted via the Days and Entries Parameters.
.PARAMETER Days
Number of days back to search.  Defaults to 1.
.PARAMETER Entries
Number of entries to parse.  Defaults to 100,000.
.OUTPUTS
[PSCustomObject] SupSkiFun.HA.Restart.Info
.EXAMPLE
Retrieve information using default parameters:
Get-HARestartInfo
.EXAMPLE
Retrieve information for the past two days, returning object into a variable:
$MyVar = Get-HARestartInfo -Days 2
.EXAMPLE
Retrieve information searching through the first 200 entries, returning object into a variable:
$MyVar = Get-HARestartInfo -Entries 2
#>
Function Get-HARestartInfo
{
    [cmdletbinding()]
    Param
    (
        [int] $Days = 1 ,
        [int32] $Entries = 100000
    )

    Begin
    {
        $msg = "vSphere HA restarted"
        $zz = Get-VIEvent -MaxSamples $Entries -Start (Get-Date).AddDays(-$Days) -Type Warning |
            Where-Object -Property FullFormattedMessage -match $msg |
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