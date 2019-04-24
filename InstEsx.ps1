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
<#

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