using module ~\Scripts\Underway\CliObj.psm1
$vv = get-vmhost *  
$arr = new-object System.Collections.ArrayList
foreach ($v in $vv) {[void] $arr.add([CliOBJ]::new($v.Name))}
foreach($a in $arr) {$a.getinfo()}
foreach($a in $arr) {$a.hasdata}
foreach($a in $arr) {$a.Info}
