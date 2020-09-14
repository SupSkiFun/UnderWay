class K8sAPI
{
    static $uria = 'apis/'

    static [psobject] GetApiInfo ( [uri] $mainurl )
    {
        $apis =  Invoke-RestMethod -Method Get -Uri $mainurl
        return $apis
    }

    static [psobject] GetResourceInfo ( [uri] $url )
    {
        $resq = Invoke-RestMethod -Method Get -Uri $url
        $resi = $resq.resources.Where({$_.name -notmatch "/"})
        return $resi
    }

    static [pscustomobject] MakeObj (
            [string] $nom ,
            [psobject] $grv ,
            [psobject] $res ,
            [string] $prv
        )
    {
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
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Kubernetes.API.Info')
        return $lo
    }
}

<#
.SYNOPSIS
Produces an object of Kubernetes API Groups and Resources.
.DESCRIPTION
Produces an object of Kubernetes API Groups and Resources, via proxied connection.  See Notes and Examples.
.PARAMETER Uri
URI that has been proxied via kubectl.
.INPUTS
URI that has been proxied via kubectl.
.OUTPUTS
pscustombobject SupSkiFun.Kubernetes.API.Info
.NOTES
NEED
INFO
HERE
.EXAMPLE
NEED
INFO
HERE
.EXAMPLE
NEED
INFO
HERE
#>

Function Get-K8sAPIInfo
{
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [Uri] $Uri
    )

    Begin
    {
        if ( ([uri] $uri).IsAbsoluteUri -eq $false )
        {
            Write-Output "Terminating.  Non-valid URL detected.  Submitted URL:  $uri"
            break
        }

        $mainurl = ($($Uri.AbsoluteUri)+$([K8sAPI]::uria))
    }

    Process
    {
        $apis = [K8sAPI]::GetApiInfo($mainurl)

        foreach ($api in $apis.groups)
        {
            $prv = $api.preferredVersion.groupVersion
            $grvs = $api.versions
            foreach ($grv in $grvs)
            {
                $url = $($mainurl)+$($grv.groupVersion)
                $resi = [K8sAPI]::GetResourceInfo($url)
                foreach ($res in $resi)
                {
                    $lo = [K8sAPI]::MakeObj($api.name , $grv , $res , $prv)
                    $lo
                }
            }
        }
    }
}


#  [uri]::new("https://127.0.0.1:8888")
#  Make a default view with just a subset of properties
#  $baseurl = 'http://127.0.0.1:8888/'   

<#
    Error Message:
        PreferredVersion = ( $prv -eq $gvv ? $true : $false )
        Unexpected token '?' in expression or statement.
#>
