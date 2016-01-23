<#
.Synopsis
    Gets service status for Hubot Script.
.DESCRIPTION
    Gets service status for Hubot Script.
.EXAMPLE
    Get-ServiceHubot -Name dhcp
#>
function Get-ServiceHubot
{
    [CmdletBinding()]
    Param
    (
        # Name of the Service
        [Parameter(Mandatory=$true)]
        $Name
    )

    $result = @{}
                
    try
    {
        $service = Get-Service -Name $Name -ErrorAction Stop
        $result.output = "Service $($service.Name) (*$($service.DisplayName)*) is currently ``$($service.Status.ToString())``."
        $result.success = $true
    }
    catch
    {
        $result.output = "Service $($Name) does not exist on this server."
        $result.success = $false
    }

    return $result | ConvertTo-Json
}