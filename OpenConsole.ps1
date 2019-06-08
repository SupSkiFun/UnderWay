
function Open-Console
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