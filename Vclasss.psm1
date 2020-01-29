class Vclasss
{
    static [pscustomobject] MakeGVSACObj ( [psobject] $obj , [string] $type )
    {
        $lo = [pscustomobject]@{
            Name = $obj.Name
            Enabled = $obj.ExtensionData.AlarmActionsEnabled
            Type = $type
        }
        $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.Alarm.Config')
        return $lo
    }
}