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
    param( $nom, $grv, $res, $prv )

    $gvv = $grv.groupVersion

    $lo = [PSCustomObject]@{
        GroupName = $nom
        GroupVersion = $gvv
        Version = $grv.version
        PreferredVersion = ( $prv -eq $gvv ? $true : $false )
        ResourceName = $res.name
        ResourceKind = $res.kind
        ShortName = $res.shortNames
        NameSpaced = $res.namespaced
    }
    return $lo
}

Function ProcessInfo
{
    param($apis)

    foreach ($api in $apis.groups)
    {
        $prv = $api.preferredVersion.groupVersion
        $grvs = $api.versions
        foreach ($grv in $grvs)
        {
            $url = $($mainurl)+$($grv.groupVersion)
            $resi = GetResourceInfo($url)
            foreach ($res in $resi)
            {
                $lo = MakeObj -nom $api.name -grv $grv -res $res -prv $prv
                $lo
            }
        }
    }
}

# Ternary operator ? <if-true> : <if-false>

# Check for PowerShell 7
#  [uri]::new("https://127.0.0.1:8888")
$baseurl = 'http://127.0.0.1:8888/'    # Needs to be a parameter ; reg exp or maybe there is .NET type  [httpurl]
$apis = GetApiInfo
ProcessInfo($apis)
