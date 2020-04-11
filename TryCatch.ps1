Function TestE
{
    param ($Value)

    $d = "."
    if ($value.ToString().Contains($d))
    {
        $a = $value.Split(".")
        $a[0],($a[1][0..3] -join "") -join "."
    }
    else
    {
        $value
    }
}

<#

    PowerShell Equivalent of

    s = str(s)
    try:
        i = s.index(".")
    except:
        return s
    else:
        return (s[:(i+5)])


#>