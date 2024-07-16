function Add-ApiData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [String]
        $Title = "foo",

        [Parameter(Mandatory = $false)]
        [String]
        $Body = "bar",

        [Parameter(Mandatory = $false)]
        [int32]
        $UserId = 1
    )

    begin {
        $configPath = "$PSScriptRoot/../Config/config.json"
        $config = Import-Configuration -Path $configPath
    }

    process {
        try {
            $apiBody = @{
                title  = $Title
                body   = $Body
                userId = $UserId
            } | ConvertTo-Json

            $headers = @{
                "Content-Type" = "application/json"
            }

            $params = @{
                Uri     = $config.Uri
                Method  = "Post"
                Body    = $apiBody
                Headers = $headers
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
