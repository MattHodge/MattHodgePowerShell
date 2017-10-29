<#
.Synopsis
   Allows running processes and capturing output.
.DESCRIPTION
   Allows running processes and capturing output.
.EXAMPLE
   Start-ProcessWithCapture -FilePath 'git' -ArgumentList 'pull' -WorkingDirectory $Path -ErrorAction Stop
#>
function Start-ProcessWithCapture
{
    [CmdletBinding()]
    Param
    (
        # File Path of the Process to Execute
        [Parameter(Mandatory=$true)]
        [string]
        $FilePath,

        # Argument List for Process
        [Parameter(Mandatory=$true)]
        [string]
        $ArgumentList,

        # Argument List for Process
        [Parameter(Mandatory=$false)]
        [string]
        $WorkingDirectory
    )

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo

    if ($PSBoundParameters.ContainsKey('WorkingDirectory'))
    {
        $pinfo.WorkingDirectory = $WorkingDirectory
    }

    $pinfo.FileName = $FilePath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $ArgumentList
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()

    $output = @{}
    $output.stdout = $stdout
    $output.stderr = $stderr
    $output.exitcode = $p.ExitCode

    return $output
}
