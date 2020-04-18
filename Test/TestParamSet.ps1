Function Test-It
{
    [CmdletBinding(DefaultParameterSetName = "p")]
    #[CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "p")]
        [switch] $Fixed,

        [Parameter(ParameterSetName = "s", ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [System.ServiceProcess.ServiceController[]] $Manual
    )

    Begin
    {

    }

    Process
    {
        Write-Output " Process Block Executing"
        if ($Manual)
        {
            Write-Output "If Processing"
            $info = $Manual
        }
        else
        {
            Write-Output "Else Processing"
            $info = Get-Service w*
        }

        foreach ($i in $info)
        {
            $i.Name
        }
    }
}

$a = (
    'one line' ,
    'another line',
    'third line'
)
#Test-It
#get-service s* |Test-It
#Test-It -Manual "more fun"
#Test-It -Fixed