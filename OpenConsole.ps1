
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
        $mod1 = 'VMware.VimAutomation.Core'
        $mod2 = $mod2 = Get-Module -Name $($mod1) -ListAvailable
        $vexe = "$($mod2.ModuleBase)\net45\VMware Remote Console\vmrc.exe"
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

#https://communities.vmware.com/message/2812543#2812543