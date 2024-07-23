function Get-Product {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Int16]
        $Id
    )

    begin {
        $configPath = "$PSScriptRoot/../Config/config.json"
        $config = Import-Configuration -Path $configPath
    }

    process {
        try {
            $uri = "$($config.BaseUri)/products"
            $uri += if ($Id) { "/$($Id.ToString())" }

            $params = @{
                Uri = $uri
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
