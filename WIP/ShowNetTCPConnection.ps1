#Needs Error handling / Parameters / Testing / Code Formatiing

Function GetProcInfo
{
    $script:pp = Get-NetTCPConnection -State Established |
        Where-Object {$_.RemoteAddress -notmatch "^127" -and $_.RemoteAddress -notmatch "::1" }
    $op = $pp.OwningProcess |
        Select-Object -Unique
    $script:qp = Get-Process -PID $op |
        Select-Object -Property Id , Name , Description , Company , Path
}

Function SetParams
{
    #$cle = 'PUT API Key Here'  Or ...
    $cle = Get-Content apikey.txt -ErrorAction SilentlyContinue
    if ($cle)
    {
        $script:uri = 'http://api.ipapi.com/'  # Keep Trailing Slash - code around that
        $script:body = @{
            access_key = $cle
            output = 'json'
            fields = 'ip,country_name,region_name,city'  # Intentionally no Space
        }
    }
    else
    {
        $script:cleOK = $false
    }
}

Function GetIpInfo
{
    param ($IP)
    $IRP = @{
        Uri = ($uri+$ip)
        Body = $body
        Method = "Get"
        ErrorAction = "SilentlyContinue"
        ErrorVariable = "err"
    }
    $r2 = Invoke-RestMethod @IRP
    if ($err)
    {
        $msg = "Error obtaining IP Info from API"
        $msg
    }
    else
    {
        $r2
    }
}


Function MakeObj
{
    foreach ($p in $pp)
    {
        # IF NOT $rp MAKE A NO DATA VALUE?  OR JUST LEAVE?
        $rp = $qp.Where({$p.OwningProcess.ToString() -eq $_.id.ToString()})
        $ip = $p.RemoteAddress
        if ($cleOK)
        {
            $ipinfo = GetIpInfo -IP $ip
        }
        else
        {
            $ipinfo = "API Key Not Found"
        }
        $lo = [pscustomobject]@{
            LocalAddress = $p.LocalAddress
            LocalPort = $p.LocalPort
            RemoteAddress = $ip
            RemotePort = $p.RemotePort
            Setting = $p.AppliedSetting.ToString()
            Process = $rp.id
            ProcessName = $rp.Name
            Description = $rp.Description
            Company = $rp.Company
            Path = $rp.Path
            Locale = $ipinfo
        }
        $lo
        $rp = $null
    }
}

GetProcInfo
SetParams
MakeObj
