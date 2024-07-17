function Import-Configuration {
    <#
    .SYNOPSIS
        Imports the module configuration file.

    .DESCRIPTION
        Imports the module configuration file and returns it as a PSCustomObject.

    .INPUTS
        None. You cannot pipe input to this function.

    .OUTPUTS
        The functions returns a PSCustomObject with the information from the configuration file.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [string]
        $Path
    )

    if (-not (Test-Path -Path $Path)) {
        throw "Configuration file not found: $Path"
    }

    $configContent = Get-Content -Path $Path -Raw | ConvertFrom-Json
    $configContent
}
