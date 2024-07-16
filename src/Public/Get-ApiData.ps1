function Get-ApiData {
    [CmdletBinding()]
    param ()

    begin {
        $configPath = "$PSScriptRoot/../Config/config.json"
        $config = Import-Configuration -Path $configPath
    }

    process {
        try {
            $params = @{
                Uri = $config.Uri
            }
            $response = Invoke-RestMethod @params
        }
        catch {
            Write-Error $_.Exception.StatusCode
            return $null
        }

        $response
    }
}
