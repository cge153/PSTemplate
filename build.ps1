# [CmdletBinding()]
# param (
#     [Parameter()]
#     [ValidateSet("Local", "Remote")]
#     [string]
#     $Publish
# )

# $moduleName = "PSTemplate"
$sourcePath = "./src"
$buildPath = "./build"
# $testPath = "./tests"
# $localModulePath = ($env:PSModulePath -split ":" )[0] # Should be user scope path
# $nugetApiKey = "YourNuGetApiKeyHere"
# $nugetSource = "https://api.nuget.org/v3/index.json"

# ANSI color codes for better readability
$green = "`e[32m"
$yellow = "`e[33m"
$red = "`e[31m"
$blue = "`e[34m"
$reset = "`e[0m"

$Message = "just testing, nothing to do..."

# Function to log information with colors
function Write-LogInfo {
    param(
        [string]$Message
    )
    Write-Information -MessageData "$blue[INFO]$reset $Message" -InformationAction Continue
}

# Function to log warnings with colors
function Write-LogWarning {
    param(
        [string]$Message
    )
    Write-Information -MessageData "$yellow[WARNING]$reset $Message" -InformationAction Continue
}

# Function to log errors with colors
function Write-LogError {
    param(
        [string]$Message
    )
    Write-Information -MessageData "$red[ERROR]$reset $Message" -InformationAction Continue
}

# Function to log success messages with colors
function Write-LogSuccess {
    param(
        [string]$Message
    )
    Write-Information -MessageData "$green[SUCCESS]$reset $Message" -InformationAction Continue
}

function Clear-BuildFolder {
    Write-LogInfo "Cleaning build folder..."
    # Create the build output directory if it doesn't exist
    if (-not (Test-Path -Path $buildPath)) {
        New-Item -ItemType Directory -Path $buildPath
    }
    
    # Clean up previous build artifacts
    Get-ChildItem -Path $buildPath -Recurse | Remove-Item -Force -Recurse
    Write-LogSuccess "Done."
}

function Copy-SourcesToBuild {
    Write-LogInfo "Copying source files to build folder..."
    Copy-Item -Path "$sourcePath/*" -Destination $buildPath -Recurse -Force
    Write-LogSuccess "Done."
}

function Start-PSScriptAnalyzer {
    Write-LogInfo "Running PSScriptAnalyzer..."
    
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

# function Publish-NuGetPackage {
#     if ($Publish.ToUpper() -eq "LOCAL") {
#         Write-Information -MessageData "Importing module with user scope..." -InformationAction Continue

#         if (Test-Path $localModulePath) {
#             Write-Information -MessageData "Deleting contents of existing module folder..." -InformationAction Continue
#             Remove-Item $localModulePath\* -Recurse -Force
#         }
#         else {
#             Write-Information -MessageData "`nCreating new module folder... " -InformationAction Continue
#             New-Item -Path $localModulePath -ItemType "Directory"
#         }
#     }
#     else {

#         Write-Information -MessageData "Publishing package to NuGet repository..." -InformationAction Continue
#         Publish-Module -Path $buildDir -Repository $repositoryName -NuGetApiKey 'YourApiKey' # Provide API key if needed
#     }
# }

# Main script
try {
    Write-LogInfo "Started build process."

    Clear-BuildFolder
    Copy-SourcesToBuild
    Start-PSScriptAnalyzer
    # Start-PesterTests
    # Publish-NuGetPackage

    Write-LogSuccess "Build script completed.`n"
}
catch {
    Write-LogError "Build script failed: $_`n"
    exit 1
}
