function Test-Object
{
    [cmdletbinding()]
    [Alias("to")]

    param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "Pipe DataStore Object(s) from Get-Datastore")]
        [Alias("DataStore")]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]$Name
    )

    Begin
    {
        $j = {$this | ConvertTo-Json -Depth 4}
    }

    Process
    {
        if(!$name)
        {
            Write-Output "Input Object Required. For more information execute: help gdpf -full"
            break
        }

        foreach ($info in $name)
        {
            <#
                Note - this returns to pipe once complete.  Need to test if each item is piped
                with $lo in the for loop block
            #>
            $lo=[pscustomobject]@{
                #PSTypeName = 'SupSkiFun.Test.Object'
                Name = $info.name
                URL = $info.ExtensionData.info.url.Split("/")[5]
                PerCentFree = [math]::Round((($info.FreeSpaceGB / $info.CapacityGB)*100),2)
                GBFree = [math]::Round($info.FreeSpaceGB, 2)
                GBUsed = [math]::Round(($info.CapacityGB - $info.FreeSpaceGB),2)
                GBTotal = [math]::Round($info.CapacityGB, 2)
            }
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Test.Object')
        Update-TypeData -TypeName "SupSkiFun.Test.Object" -MemberType ScriptProperty -MemberName "Json" -Value $j -Force
        $lo
    }
}