$tagAss = Get-CisService -Name com.vmware.cis.tagging.tag_association
$tagCat = Get-CisService com.vmware.cis.tagging.category
$tagSvc = Get-CisService -Name com.vmware.cis.tagging.tag
$tagObj = $tagAss.help.list_attached_tags.object_id.create()
$tagObj.type=$vm.ExtensionData.moref.Type
$tagObj.id=$vm.ExtensionData.moref.Value
$tagIds = $tagAssocSvc.list_attached_tags($tagObj)

foreach ($tag in $tagIds)
{
    $tagA = $tagSvc.get($tag)
    $tagC = $tagCat.get($tagA.category_id)
    $lo = [pscustomobject]@{
        Entity = $VM.Name
        Name = $tagA.name
        Category = $tagC.name
        TagDescription = $tagA.description
        CategoryDescription = $tagC.description
        TagID = $tagA.id
        CategoryID = $tagC.id
    }
    $lo
}