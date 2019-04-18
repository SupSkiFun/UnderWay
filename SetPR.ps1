

<#
$rdms = (get-vm -Location $MyCLUS Get-HardDisk -DiskType "RawPhysical","RawVirtual").ScsiCanonicalName |select -unique
$tt = $x.storage.core.device.list.Invoke()
if (($tt | ? device -match $rdms[12]).IsPerenniallyReserved -eq "true") {"yes"} else {"no"}

foreach ($rdm in $rdms) {
>>
>> $a = $tt |? device -match $rdm
>> if ($a.IsPerenniallyReserved -match "true")
>> {$a.Device, $a.DefsPath, $a.IsPerenniallyReserved}
>> }

$z = $x.storage.core.device.setconfig.CreateArgs()
$z

Name                           Value
----                           -----
sharedclusterwide              Unset, ([boolean], optional)
device                         Unset, ([string])
perenniallyreserved            Unset, ([boolean], optional)
detached                       Unset, ([boolean], optional)

$x.storage.core.device.setconfig.Invoke($cible)


So grab list ($rdms), grab list of devices ($tt) loop list looking for IsPerenniallyReserved -ne true, if -ne true
make $cible (see below, hopefully don't have to set shared* or detached*), then invoke , then grab list again and report settings.


 $cible = @{
 pereniallyreserved = "true"  ;
 device = "looped name"
 }
 $cible

Name                           Value
----                           -----
device                         looped name
pereniallyreserved             true

#>
