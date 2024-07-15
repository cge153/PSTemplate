#region module variables
$moduleVariable = @{
    Uri = $null
}

#endregion module variables

#region dot source and export functions
$scriptFolderTypes = @("Private", "Public")

foreach ($scriptFolderType in $scriptFolderTypes) {
    $scriptFolder = (Join-Path -Path $PSScriptRoot -ChildPath $scriptFolderType)
    if (Test-Path -Path $scriptFolder) {
        $scriptFiles = Get-ChildItem -Path $scriptFolder -Filter *.ps1
        foreach ($scriptFile in $scriptFiles) {
            . $scriptFile.FullName

            if ($scriptFolderType -eq "Public") {
                Export-ModuleMember -Function $scriptFile
            }
        }
    }
}
#endregion dot source and export functions
