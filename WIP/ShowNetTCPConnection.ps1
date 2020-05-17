#Needs Error handling / Parameters / Testing / Code Formatiing
$pp = Get-NetTCPConnection -State Established |? {$_.RemoteAddress -notmatch "^127" -and $_.RemoteAddress -notmatch "::1" }
$op = $pp.OwningProcess | Select -Unique
$qp = Get-Process -PID $op | Select Id , Name , Description, Company, Path

$uri = 'http://api.ipapi.com/'  # Keep Trailing Slash - code around that
#$cle = 'PUT API Key Here'
$cle = Get-Content apikey.txt
$headers = @{
	access_key = $cle
	output = 'json'
	fields = 'ip,country_name,region_name,city'  # Intentionally no Space
}

Function GetIpInfo
{
    param ($IP)
    # Need Error Handling in this
    $r2 = Invoke-RestMethod -Uri ($uri+$ip) -body $headers
    $r2
}

foreach ($p in $pp)
{
    # IF NOT $rp MAKE A NO DATA VALUE?  oR JUST LEAVE?
    $rp = $qp.Where({$p.OwningProcess.ToString() -eq $_.id.ToString()})
    $ip = $p.RemoteAddress
    $ipinfo = GetIpInfo -IP $ip

    $r2 = Invoke-RestMethod -Uri ($uri+$ip) -body $headers
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
