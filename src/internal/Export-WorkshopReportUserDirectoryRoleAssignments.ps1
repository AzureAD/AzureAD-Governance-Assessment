function Export-WorkshopReportUserDirectoryRoleAssignments {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # Directory Role Assignment data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $DirectoryRoleAssignmentData = '.\DirectoryRoleAssignments.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\UserDirectoryRoleAssignments.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: User DirectoryRole Assignments'
        try {
            if ($DirectoryRoleAssignmentData -is [string]) { $DirectoryRoleAssignmentData = Import-Clixml (Resolve-FullPath $DirectoryRoleAssignmentData $DataDirectory -ErrorAction Stop) }
        }
        catch { return }

        [object[]] $OutputAttributes = @(
            'userId', 'userPrincipalName', 'userDisplayName', 'userType'
            @{ Name = 'roleId'; Expression = { $_.id } }
            @{ Name = 'roleDisplayName'; Expression = { $_.displayName } }
            @{ Name = 'roleDescription'; Expression = { $_.description } }
            'roleTemplateId'
        )

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $DirectoryRoleAssignmentData | Select-Object -Property $OutputAttributes | Sort-Object -Property userDisplayName, roleDisplayName | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}