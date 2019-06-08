<#
.SYNOPSIS
Retrieves detailed information from submitted tasks.
.DESCRIPTION
Retrieves detailed information from submitted tasks.  Returns an object of Name, Description,
ID, State, IsCancelable, PercentComplete, Start, Finish, UserName, EntityName, and EntityID.
.PARAMETER Task
Output from VMWare PowerCLI Get-Task.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Task]
.INPUTS
VMWare PowerCLI Task from Get-Task:
[VMware.VimAutomation.ViCore.Types.V1.Task]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.Task.Info
.EXAMPLE
Retrieve information from all running tasks, returning an object into a variable:
$MyVar = Get-Task -Status Running | Show-TaskInfo
.EXAMPLE
Retrieve information from all relocation tasks, returning an object into a variable:
$MyVar = Get-Task | Where-Object -Property Name -Match reloc | Show-TaskInfo
.EXAMPLE
Retrieve information from all recent tasks, returning an object into a variable:
$MyVar = Get-Task | Show-TaskInfo
#>
function Show-TaskInfo
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Task[]] $Task
    )

    Process
    {
        foreach ($t in $task)
        {
            $lo = [pscustomobject]@{
                Name = $t.Name
                Description = $t.Description
                ID = $t.Id
                State = $t.State
                IsCancelable = $t.IsCancelable
                PercentComplete = $t.PercentComplete
                Start = $t.StartTime
                Finish = $t.FinishTime
                UserName = $t.ExtensionData.Info.Reason.UserName
                EntityName = $t.ExtensionData.Info.EntityName
                EntityID = $t.ExtensionData.Info.Entity
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Task.Info')
            $lo
        }
    }
}