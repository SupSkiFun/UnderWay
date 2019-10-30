<#
.SYNOPSIS
Enables or disables the WBEN service on VMHost(s).
.DESCRIPTION
Enables or disables the WBEN service on VMHost(s).  See Examples.
Returns no output.  Confirm settings with Get-WBEMState.
.PARAMETER VMHost
Output from VMWare PowerCLI Get-VMHost. See Examples.
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.PARAMETER Enabled
Switch. If specified, enables the WBEM service.
.PARAMETER Disabled
Switch. If specified, disables the WBEM service.
.INPUTS
VMWare PowerCLI VMHost from Get-VMHost:
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
.EXAMPLE
Enables the WBEM service on two VMHosts:
Get-VMHost -Name ESX01 , ESX02 | Set-WBEMState -Enabled
.EXAMPLE
Disables the WBEM service on two VMHosts:
Get-VMHost -Name ESX01 , ESX02 | Set-WBEMState -Disabled
.LINK
Get-WBEMState
#>

Function Set-WBEMState
{
    [CmdletBinding(SupportsShouldProcess = $true , ConfirmImpact = 'high')]

    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] $VMHost,

        [Parameter(ParameterSetName = "Enabled")]
        [switch] $Enabled,

        [Parameter(ParameterSetName = "Disabled")]
        [switch] $Disabled
    )

    Begin
    {
        <#
            $State maps switch to boolean.  $Setting clarifies Should Process message.
        #>
        If ($Enabled)
        {
            $State = $true
            $Setting = "Enabled"
        }
        elseif ($Disabled)
        {
            $State = $false
            $Setting = "Disabled"
        }
    }

    Process
    {
        ForEach ($vmh in $VMHost)
        {
            if ($pscmdlet.ShouldProcess("$vmh to $Setting"))
            {
                $x2 = Get-EsxCli -V2 -VMHost $vmh
                $y2 = $x2.system.wbem.set.CreateArgs()
                $y2.enable = $State
                [void] $x2.system.wbem.set.Invoke($y2)
            }
        }
    }
}