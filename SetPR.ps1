

<#
$rdms = (get-vm -Location $MyCLUS Get-HardDisk -DiskType "RawPhysical","RawVirtual").ScsiCanonicalName |select -unique

Loop thru all cluster vmhosts?


$tt = $x.storage.core.device.list.Invoke()


$tt.IsPerenniallyReserved -contains "false"
then do the loop.  If not just make the object then

object will be VmHost, Device, IsPereniallyReserved

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


So grab list ($rdms), grab list of devices ($tt) ,
{quick check first for any not perenially reserved?}
{also make a flag for whethre the list needs to be grabbed again.  $needRescan = $false
set to $true if SetPerenially reserved is needed / = False}
loop list looking for IsPerenniallyReserved -ne true, if -ne true
make $cible (see below, hopefully don't have to set shared* or detached*), then invoke ,
then grab list again (idf flag set) and report settings.


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
