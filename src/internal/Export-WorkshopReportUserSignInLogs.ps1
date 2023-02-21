function Export-WorkshopReportUserSignInLogs {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # User data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $UserData = '.\Users.xml',
        # SignIn data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $SignInData = '.\SignInLogs.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\SignInLogs.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: User SignIn Logs'
        try {
            if ($UserData -is [string]) { $UserData = Import-Clixml (Resolve-FullPath $UserData $DataDirectory -ErrorAction Stop) }
            if ($SignInData -is [string]) { $SignInData = Import-Clixml (Resolve-FullPath $SignInData $DataDirectory -ErrorAction Stop) }
        }
        catch { return }

        foreach ($SignInLog in $SignInData) {
            $User = $UserData | Where-Object id -EQ $SignInLog.userId
            #$SignInLog['userPrincipalName'] = $User.userPrincipalName
            #$SignInLog['userDisplayName'] = $User.displayName
            $SignInLog | Add-Member 'userType' -MemberType NoteProperty -Value $User.userType
        }

        [object[]] $OutputAttributes = @(
            'userId', 'userPrincipalName', 'userDisplayName', 'userType'
            'id', 'createdDateTime', 'correlationId'
            'appId', 'appDisplayName', 'resourceId', 'resourceDisplayName'
            'isInteractive', 'authenticationRequirement', 'conditionalAccessStatus'
            'ipAddress', 'clientAppUsed', 'userAgent'
            'riskDetail', 'riskLevelAggregated', 'riskLevelDuringSignIn', 'riskState'
            @{ Name = 'statusErrorCode'; Expression = { $_.status.errorCode } }
            @{ Name = 'statusFailureReason'; Expression = { $_.status.failureReason } }
            @{ Name = 'deviceOperatingSystem'; Expression = { $_.deviceDetail.operatingSystem } }
            @{ Name = 'deviceBrowser'; Expression = { $_.deviceDetail.browser } }
            @{ Name = 'locationCity'; Expression = { $_.location.city } }
            @{ Name = 'locationState'; Expression = { $_.location.state } }
            @{ Name = 'locationCountryOrRegion'; Expression = { $_.location.countryOrRegion } }
        )

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $SignInData | Select-Object -Property $OutputAttributes | Sort-Object -Property userPrincipalName, createdDateTime | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}