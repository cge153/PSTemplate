#region module variables
$moduleVariable = [PSCustomObject]@{
    Uri = $null
}
New-Variable -Name ModuleVariable -Value $moduleVariable -Scope Script -Force
#endregion module variables

#region dot source and export functions
foreach ($scope in "Private", "Public") {
    $scopeFolder = (Join-Path -Path $PSScriptRoot -ChildPath $scope)
    if (Test-Path -Path $scopeFolder) {
        foreach ($scriptFile in (Get-ChildItem -Path $scopeFolder -Filter *.ps1)) {
            . $scriptFile.FullName

            if ($scope -eq "Public") {
                Export-ModuleMember -Function $scriptFile -ErrorAction Stop
            }
        }
    }
}
#endregion dot source and export functions
