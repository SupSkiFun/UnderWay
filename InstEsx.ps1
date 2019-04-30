<#
.SYNOPSIS
Installs an image profile from a local depot onto a VMHost with ESXi already installed.
.DESCRIPTION
Replaces the installed image with the new image profile.  Will result in the loss of installed VIBs that don't match the profile.
System Should be in Maintenance Mode.  Use DryRun to test.  Read / Evaluate the returned object.  See Examples.
Returns an object of HostName, Message, RebootRequired, VIBSInstalled, VIBSRemoved, and VIBSSkipped.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.PARAMETER Depot
Full local server file path pointing to an offline bundle .zip file.  Example:
/vmfs/volumes/Datastore/Path/6.7/VMware-ESXi-6.7.0-Update1-11675023-HPE-Gen9plus-670.U1.10.4.0.19-Apr2019-depot.zip
.PARAMETER ImageProfile
Image Profile to Install.  Often found within <id>  </id> of metadata/vmware.xml in the *depot.zip file.
Example:  HPE-ESXi-6.7.0-Update1-Gen9plus-670.U1.10.4.0.19
.PARAMETER DryRun
If specified, performs a dry-run only. Reports the VIB-level operations that would be performed, but changes nothing.
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.OUTPUTS
[PSCUSTOMOBJECT] SupSkiFun.ESXi.Info
.EXAMPLE
Perform a DryRun (Test) Install of an image onto one VMHost, returning an object into a variable:
$d = '/vmfs/volumes/Datastore/Path/6.7/VMware-ESXi-6.7.0-Update1-11675023-HPE-Gen9plus-670.U1.10.4.0.19-Apr2019-depot.zip'
$p = 'HPE-ESXi-6.7.0-Update1-Gen9plus-670.U1.10.4.0.19'
$MyVar = Get-VMHost -Name ESX01 | Install-ESXi -DryRun
.EXAMPLE
Install image onto one VMHost, returning an object into a variable:
$d = '/vmfs/volumes/Datastore/Path/6.7/VMware-ESXi-6.7.0-Update1-11675023-HPE-Gen9plus-670.U1.10.4.0.19-Apr2019-depot.zip'
$p = 'HPE-ESXi-6.7.0-Update1-Gen9plus-670.U1.10.4.0.19'
$MyVar = Get-VMHost -Name ESX02 | Install-ESXi
.EXAMPLE
Install image onto two VMHosts, returning an object into a variable:
$d = '/vmfs/volumes/Datastore/Path/6.7/VMware-ESXi-6.7.0-Update1-11675023-HPE-Gen9plus-670.U1.10.4.0.19-Apr2019-depot.zip'
$p = 'HPE-ESXi-6.7.0-Update1-Gen9plus-670.U1.10.4.0.19'
$MyVar = Get-VMHost -Name ESX03 , ESX04 | Install-ESXi
#>
function Install-ESXi
{
    [CmdletBinding(SupportsShouldProcess = $true , ConfirmImpact = 'high')]

    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost,

        [Parameter(Mandatory = $true)]
        [string] $Depot,

        [Parameter(Mandatory = $true)]
        [string] $ImageProfile,

        [switch] $DryRun
    )

    Process
    {
        Function MakeObj
        {
            param($vhdata,$resdata)

            $lo = [PSCustomObject]@{
                HostName = $vhdata
                Message = $resdata.Message
                RebootRequired = $resdata.RebootRequired
                VIBsInstalled = $resdata.VIBsInstalled
                VIBsRemoved = $resdata.VIBsRemoved
                VIBsSkipped = $resdata.VIBsSkipped
            }
            $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.ESXi.Info')
            $lo
        }

        foreach ($vmh in $VMHost)
        {
            if($PSCmdlet.ShouldProcess("$vmh using $imageprofile"))
            {
                $xcli = Get-EsxCli -v2 -VMHost $vmh
                $hash = $xcli.software.profile.install.CreateArgs()
                $hash.depot = $depot
                $hash.profile = $imageprofile
                $hash.oktoremove = $true
                if ($dryrun)
                {
                    $hash.dryrun = $true
                }
                $resp = $xcli.software.profile.install.Invoke($hash)
                MakeObj -vhdata $vmh.Name -resdata $resp
            }
        }
    }
}


<#
$x = Get-EsxCli -v2  -VMHost $vmh
$z = $x.software.profile.install.CreateArgs()
$z.dryrun=$true # Make it a switch parameter
$z.oktoremove=$true  # Make it a switch parameter
$z.depot='/vmfs/volumes/Datastore/Path/6.7/VMware-ESXi-6.7.0-Update1-11675023-HPE-Gen9plus-670.U1.10.4.0.19-Apr2019-depot.zip'
$z.profile='HPE-ESXi-6.7.0-Update1-Gen9plus-670.U1.10.4.0.19'
$x.software.profile.install.Invoke($z)
$res1 = $x.software.profile.install.Invoke($z)
$z.dryrun=$false
$res3 = $x.software.profile.install.Invoke($z)


Message        : The update completed successfully, but the system needs to be rebooted for the changes to be effective.
RebootRequired : true
VIBsInstalled  : {VMware_bootbank_esx-base_6.7.0-1.39.11675023, VMware_bootbank_esx-update_6.7.0-1.39.11675023, VMware_bootbank_vsan_6.7.0-1.39.11399593,
                 VMware_bootbank_vsanhealth_6.7.0-1.39.11399595}
VIBsRemoved    : {NetApp_bootbank_NetAppNasPlugin_1.1.2-3, VMware_bootbank_esx-base_6.7.0-1.41.13004448, VMware_bootbank_esx-update_6.7.0-1.41.13004448,
                 VMware_bootbank_vmware-fdm_6.7.0-11726888...}
VIBsSkipped    : {Avago_bootbank_lsi-mr3_7.706.08.00-1OEM.670.0.0.8169922, BCM_bootbank_bnxtnet_212.0.119.0-1OEM.670.0.0.8169922,
                 BCM_bootbank_bnxtroce_212.0.114.0-1OEM.670.0.0.8169922, ELX_bootbank_elx-esx-libelxima-8169922.so_12.0.1188.0-03...}




Message: EsxCLI.CLIFault.summary;
InnerText:  [ValueError] Only server local file path is supported for offline bundles.

So



Message        : Dryrun only, host not changed. The following installers will be applied: [BootBankInstaller]
RebootRequired : true
VIBsInstalled  : {VMware_bootbank_esx-base_6.7.0-1.39.11675023, VMware_bootbank_esx-update_6.7.0-1.39.11675023, VMware_bootbank_vsan_6.7.0-1.39.11399593,
                 VMware_bootbank_vsanhealth_6.7.0-1.39.11399595}
VIBsRemoved    : {NetApp_bootbank_NetAppNasPlugin_1.1.2-3, VMware_bootbank_esx-base_6.7.0-1.41.13004448, VMware_bootbank_esx-update_6.7.0-1.41.13004448,
                 VMware_bootbank_vmware-fdm_6.7.0-11726888...}
VIBsSkipped    : {Avago_bootbank_lsi-mr3_7.706.08.00-1OEM.670.0.0.8169922, BCM_bootbank_bnxtnet_212.0.119.0-1OEM.670.0.0.8169922,
                 BCM_bootbank_bnxtroce_212.0.114.0-1OEM.670.0.0.8169922, ELX_bootbank_elx-esx-libelxima-8169922.so_12.0.1188.0-03...}


                 #>