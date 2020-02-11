$almg = Get-View AlarmManager
$filt = [VMware.Vim.AlarmFilterSpec]::new()

$filt.Status += [VMware.Vim.ManagedEntityStatus]::red
$filt.TypeEntity = [VMware.Vim.AlarmFilterSpecAlarmTypeByEntity]::entityTypeVm
$filt.TypeTrigger = [vmware.vim.AlarmFilterSpecAlarmTypeByTrigger]::triggerTypeEvent

$alarmMgr.ClearTriggeredAlarms($filter)

<# 
https://communities.vmware.com/thread/623890

$alarmMgr = Get-View AlarmManager
 
$filter = New-Object VMware.Vim.AlarmFilterSpec
$filter.Status += [VMware.Vim.ManagedEntityStatus]::red
$filter.TypeEntity = [VMware.Vim.AlarmFilterSpecAlarmTypeByEntity]::entityTypeVm
$filter.TypeTrigger = [vmware.vim.AlarmFilterSpecAlarmTypeByTrigger]::triggerTypeEvent

$alarmMgr.ClearTriggeredAlarms($filter)


#>