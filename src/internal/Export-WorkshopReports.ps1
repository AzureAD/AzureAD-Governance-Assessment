function Export-WorkshopReports {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory
        # # Entitlement Lifecycle Manager settings data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $ElmSettingsData,
        # # SharePoint Online settings data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $SpoSettingsData,
        # # Teams settings data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $TeamsSettingsData,
        # # User data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $UserData,
        # # Service Principal data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $ServicePrincipalData,
        # # Directory Role Assignment data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $DirectoryRoleAssignmentData,
        # # App Role Assignment data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $AppRoleAssignmentData,
        # # Conditional Access Policy data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $ConditionalAccessPolicyData,
        # # Team Membership data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $TeamMembershipData,
        # # Audit data or file path
        # [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        # [object] $AuditData
    )

    process {
        Export-WorkshopReportTenantDetails -DataDirectory $DataDirectory
        Export-WorkshopReportGuestSettings -DataDirectory $DataDirectory
        Export-WorkshopReportUsers -DataDirectory $DataDirectory
        Export-WorkshopReportServicePrincipals -DataDirectory $DataDirectory
        Export-WorkshopReportUserDirectoryRoleAssignments -DataDirectory $DataDirectory
        Export-WorkshopReportUserAppRoleAssignments -DataDirectory $DataDirectory
        Export-WorkshopReportUserCaPolicyExclusions -DataDirectory $DataDirectory
        Export-WorkshopReportUserTeamsAccess -DataDirectory $DataDirectory
        Export-WorkshopReportUserAuditLogs -DataDirectory $DataDirectory
        Export-WorkshopReportUserSignInLogs -DataDirectory $DataDirectory

        Compress-Archive (Join-Path $DataDirectory 'Reports\*') -DestinationPath ("{0}_Reports.zip" -f $DataDirectory) -Force
    }
}