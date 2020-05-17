<#
.SYNOPSIS
Produces an object of Microsoft Scheduled Task Information
.DESCRIPTION
Produces an object of Name, Description, State, UserID, Author, Enabled, AllowDemandStart,
Command, Arguments, WorkingDirectory, TriggerEnabled, and StartTime.
.PARAMETER Task
Microsoft scheduled task.  [MSFT_ScheduledTask]  See Examples.
.INPUTS
Microsoft scheduled task.  [MSFT_ScheduledTask]
.OUTPUTS
pscustombobject SupSkiFun.Scheduled.Task.Info
.EXAMPLE
Returns an object of a specific Microsoft Scheduled Task Information into a variable:
$MyObj =  Get-ScheduledTask -TaskName MyTask |  Show-ScheduledTaskInfo
.EXAMPLE
Returns an object of all Microsoft Scheduled Task Information into a variable:
$MyObj = Get-ScheduledTask -TaskName * | Show-ScheduledTaskInfo
#>

Function Show-ScheduledTaskInfo
{
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [MSFT_ScheduledTask] $Task
    )

    Process
    {
        foreach ($t in $task)
        {
            $lo = [PSCustomObject]@{
                Name = $t.TaskName
                Description = $t.Description
                State = $t.State
                UserID = $t.Principal.UserId
                Author = $t.Author
                Enabled = $t.Settings.Enabled
                AllowDemandStart = $t.Settings.AllowDemandState
                Command = $t.Actions.Execute
                Arguments = $t.Actions.Arguments
                WorkingDirectory = $t.Actions.WorkingDirectory
                TriggerEnabled = $t.Triggers.Enabled
                StartTime = $t.Triggers.StartBoundary
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Scheduled.Task.Info')
            $lo
        }
    }
}

<#
Test the plain enabled and trigger enabled to verify
TypeName: Microsoft.Management.Infrastructure.CimInstance#Root/Microsoft/Windows/TaskScheduler/MSFT_ScheduledTask
#>