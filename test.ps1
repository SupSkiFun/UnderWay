Function Test-Param
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false , ValueFromPipeline = $false)]
        [Switch]$Refresh
    )


    Begin
    {
        "Value of $refresh in begin block"
        "Value of $wwwwwww in begin block"
    }

    Process
    {
        "Value of $refresh in process block"
        "Value of $wwwwwww in process block"
        $wwwwwww = $null
        "Second Value of $wwwwwww in process block"
        
    }
    End
    {
        "Value of $wwwwwww in end block"
    }
}