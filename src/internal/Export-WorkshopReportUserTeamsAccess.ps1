function Export-WorkshopReportUserTeamsAccess {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # Team Membership data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $TeamMembershipData = '.\TeamMemberships.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\TeamsAccess.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: User Teams Access'
        try {
            if ($TeamMembershipData -is [string]) { $TeamMembershipData = Import-Clixml (Resolve-FullPath $TeamMembershipData $DataDirectory -ErrorAction Stop) }
        }
        catch { return }

        [object[]] $OutputAttributes = @(
            'userId', 'userPrincipalName', 'userDisplayName', 'userType'
            'id', 'displayName', 'description'
            'classification', 'guestSettings'
            'createdDateTime', 'deletedDateTime'
        )

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $TeamMembershipData | Select-Object -Property $OutputAttributes | Sort-Object -Property userDisplayName, displayName | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}