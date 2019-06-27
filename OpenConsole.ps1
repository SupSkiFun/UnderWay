
<#
.SYNOPSIS
Opens a Console Window on a VM.
.DESCRIPTION
Opens a Console Window on a VM.  Was written as an alternative to Open-VMConsoleWindow when
Open-VMConsoleWindow was not functioning correctly after a Virtual Center upgrade.
.PARAMETER VM
Output from VMWare PowerCLI Get-VM.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.INPUTS
VMWare PowerCLI VM from Get-VM:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.EXAMPLE
Open a Console Window on a VM.
Get-VM -Name Server01 | Open-Console
.EXAMPLE
Open a Console Window on multiple VMs.
Get-VM -Name Test* | Open-Console
#>
Function Open-Console
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]] $VM
    )

    Begin
    {
        $modn = 'VMware.VimAutomation.Core'
        $modb = (Get-Module -Name $modn -ListAvailable)[0].ModuleBase
        $vexe = "$($modb)\net45\VMware Remote Console\vmrc.exe"
    }

    Process
    {
        foreach ($v in $vm)
        {
            $mkst = $vm.ExtensionData.AcquireMksTicket()
            $parm = "vmrc://$($vm.VMHost.Name):902/?mksticket=$($mkst.Ticket)&thumbprint=$($mkst.SslThumbPrint)&path=$($mkst.CfgFile)"
            & "$vexe" $parm
        }
    }
}