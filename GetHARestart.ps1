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
    TODO:  
        Paramaterize the Begin statement ZZ  MaxSamples -Start
        Add Help
        Split out MakeObj and ParseInfo?

#>

Function Get-HARestartInfo
{
    Begin
    {
        $zz = Get-VIEvent -MaxSamples 100000 -Start (Get-Date).AddDays(-1) -Type Warning | 
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