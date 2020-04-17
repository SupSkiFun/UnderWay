class GenFunctions
{
    hidden [string] Static GetSize ( [Int64] $num )
    {
        $size = switch ($num.ToString())
        {
            { $PSItem.Length -le 3  } {($PSItem.ToString())+" B" ; break }
            { $PSItem.Length -le 6  } {[math]::Round(($_/1kb),2).ToString()+" KB" ; break }
            { $PSItem.Length -le 9  } {[math]::Round(($_/1mb),2).ToString()+" MB" ; break }
            { $PSItem.Length -le 12 } {[math]::Round(($_/1gb),2).ToString()+" GB" ; break }
            { $PSItem.Length -le 15 } {[math]::Round(($_/1tb),2).ToString()+" TB" ; break }
            { $PSItem.Length -le 18 } {[math]::Round(($_/1tb),2).ToString()+" PB" ; break }
            default { $PSItem.ToString() }
        }
        return $size
    }

    [string] Static MakeInfo ([int64] $length)
    {
        $xfer = [GenFunctions]::GetSize($length)
        return $xfer
    }
}


$arr = (
    1 , 12 , 123 , 1234 , 12345 , 123456 , 1234567 , 12345678 , 123456789 , 1234567891 ,
    12345678912 ,  123456789123 ,  1234567891234 ,  12345678912345 ,  123456789123456 ,  1234567891234567 ,
    12345678912345678 , 123456789123456789 ,  1234567891234567891
)

foreach ($a in $arr)
{
    [GenFunctions]::MakeInfo($a)
}


<#
    Above Just tests calling a method from a method within a class.  Its purposely inefficient.
    Below Tests that GetSize is hidden by default, but can be IntelliSensed if you start to type it.
    $x = [GenFunctions]::
#>

