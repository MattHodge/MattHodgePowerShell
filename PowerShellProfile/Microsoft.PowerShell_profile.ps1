##########################
# Import PoshGit
##########################

. 'C:\tools\poshgit\dahlbyk-posh-git-fadc4dd\profile.example.ps1'

##########################
# Open Git Path
##########################

if (Test-Path -Path 'E:\ProjectsGit')
{
    Set-Location -Path "E:\ProjectsGit"
}
if (Test-Path -Path 'D:\ProjectsGit')
{
    Set-Location -Path "D:\ProjectsGit"
}


<#
.Synopsis
   Adds an Environment Variable to the system
.EXAMPLE
   Add-EnvironmentVariable -Variable "GOPATH" -Value F:\ProjectsGit\gotesting\
.EXAMPLE
   Add-EnvironmentVariable -Variable "GOROOT" -Value 'C:\tools\go'
#>
function Add-EnvironmentVariable
{
    [CmdletBinding()]
    Param
    (
        # The environment variable to add
        [Parameter(Mandatory=$true)]
        [string]
        $Variable,

        # The value of the environment variable
        [Parameter(Mandatory=$true)]
        [string]
        $Value
    )

    try
    {
        [Environment]::SetEnvironmentVariable($Variable, $Value, [EnvironmentVariableTarget]::User)
        Write-Output "$($Variable) with value $($Value) added to environment variables"
    }
    catch
    {
        Write-Error $_
    }
}

##########################
# Reload Path Variables
##########################

function Import-PathVariable
{
    # Reload Path Variable
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

Import-PathVariable

function Show-PathVariable
{
    $env:Path -split ';'
}

<#
.Synopsis
   Adds a Path Variable to the system
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Add-PathVariable
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true)]
        [ValidateScript({
        if(Test-Path -Path $_ -ErrorAction SilentlyContinue)
        {
            return $true
        }
        else
        {
            throw "$($_) does not exist."
        }
        })]
        [string]
        $Path
    )

    # Refresh Path Variables
    Import-PathVariable

    # Replace incorrect facing slashes
    $Path = $Path -replace '/','\'
    Write-Verbose "Path being used is $($Path)."

    # Check Path Variable First
    $arrayOfPaths = $env:Path -split ';'

    if ($arrayOfPaths -contains $Path)
    {
        Write-Output "Path $($Path) already exists in the path environment variable"
    }
    else
    {
        try
        {
            [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$($Path)", [EnvironmentVariableTarget]::User)
            Write-Output "Path $($Path) added to the path environment variable"
            # Refresh Path Variables
            Import-PathVariable
        }
        catch
        {
            Write-Error $_
        }
    }
}

##########################
# Style Prompt
##########################

function prompt
{
    Set-StrictMode -Off
 
    $history = Get-History
    $nextHistoryId = $history.Count + 1
    Write-Host "[" -ForegroundColor DarkGray -NoNewline
    Write-Host "$nextHistoryId" -ForegroundColor Red -NoNewline
    Write-Host "|" -ForegroundColor DarkGray -NoNewline
 
    Write-Host "$((Get-Date).ToShortTimeString())" -ForegroundColor Yellow -NoNewline
 
    if ($history) {
        $timing = $history[-1].EndExecutionTime - $history[-1].StartExecutionTime
        Write-Host "|" -ForegroundColor DarkGray -NoNewline
 
        $color = "Green"
        if ($timing.TotalSeconds -gt 1) {
            $color = "Red"
        }
 
        Write-Host "+" -ForegroundColor $color -NoNewline
        if ($timing.Hours) { Write-Host "$(($timing).Hours)h " -ForegroundColor $color -NoNewline }
        if ($timing.Minutes) { Write-Host "$(($timing).Minutes)m " -ForegroundColor $color -NoNewline }
        if ($timing.Seconds) { Write-Host "$(($timing).Seconds)s " -ForegroundColor $color -NoNewline }
        Write-Host "$(($timing).Milliseconds)ms" -ForegroundColor $color -NoNewline
    }
 
    Write-Host "] " -ForegroundColor DarkGray -NoNewline
   
    Write-Host "[" -ForegroundColor DarkGray -NoNewline
   
    [string]$path = $Pwd.Path
 
    if ($path -like "c:\users\$env:username*") {
        $path = "~home" + $path.Substring("c:\users\$env:username".Length)
    }
 
    $chunks = $path -split '\\'
 
    $short = $false
    if ($Pwd.Path.Length -gt 30 -and $chunks.Length -gt 2) {
        $chunks = $chunks | select -Last 2
        $short = $true
    }
 
    if ($short) {
        Write-Host "...\" -ForegroundColor DarkGray -NoNewline
    }
 
    $chunks | % { $i = 0 } {
        $i++
        $color = "Yellow"
 
        if ($_ -like "~home") { $color = "Green" }
        Write-Host "$_" -ForegroundColor $color -NoNewline
 
        if ($i -le $chunks.Count-1) {
            Write-Host "\" -ForegroundColor DarkGray -NoNewline
        }
    }
 
    Write-Host "]" -ForegroundColor DarkGray -NoNewline
     
 
    $g = Get-GitStatus
 
    if ($g) {
        Write-Host " [" -ForegroundColor DarkGray -NoNewline
       
        $branch = $g.Branch.Split("...") | select -first 1
        Write-Host $branch -ForegroundColor Red -NoNewline
 
        $add = $g.Working.Added.Count
        $cha = $g.Working.Modified.Count
        $del = $g.Working.Deleted.Count
        $ahead = $g.AheadBy
        $behind = $g.BehindBy
 
        if ($add) {
            Write-Host "|" -ForegroundColor DarkGray -NoNewline
            Write-Host "+$add" -ForegroundColor Yellow -NoNewline
        }
 
        if ($rem) {
            Write-Host "|" -ForegroundColor DarkGray -NoNewline
            Write-Host "-$rem" -ForegroundColor Yellow -NoNewline
        }
 
        if ($cha) {
            Write-Host "|" -ForegroundColor DarkGray -NoNewline
            Write-Host "~$cha" -ForegroundColor Yellow -NoNewline
        }
 
        if (!$g.Working) {
            Write-Host "|" -ForegroundColor DarkGray -NoNewline
            Write-Host "clean" -ForegroundColor Green -NoNewline
        }
 
        if ($ahead) {
            Write-Host "|" -ForegroundColor DarkGray -NoNewline
            Write-Host "▲$ahead" -ForegroundColor Green -NoNewline
        }
 
        if ($behind) {
            Write-Host "|" -ForegroundColor DarkGray -NoNewline
            Write-Host "▼$behind" -ForegroundColor Red -NoNewline
        }
 
        Write-Host "]" -ForegroundColor DarkGray -NoNewline
    }
    Write-Host "`n>" -ForegroundColor DarkGray -NoNewline
    return " "
}

##########################
# Run pester tests in a background job
##########################

function Invoke-PesterJob
{
    [CmdletBinding(DefaultParameterSetName = 'LegacyOutputXml')]
    param(
        [Parameter(Position=0,Mandatory=0)]
        [Alias('Path', 'relative_path')]
        [object[]]$Script = '.',

        [Parameter(Position=1,Mandatory=0)]
        [Alias("Name")]
        [string[]]$TestName,

        [Parameter(Position=2,Mandatory=0)]
        [switch]$EnableExit,

        [Parameter(Position=3,Mandatory=0, ParameterSetName = 'LegacyOutputXml')]
        [string]$OutputXml,

        [Parameter(Position=4,Mandatory=0)]
        [Alias('Tags')]
        [string[]]$Tag,

        [string[]]$ExcludeTag,

        [switch]$PassThru,

        [object[]] $CodeCoverage = @(),

        [Switch]$Strict,

        [Parameter(Mandatory = $true, ParameterSetName = 'NewOutputSet')]
        [string] $OutputFile,

        [Parameter(ParameterSetName = 'NewOutputSet')]
        [ValidateSet('LegacyNUnitXml', 'NUnitXml')]
        [string] $OutputFormat = 'NUnitXml',

        [Switch]$Quiet,

        [object]$PesterOption
    )

    $params = $PSBoundParameters
    
    Start-Job -ScriptBlock { Set-Location $using:pwd; Invoke-Pester @using:params } |
    Receive-Job -Wait -AutoRemoveJob
}

function ConvertFrom-PesterOutputObject {
  param (
    [parameter(ValueFromPipeline=$true)]
    [object]
    $InputObject
  )
  begin {
    $PesterModule = Import-Module Pester -Passthru
  }
  process {
    $DescribeGroup = $InputObject.testresult | Group-Object Describe
    foreach ($DescribeBlock in $DescribeGroup) {
      $PesterModule.Invoke({Write-Screen $args[0]}, "Describing $($DescribeBlock.Name)")
      $ContextGroup = $DescribeBlock.group | Group-Object Context
      foreach ($ContextBlock in $ContextGroup) {
        $PesterModule.Invoke({Write-Screen $args[0]}, "`tContext $($subheader.name)")
        foreach ($TestResult in $ContextBlock.group) {
          $PesterModule.Invoke({Write-PesterResult $args[0]}, $TestResult)
        }
      }
    }
    $PesterModule.Invoke({Write-PesterReport $args[0]}, $InputObject)
  }
}