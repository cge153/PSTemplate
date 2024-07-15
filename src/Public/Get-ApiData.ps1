function Get-ApiData {
    [CmdletBinding()]
    param ()

    begin {
        $uri = "https://jsonplaceholder.typicode.com/posts"
    }

    process {
        try {
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
