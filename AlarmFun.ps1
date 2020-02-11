$alarmMgr = Get-View AlarmManager
 
$filter = New-Object VMware.Vim.AlarmFilterSpec
$filter.Status += [VMware.Vim.ManagedEntityStatus]::red
$filter.TypeEntity = [VMware.Vim.AlarmFilterSpecAlarmTypeByEntity]::entityTypeVm
$filter.TypeTrigger = [vmware.vim.AlarmFilterSpecAlarmTypeByTrigger]::triggerTypeEvent

$alarmMgr.ClearTriggeredAlarms($filter)