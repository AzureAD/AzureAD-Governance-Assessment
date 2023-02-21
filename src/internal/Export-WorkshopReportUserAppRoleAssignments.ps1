function Export-WorkshopReportUserAppRoleAssignments {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # App Role Assignment data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $AppRoleAssignmentData = '.\AppRoleAssignments.xml',
        # Service Principal data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $ServicePrincipalData = '.\ServicePrincipals.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\UserAppRoleAssignments.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: User AppRole Assignments'
        try {
            if ($AppRoleAssignmentData -is [string]) { $AppRoleAssignmentData = Import-Clixml (Resolve-FullPath $AppRoleAssignmentData $DataDirectory -ErrorAction Stop) }
            if ($ServicePrincipalData -is [string]) { $ServicePrincipalData = Import-Clixml (Resolve-FullPath $ServicePrincipalData $DataDirectory -ErrorAction Stop) }
        }
        catch { return }

        [object[]] $OutputAttributes = @(
            'userId', 'userPrincipalName', 'userDisplayName', 'userType'
            'id', 'createdDateTime'
            'principalType', 'principalId', 'principalDisplayName'
            'resourceId', 'resourceDisplayName'
            @{ Name = 'resourceAccountEnabled'; Expression = { $ServicePrincipalData | Where-Object id -EQ $_.resourceId | Select-Object -ExpandProperty accountEnabled } }
            @{ Name = 'resourceAppRoleAssignmentRequired'; Expression = { $ServicePrincipalData | Where-Object id -EQ $_.resourceId | Select-Object -ExpandProperty appRoleAssignmentRequired } }
            'appRoleId'
            @{ Name = 'appRoleDisplayName'; Expression = { if ($_.appRoleId -eq '00000000-0000-0000-0000-000000000000') { 'Default Access' } else { $ServicePrincipalData | Where-Object id -EQ $_.resourceId | Select-Object -ExpandProperty appRoles | Where-Object id -EQ $_.appRoleId | Select-Object -ExpandProperty displayName } } }
        )

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $AppRoleAssignmentData | Select-Object -Property $OutputAttributes | Sort-Object -Property resourceAccountEnabled, resourceAppRoleAssignmentRequired -Descending | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}