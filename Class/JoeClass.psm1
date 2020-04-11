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
