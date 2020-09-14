class K8sAPI
{
    static $uria = '/apis/'

    [psobject] GetApiInfo ( [uri] $mainurl )
    {
        $apis =  Invoke-RestMethod -Method Get -Uri $mainurl
        return $apis
    }

    [psobject] GetResourceInfo ( [uri] $url )
    {
        $resq = Invoke-RestMethod -Method Get -Uri $url
        $resi = $resq.resources.Where({$_.name -notmatch "/"})
        return $resi
    }

    [pscustomobject] MakeObj ( $nom, $grv, $res, $prv )
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
        [uri] $Uri
    )

    Begin
    {
        #$uria = "/apis/"
        $reqver = 7
        $actver = $PSVersionTable.PSVersion.Major
        $message = "PowerShell Version"

        if ( $reqver -ne $actver )
        {
            Write-Output "Terminating.  $message $reqver required.  $message $actver detected."
            break
        }

        $mainurl = ($Uri+$([K8sAPI]::uria))
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

#  Ternary operator ? <if-true> : <if-false>
#  Ports 1024-65535
#  Make URL a class static variable / property?
#  Check for PowerShell 7
#  [uri]::new("https://127.0.0.1:8888")
#  Make a default view with just a subset of properties
#  Make parameter sets?  port and uri?  Or just port on localhost?
#  $baseurl = 'http://127.0.0.1:8888/'    # Needs to be a parameter ; reg exp or maybe there is .NET type  [httpurl]
#  $apis = GetApiInfo
#  ProcessInfo($apis)
