function Export-WorkshopReportUsers {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # User data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $UserData = '.\Users.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\GuestUsers.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: Users'
        if ($UserData -is [string]) { $UserData = Import-Clixml (Resolve-FullPath $UserData $DataDirectory -ErrorAction Stop) }

        $Today = Get-Date
        [object[]] $OutputAttributes = @(
            'id', 'userPrincipalName', 'displayName', 'mail'
            'userType', 'accountEnabled', 'createdDateTime', 'creationType', 'externalUserState', 'externalUserStateChangeDateTime'
            @{ Name = 'lastSignInDateTime'; Expression = { $_.signInActivity.lastSignInDateTime } }
            @{ Name = 'lastSignInRequestId'; Expression = { $_.signInActivity.lastSignInRequestId } }
            @{ Name = 'daysInactive'; Expression = { if ($_.signInActivity) { (New-TimeSpan -Start $_.signInActivity.lastSignInDateTime -End $Today).Days } } }
            'refreshTokensValidFromDateTime', 'signInSessionsValidFromDateTime'
            'jobTitle', 'companyName', 'country'
        )

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $UserData | Where-Object { $_.userType -eq 'Guest' -or $_.userPrincipalName -like "*#EXT#@*" } | Select-Object -Property $OutputAttributes | Sort-Object -Property lastSignInDateTime, @{Expression = "externalUserState"; Descending = $true }, displayName | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}