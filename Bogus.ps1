Class NewVClass
{
    static [pscustomobject] ParseInfo( [psobject] $line )
    {
        <#
            $y line - Regex in case of message change?
            $v line - Make ErrorVariable with actions?
            Method performs two actions?  Split it out?  Less efficient split out?
            Example output of $line.FullFormattedMessage above looks akin to:
            vSphere HA restarted virtual machine MyFine on host ESX-Server-O1.example.com in cluster PROD-17
        #>

        $y = $line.FullFormattedMessage.Substring(37).split()
        $v = Get-VM -Name $y[0].trim() -ErrorAction SilentlyContinue
        $lo = [pscustomobject]@{
            VM = $v.Name
            VMNotes = $v.Notes
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
Returns an object of VM, VMNotes, NewHost, DateTime, and FullMessage for VMs restarted via HA.
By default, searches back one day through 100,000 entires, for HA restart events from connected Virtual Center.
Can be adjusted via the Days and Entries Parameters.
.PARAMETER Days
Number of Days back (from current day) to check.  Defaults to 1.
.PARAMETER Entries
Number of Entries to check.  Defaults to 100000.
.OUTPUTS
[pscustomobject] SupSkiFun.HA.Restart.Info
.EXAMPLE
Retrieve information using default parameters:
Get-HARestartInfo
.EXAMPLE
Retrieve information for the past two days, returning object into a variable:
$MyVar = Get-HARestartInfo -Days 2
.EXAMPLE
Retrieve information searching through the first 200 entries, returning object into a variable:
$MyVar = Get-HARestartInfo -Entries 200
#>
Function Get-HARestartInfo
{
    [CmdletBinding()]
    param
    (
        [Int] $Days = 1 ,
        [int32] $MaxSamples = 100000
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