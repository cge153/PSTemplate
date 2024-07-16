# Define paths and variables
$moduleName = "MyPowerShellModule"
$sourceDir = "src"
$buildDir = "build\output"
$testsDir = "tests"
$repositoryName = "MyNuGetRepo"  # Change this to your repository name as registered with Register-PSRepository

# Ensure PSScriptAnalyzer is installed
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Output "Installing PSScriptAnalyzer..."
    Install-Module -Name PSScriptAnalyzer -Force
}

# Create the build output directory if it doesn't exist
if (-not (Test-Path -Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir
}

# Clean up previous build artifacts
Get-ChildItem -Path $buildDir -Recurse | Remove-Item -Force -Recurse

# Compile the module
Write-Output "Compiling the module..."
Copy-Item -Path "$sourceDir\*" -Destination $buildDir -Recurse

# Import the module functions
Write-Output "Importing module functions..."
Get-ChildItem -Path "$buildDir\Public" -Filter *.ps1 | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$buildDir\Private" -Filter *.ps1 | ForEach-Object { . $_.FullName }

# Run PSScriptAnalyzer to check the code
Write-Output "Running PSScriptAnalyzer..."
$analyzerResults = Invoke-ScriptAnalyzer -Path "$buildDir\*.ps1"

if ($analyzerResults) {
    $analyzerResults | ForEach-Object {
        Write-Output "[$($_.Severity)] $($_.Message) in $($_.ScriptName) at line $($_.Line)"
    }
    Write-Error "ScriptAnalyzer found issues in the code. Fix the issues before proceeding."
    exit 1
}

# Run tests using Pester
Write-Output "Running tests..."
Invoke-Pester -Script "$testsDir\Public\*.Tests.ps1" -OutputFile "$buildDir\test-results-public.xml" -OutputFormat NUnitXml
Invoke-Pester -Script "$testsDir\Private\*.Tests.ps1" -OutputFile "$buildDir\test-results-private.xml" -OutputFormat NUnitXml

# Check if tests passed
$publicTestResults = [xml](Get-Content "$buildDir\test-results-public.xml")
$privateTestResults = [xml](Get-Content "$buildDir\test-results-private.xml")

$testsFailed = $publicTestResults.testsuites.testsuite | Where-Object { $_.failures -gt 0 } + 
               $privateTestResults.testsuites.testsuite | Where-Object { $_.failures -gt 0 }

if ($testsFailed) {
    Write-Error "Tests failed. Check the test results for more information."
    exit 1
}

# Package the module (optional step, since Publish-Module handles this)
Write-Output "Packaging the module..."
$modulePackage = "$buildDir\$moduleName.zip"
Compress-Archive -Path "$buildDir\*" -DestinationPath $modulePackage

# Publish the module to the repository
Write-Output "Publishing the module to the repository..."
Publish-Module -Path $buildDir -Repository $repositoryName -NuGetApiKey 'YourApiKey' # Provide API key if needed

Write-Output "Build and publishing completed successfully."
