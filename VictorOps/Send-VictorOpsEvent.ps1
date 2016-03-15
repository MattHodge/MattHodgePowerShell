<#
.NOTES
   Written by Matthew Hodgkins.
.VERSION
   1.0.0 (11/19/2015)
.Synopsis
   Sends VictorOps events using the VictorOps REST API.
.DESCRIPTION
   Sends VictorOps events using the VictorOps REST API. More details on the API http://victorops.force.com/knowledgebase/articles/Integration/Alert-Ingestion-API-Documentation/
.EXAMPLE
  $sendEventSplat = @{
    ApiKey = '1111111-11111-111-111-111111'
    message_type = 'CRITICAL'
    RoutingKey = 'matt_test'
    entity_id = 'mattlaptop\some_service'
    monitoring_tool = 'powershell'
    state_message = 'testing a failed trigger'
  }
  
  Send-VictorOpsEvent @sendEventSplat

  Send a VictorOps event using a splat.
#>
function Send-VictorOpsEvent
{
    [CmdletBinding()]
    Param
    (
        # API Key for your VictorOps Account
        [Parameter(Mandatory=$true)]
        $ApiKey,

        # The Routing Key to use for sending the event
        [Parameter(Mandatory=$true)]
        $RoutingKey,

        # The API URI (excluding the API and Routing keys) - Default is 'https://alert.victorops.com/integrations/generic/20131114/alert'
        [Parameter(Mandatory=$false)]
        $BaseURI = 'https://alert.victorops.com/integrations/generic/20131114/alert',

        # The type of message to send VictorOps
        [Parameter(Mandatory=$true)]
        [ValidateSet('INFO', 'ACKNOWLEDGEMENT', 'CRITICAL', 'RECOVERY')]
        $message_type,

        # The name of alerting entity. If not provided, a random name will be assigned.
        [Parameter(Mandatory=$false)]
        [string]
        $entity_id,

        # The name of the monitoring system software (eg. nagios, icinga, sensu, etc.)
        [Parameter(Mandatory=$false)]
        [string]
        $monitoring_tool,

        # Any additional status information from the alert item.
        [Parameter(Mandatory=$false)]
        [string]
        $state_message,

        # Used within VictorOps to display a human-readable name for the entity.
        [Parameter(Mandatory=$false)]
        [string]
        $entity_display_name,

        # A hash table of any other key/value pairs you want sent to VictorOps
        [Parameter(Mandatory=$false)]
        [System.Collections.Hashtable]
        $KeyValueHash,

        # Enable Logging
        [Parameter(Mandatory=$false)]
        [string]
        $LogPath
    )

    $fullURI = "$($BaseURI)/$($ApiKey)/$($RoutingKey)"
    Write-Verbose "Full API URI Being Used: $($fullURI)"

    $body = @{
        message_type = $message_type
    }

    if ($PSBoundParameters.ContainsKey('entity_id')) {
        $body.entity_id = $entity_id
    }

    if ($PSBoundParameters.ContainsKey('monitoring_tool')) {
        $body.monitoring_tool = $monitoring_tool
    }

    if ($PSBoundParameters.ContainsKey('state_message')) {
        $body.state_message = $state_message
    }

    if ($PSBoundParameters.ContainsKey('entity_display_name')) {
        $body.entity_display_name = $entity_display_name
    }

    if ($PSBoundParameters.ContainsKey('KeyValueHash')) {
        $body += $KeyValueHash
    }
    if ($PSBoundParameters.ContainsKey('LogPath')) {
        $Logging = $true
    }

    $body_json = $body | ConvertTo-Json
    Write-Verbose $body_json

    if ($Logging)
    {
       New-Item -Path $LogPath -ItemType Directory -Force -ErrorAction SilentlyContinue
       $guid = [guid]::NewGuid().Guid

       # Create Json
       Set-Content -Path "$($LogPath)\$($guid)_json.txt" -Value $body_json
    }

    Invoke-WebRequest -UseBasicParsing -Uri $fullURI -Body $body_json -method Post -ContentType "application/json"
}
