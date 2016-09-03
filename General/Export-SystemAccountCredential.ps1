#Requires -RunAsAdministrator

<#
.Synopsis
   Generates a Credential .xml file to be used with Import-Clixml
.DESCRIPTION
   Creates a credential .xml file exported from Export-Clixml from the SYSTEM account. This is useful when running scripts or services under the SYSTEM account that requires credentials.
.EXAMPLE
   $cred = Get-Credential
   Export-SystemAccountCredential -Credential $cred -Path 'C:\mycreds' -Verbose
#>
function Export-SystemAccountCredential
{
    [CmdletBinding()]
    Param
    (
        # Credential to export under the SYSTEM account.
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,

        # Path to store export the credential to
        [string]
        $Path
    )

    if (!(Test-Path -Path $Path))
    {
      New-Item -Path $Path -Type Directory -Force
    }

    $schTaskName = 'CreateCredential'
    $scriptName = "$($schTaskName).ps1"

    # define the scheduled task
    [scriptblock]$schTaskScript = {
        # take the params passed to the script
        param (
            $Username,
            $Password,
            $Path
        )
        $npipeClient = new-object System.IO.Pipes.NamedPipeClientStream($env:ComputerName, 'task', [System.IO.Pipes.PipeDirection]::Out)
        $npipeclient.connect()
        $pipeWriter = new-object System.IO.StreamWriter($npipeClient)
        $pipeWriter.AutoFlush = $true

        # convert to creds block
        $pw = $Password | ConvertTo-SecureString -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($Username,$pw)

        $pipewriter.writeline("Generating Credential for $($Credential.Username)")
        $Credential | Export-Clixml -Path "$($Path)\$($Credential.Username)_credential.xml"

        $pipewriter.writeline("SCHEDULED_TASK_DONE: $LastExitCode")
        $pipewriter.dispose()
        $npipeclient.dispose()
    }.GetNewClosure()

    Write-Verbose "Creating Script File"
    $scriptPath = Join-Path $env:TEMP $scriptName
    Set-Content -Path $scriptPath -Value $schTaskScript -Force

    Write-Verbose "Creating Scheduled Task"
    # create scheduled task with params that the script will need
    Start-Process -FilePath 'schtasks' -ArgumentList "/create /tn $($schTaskName) /ru SYSTEM /sc once /st 00:00 /sd 01/01/2005 /f /tr ""powershell -executionpolicy unrestricted -File '$($scriptPath)' $($Credential.Username) $($Credential.GetNetworkCredential().Password) $Path""" -Wait -NoNewWindow

    Start-Sleep -Seconds 5

    Write-Verbose "Running Scheduled Task"
    try
    {
        $npipeServer = new-object System.IO.Pipes.NamedPipeServerStream('task', [System.IO.Pipes.PipeDirection]::In)
        $pipeReader = new-object System.IO.StreamReader($npipeServer)
        Start-Process -FilePath 'schtasks' -ArgumentList "/run /tn ""$($schTaskName)"""
        $npipeserver.waitforconnection()
        $host.ui.writeline('Connected to the scheduled task.')
        while ($npipeserver.IsConnected)
        {
            $output = $pipereader.ReadLine()
            if ($output -like 'SCHEDULED_TASK_DONE:*')
            {
                $exit_code = ($output -replace 'SCHEDULED_TASK_DONE:').trim()
            }
            else
            {
                $host.ui.WriteLine($output)
            }
        }
    }
    catch
    {
        if ($_.Exception.Message)
        {
            Write-Error $_.Exception.Message
        }

        if ($_.Exception.ItemName)
        {
            Write-Error $_.Exception.ItemName
        }

        if ($_.CategoryInfo.Reason)
        {
            Write-Error $_.CategoryInfo.Reason
        }

        if ($_.CategoryInfo.Category)
        {
            Write-Error $_.CategoryInfo.Category.ToString()
        }

        if ($_.CategoryInfo.Activity)
        {
            Write-Error $_.CategoryInfo.Activity
        }
    }
    finally
    {
        $pipereader.dispose()
        $npipeserver.dispose()

        Write-Verbose "Removing Scheduled Task"
        Start-Process -FilePath 'schtasks' -ArgumentList "/Delete /TN $($schTaskName) /F"
    }
}
