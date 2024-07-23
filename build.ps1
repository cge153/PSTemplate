[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("Local", "Remote")]
    [string]
    $Publish = "Local"
)

$moduleName = "PSTemplate"
$sourcePath = "./src"
$buildPath = "./build"
# $testPath = "./tests"
$localModulePath = "$(($env:PSModulePath -split ":" )[0])/$moduleName" # Should be user scope path
# $nugetApiKey = "YourNuGetApiKeyHere"
# $nugetSource = "https://api.nuget.org/v3/index.json"

# ANSI color codes for better readability
$green = "`e[32m"
$yellow = "`e[33m"
$red = "`e[31m"
$blue = "`e[34m"
$reset = "`e[0m"

# Function to log information with colors
function Write-LogInfo {
    param(
        [string]$Message,
        [switch]$PreNewLine,
        [switch]$PostNewLine
    )
    
    $preLineBreak = if ($PreNewLine) { "`n" } else { "" }
    $postLineBreak = if ($PostNewLine) { "`n" } else { "" }

    Write-Information -MessageData "$preLineBreak$blue[ INFO    ]$reset $Message$postLineBreak" -InformationAction Continue
}

# Function to log warnings with colors
function Write-LogWarning {
    param(
        [string]$Message,
        [switch]$PreNewLine,
        [switch]$PostNewLine
    )
    
    $preLineBreak = if ($PreNewLine) { "`n" } else { "" }
    $postLineBreak = if ($PostNewLine) { "`n" } else { "" }

    Write-Information -MessageData "$preLineBreak$yellow[ WARNING ]$reset $Message$postLineBreak" -InformationAction Continue
}

# Function to log errors with colors
function Write-LogError {
    param(
        [string]$Message,
        [switch]$PreNewLine,
        [switch]$PostNewLine
    )
    
    $preLineBreak = if ($PreNewLine) { "`n" } else { "" }
    $postLineBreak = if ($PostNewLine) { "`n" } else { "" }

    Write-Information -MessageData "$preLineBreak$red[ ERROR   ]$reset $Message$postLineBreak" -InformationAction Continue
}

# Function to log success messages with colors
function Write-LogSuccess {
    param(
        [string]$Message,
        [switch]$PreNewLine,
        [switch]$PostNewLine
    )
    
    $preLineBreak = if ($PreNewLine) { "`n" } else { "" }
    $postLineBreak = if ($PostNewLine) { "`n" } else { "" }

    Write-Information -MessageData "$preLineBreak$green[ SUCCESS ]$reset $Message$postLineBreak" -InformationAction Continue
}

function Clear-BuildFolder {
    Write-LogInfo "Cleaning build folder: start"
    # Create the build output directory if it doesn't exist
    if (-not (Test-Path -Path $buildPath)) {
        New-Item -ItemType Directory -Path $buildPath
    }
    
    # Clean up previous build artifacts
    Get-ChildItem -Path $buildPath -Recurse | Remove-Item -Force -Recurse
    Write-LogSuccess "Cleaning build folder: done" -PostNewLine
}

function Copy-SourcesToBuild {
    Write-LogInfo "Copying source files to build folder: start"
    Copy-Item -Path "$sourcePath/*" -Destination $buildPath -Recurse -Force
    Write-LogSuccess "Copying source files to build folder: done" -PostNewLine
}

function Start-PSScriptAnalyzer {
    Write-LogInfo "Running PSScriptAnalyzer: start"
    
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Write-LogInfo "Installing PSScriptAnalyzer..."
        Install-Module -Name PSScriptAnalyzer -Force
    }

    $issues = Invoke-ScriptAnalyzer -Path $buildPath -Recurse
    if ($issues) {
        $issues | Format-Table -AutoSize
        throw "PSScriptAnalyzer found issues."
    }
    else {
        Write-LogSuccess "No issues found by PSScriptAnalyzer."
    }

    Write-LogSuccess "Running PSScriptAnalyzer: done" -PostNewLine
}

# function Start-PesterTests {
#     Write-Information -MessageData "Running Pester tests..." -InformationAction Continue

#     if (-not (Get-Module -ListAvailable -Name Pester)) {
#         Write-Information -MessageData "Installing Pester..." -InformationAction Continue
#         Install-Module -Name Pester -Force
#     }

#     Invoke-Pester -Script @{ Path = $testPath; OutputFormat = 'NUnitXml'; OutputFile = "$buildPath\TestResults.xml" }
#     if ($LASTEXITCODE -ne 0) {
#         throw "Pester tests failed."
#     }
#     else {
#         Write-Information -MessageData "Pester tests passed." -InformationAction Continue
#     }
# }

function Publish-NuGetPackage {
    if ($Publish.ToUpper() -eq "LOCAL") {
        Write-LogInfo "Importing module with user scope: start"

        if (Test-Path $localModulePath) {
            Write-LogInfo "Deleting contents of existing module folder..."
            Remove-Item $localModulePath\* -Recurse -Force
        }
        else {
            Write-LogInfo "Creating new module folder..."
            New-Item -Path $localModulePath -ItemType "Directory"
        }

        Write-LogInfo "Copying build files to module folder..."
        Copy-Item -Path "$buildPath/*" -Destination $localModulePath -Recurse -Force

        Write-LogInfo "Importing module..."
        Import-Module $moduleName -Force

        Write-LogSuccess "Importing module with user scope: done" -PostNewLine
    }
    # else {

    #     Write-Information -MessageData "Publishing package to NuGet repository..." -InformationAction Continue
    #     Publish-Module -Path $buildDir -Repository $repositoryName -NuGetApiKey 'YourApiKey' # Provide API key if needed
    # }
}

# Main script
try {
    Write-LogInfo "Build process: start" -PreNewLine -PostNewLine

    Clear-BuildFolder
    Copy-SourcesToBuild
    Start-PSScriptAnalyzer
    # Start-PesterTests
    Publish-NuGetPackage

    Write-LogSuccess "Build process: end" -PostNewLine
}
catch {
    Write-LogError "Build process failed: $_" -PostNewLine
    exit 1
}
