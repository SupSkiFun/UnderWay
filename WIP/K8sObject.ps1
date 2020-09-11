Function GetApiInfo
{
    $script:mainurl = ($baseurl+"/apis/")
    $apis =  Invoke-RestMethod -Method Get -Uri $mainurl
    return $apis
}

Function GetResourceInfo
{
    param($url)
    $resq = Invoke-RestMethod -Method Get -Uri $url
    $resi = $resq.resources.Where({$_.name -notmatch "/"})
    return $resi
}

Function MakeObj
{
    param($api , $res)
    $lo = [PSCustomObject]@{
        ApiGroupName = $api.name
        ApiGroupVersion = $api.preferredVersion.groupVersion
        ApiVersion = $api.preferredVersion.version
        ApiResourceName = $res.name
        ResourceKind = $res.kind
        ResourceShortNames = $res.shortNames
    }
    return $lo
}

Function ProcessInfo
{
    param($apis)
    foreach ($api in $apis.groups)
    {
        $url = $($mainurl)+$($api.preferredVersion.groupVersion)
        $resi = GetResourceInfo($url)
        foreach ($res in $resi)
        {
            $lo = MakeObj -api $api -res $res
        }
        $lo    
    }
}

$baseurl = 'http://127.0.0.1:8888/'    # Needs to be a parameter ; reg exp or maybe there is .NET type  [httpurl]
$apis = GetApiInfo
ProcessInfo($apis)
