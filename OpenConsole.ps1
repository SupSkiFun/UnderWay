<#
.SYNOPSIS
Opens a VM Console
.DESCRIPTION
Opens a VM Console.  Created when Open-VMConsoleWindow was failing.
.PARAMETER VM
Output from VMWare PowerCLI Get-VM.  See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
.EXAMPLE
Open a console session:
Get-VM -Name SYS01 | Open-Console
.INPUTS
VMWare PowerCLI VM from Get-VM:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
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