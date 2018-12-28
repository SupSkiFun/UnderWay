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
    }

    Process
    {
        "Value of $refresh in process block"
        
    }
}