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
        $uri = "https://jsonplaceholder.typicode.com/posts"
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
                Uri     = $uri
                Method  = "Post"
                Body    = $apiBody
                Headers = $headers
            }
            $response = Invoke-RestMethod @params
        }
        catch {
            Write-Error $_.Exception.StatusCode
            Write-Error $_ | select-object -property *
            return $null
        }

        $response
    }
}
