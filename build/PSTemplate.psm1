#region module variables
# $moduleVariable = [PSCustomObject]@{
#     BaseUri = $null
# }
# New-Variable -Name ModuleVariable -Value $moduleVariable -Scope Script -Force
#endregion module variables

#region dot source and export functions
# foreach ($scope in "Private", "Public") {
#     $scopeFolder = (Join-Path -Path $PSScriptRoot -ChildPath $scope)
#     if (Test-Path -Path $scopeFolder) {
#         foreach ($scriptFile in (Get-ChildItem -Path $scopeFolder -Filter *.ps1)) {
#             . $scriptFile.FullName

#             if ($scope -eq "Public") {
#                 Export-ModuleMember -Function $scriptFile -ErrorAction Stop
#             }
#         }
#     }
# }
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
try {
    foreach ($Scope in 'Public', 'Private') {
        Get-ChildItem (Join-Path -Path $ScriptPath -ChildPath $Scope) -Filter *.ps1 | ForEach-Object {
            . $_.FullName
            if ($Scope -eq 'Public') {
                Export-ModuleMember -Function $_.BaseName -ErrorAction Stop
            }
        }
    }
}
catch {
    Write-Error ("{0}: {1}" -f $_.BaseName, $_.Exception.Message)
    exit 1
}
#endregion dot source and export functions
