<#
.SYNOPSIS
Shows VMs with CD Drives Connected or configured to Start Connected
.DESCRIPTION
Returns an object of VM, Name, StartConnected, Connected, AllowGuestControl, IsoPath, HostDevice and RemoteDevice 
for submitted VMs that have a CD Drive Connected or configured to Start Connected.  Non-CD-Connected VMs are skipped. 
.PARAMETER VM
Output from VMWare PowerCLI Get-VM.  See Examples.
[VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl]
.INPUTS
VMWare PowerCLI VM from Get-VM:
[VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl]
.OUTPUTS
[pscustomobject] SupSkiFun.VM.ConnectedCD.Info
.EXAMPLE
Retrieve information for one VM:
Get-VM -Name System01 | Show-ConnectedCD
.EXAMPLE
Retrieve information for two VMs, returning object into a variable:
$myVar = Get-VM -Name System04 , System07 | Show-ConnectedCD
.EXAMPLE
Retrieve information for all VMs, returning object into a variable:
$MyVar = Get-VM -Name * | Show-ConnectedCD
#>

Function Show-ConnectedCD
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl[]]$VM
    )

    Process
    {
        $x = Get-CDDrive -VM $vm
        foreach ($y in $x)
        {
            if ($y.ConnectionState.StartConnected -or $y.ConnectionState.Connected)
            {
                $lo = [pscustomobject]@{
                    VM = $y.Parent.Name
                    Name = $y.Name
                    StartConnected = $y.ConnectionState.StartConnected
                    Connected = $y.ConnectionState.Connected
                    AllowGuestControl = $y.ConnectionState.AllowGuestControl
                    IsoPath = $y.isopath
                    HostDevice = $y.HostDevice
                    RemoteDevice = $y.RemoteDevice
                }
                $lo
                $lo.PSObject.TypeNames.Insert(0,'SupSkiFun.VM.ConnectedCD.Info')
            }
        }
    }
}