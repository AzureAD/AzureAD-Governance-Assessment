<#
.SYNOPSIS
    Collect Data for Azure AD Governance Workshop
.DESCRIPTION
    Collect Data for Azure AD Governance Workshop
.EXAMPLE
    PS C:\>Invoke-WorkshopDataCollection
    Collect Data for Azure AD Governance Workshop
#>
function Invoke-MSGovernanceDataCollection {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # Output Directory
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputDirectory,
        # Tenant name for connecting to SharePoint Online. For example, "https://<TenantName>-admin.sharepoint.com/"
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $TenantName,
        # Tenant identifier to use when connecting to MS Graph.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $TenantId = 'organizations',
        # Skip Report Output
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [switch] $SkipReportOutput,
        # Prompt for user confirmation before collecting optional data.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [switch] $Prompt
    )

    begin {
        New-Variable -Name stackProgressId -Scope Script -Value (New-Object System.Collections.Generic.Stack[int]) -ErrorAction SilentlyContinue
        $stackProgressId.Clear()
        $stackProgressId.Push(0)

        $PromptChoices = @(
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Yes, collect the data."
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "No, skip this."
        )
    }

    process {
        Write-Output 'Connecting to Microsoft Graph...'
        #Connect-MgGraph -TenantId $TenantId -Scopes 'Directory.AccessAsUser.All'
        Connect-MgGraph -TenantId $TenantId -Scopes 'Organization.Read.All', 'User.Read.All', 'Application.Read.All', 'RoleManagement.Read.All', 'AppRoleAssignment.ReadWrite.All', 'Policy.Read.All', 'AuditLog.Read.All', 'EntitlementManagement.Read.All' | Out-Null

        ## Get Tenant Settings
        $MsGraphContextData = Get-MgContext

        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $MsGraphContextData.TenantId) -Status 'Tenant Domains' -PercentComplete 0
        $OrganizationData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri 'organization' -QueryParameters @{
            #'$select' = ('id', 'verifiedDomains') -join ','
        }
        $OrganizationData = $OrganizationData | ForEach-Object { [pscustomobject]$_ }

        $InitialTenantDomain = $OrganizationData.verifiedDomains | ForEach-Object { [pscustomobject]$_ } | Where-Object isInitial -EQ $true | Select-Object -ExpandProperty name -First 1
        if (!$TenantName) { $TenantName = $InitialTenantDomain.Replace('.onmicrosoft.com', '') }

        ## Create Output Directory
        $OutputDirectory = Join-Path $OutputDirectory $InitialTenantDomain
        Assert-DirectoryExists $OutputDirectory | Out-Null

        ## Output Tenant Context and Domain Data
        $OutputPath = Join-Path $OutputDirectory 'MsGraphContext.xml'
        $MsGraphContextData | Export-Clixml -Path $OutputPath -Force
        $OutputPath = Join-Path $OutputDirectory 'Organization.xml'
        $OrganizationData | Export-Clixml -Path $OutputPath -Force
        #$OutputPath = Join-Path $OutputDirectory 'TenantDomains.xml'
        #$TenantDomainData | Export-Clixml -Path $OutputPath -Force

        ## Get SharePoint Settings Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'SharePoint Online Settings' -PercentComplete 5
        Write-Output 'Connecting to SharePoint Online Admin PowerShell...'
        Connect-SPOService -Url ('https://{0}-admin.sharepoint.com/' -f $TenantName)
        $OutputPath = Join-Path $OutputDirectory 'SpoSettings.xml'
        $SpoSettingsData = Get-SPOTenant
        $SpoSettingsData | Export-Clixml -Path $OutputPath -Force


        ## Get Teams Settings Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'Microsoft Teams Settings' -PercentComplete 10
        $OutputPath = Join-Path $OutputDirectory 'TeamsSettings.xml'
        try {
            Write-Output 'Connecting to Microsoft Teams Admin PowerShell...'
            Connect-MicrosoftTeams
            #$CsSession = New-CsOnlineSession -OverrideAdminDomain $InitialTenantDomain
            $TeamsSettingsData = Get-CsTeamsClientConfiguration
            #$TeamsSettingsData = Invoke-Command -Session $CsSession -ScriptBlock { Get-CsTeamsClientConfiguration }
        }
        finally {
            Disconnect-MicrosoftTeams
            #Remove-PSSession $CsSession
        }
        $TeamsSettingsData | Export-Clixml -Path $OutputPath -Force


        ## Get Entitlement Management Settings Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'Entitlement Management Settings' -PercentComplete 15
        $OutputPath = Join-Path $OutputDirectory 'ElmSettings.xml'
        $ElmSettingsData = Get-MsgraphResult -ApiVersion beta -RelativeUri 'identityGovernance/entitlementManagement/settings' -Select (('externalUserLifecycleAction', 'daysUntilExternalUserDeletedAfterBlocked') -join ',')
        $ElmSettingsData | Export-Clixml -Path $OutputPath -Force


        ## Get User Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'Users' -PercentComplete 20
        $OutputPath = Join-Path $OutputDirectory 'Users.xml'
        [string[]] $SourceAttributes = 'id', 'userPrincipalName', 'userType', 'accountEnabled', 'displayName', 'givenName', 'surname', 'mail', 'jobTitle', 'companyName', 'country', 'creationType', 'externalUserState', 'externalUserStateChangeDateTime', 'createdDateTime', 'deletedDateTime', 'refreshTokensValidFromDateTime', 'signInSessionsValidFromDateTime', 'signInActivity'
        $UserData = Get-MsgraphResult -ApiVersion beta -RelativeUri 'users' -Select ($SourceAttributes -join ',') -QueryParameters @{
            '$count'  = 'true'
            '$filter' = 'userType eq ''Guest'' or endsWith(userPrincipalName, ''#EXT#@{0}'')' -f $InitialTenantDomain
        }
        $UserData = $UserData | ForEach-Object { [pscustomobject]$_ }
        $UserData | Export-Clixml -Path $OutputPath -Force


        ## Get Applications/Service Principals Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'Service Principals' -PercentComplete 30
        $OutputPath = Join-Path $OutputDirectory 'ServicePrincipals.xml'
        [string[]] $SourceAttributes = 'id', 'appId', 'servicePrincipalType', 'accountEnabled', 'displayName', 'appRoles', 'appRoleAssignmentRequired', 'appOwnerOrganizationId', 'tags', 'createdDateTime', 'deletedDateTime'
        $ServicePrincipalData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri 'servicePrincipals' -Select ($SourceAttributes -join ',') -QueryParameters @{
            #'$count'  = 'true'
            #'$filter' = 'appOwnerOrganizationId ne ''f8cdef31-a31e-4b4a-93e4-5f571e91255a'''
        }
        $ServicePrincipalData = $ServicePrincipalData | ForEach-Object { [pscustomobject]$_ }
        $ServicePrincipalData | Export-Clixml -Path $OutputPath -Force


        ## Get User Directory Role Assignments
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'Directory Role Assignments' -PercentComplete 40
        if (!$Prompt -or (Write-HostPrompt "Confirm" "Do you want to collect user directory role assignment data?" -DefaultChoice 0 -Choices $PromptChoices) -eq 0) {
            $OutputPath = Join-Path $OutputDirectory 'DirectoryRoleAssignments.xml'
            [string[]] $SourceAttributes = 'id', 'displayName', 'description', 'roleTemplateId', 'createdDateTime', 'deletedDateTime'
            $listDirectoryRoleAssignmentData = New-Object System.Collections.Generic.List[hashtable]
            Use-Progress -InputObjects $UserData -Activity "User Processing" -Property userPrincipalName -ScriptBlock {
                $User = $args[0]
                [hashtable[]] $DirectoryRoleAssignmentData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri ('users/{0}/memberOf' -f $User.id) -Select ($SourceAttributes -join ',')
                foreach ($DirectoryRoleAssignment in $DirectoryRoleAssignmentData) {
                    $DirectoryRoleAssignment.Add('userId', $User.id)
                    $DirectoryRoleAssignment.Add('userPrincipalName', $User.userPrincipalName)
                    $DirectoryRoleAssignment.Add('userDisplayName', $User.displayName)
                    $DirectoryRoleAssignment.Add('userType', $User.userType)
                }
                if ($DirectoryRoleAssignmentData) { $listDirectoryRoleAssignmentData.AddRange($DirectoryRoleAssignmentData) }
            }
            $DirectoryRoleAssignmentData = $listDirectoryRoleAssignmentData | ForEach-Object { [pscustomobject]$_ }
            $DirectoryRoleAssignmentData | Where-Object '@odata.type' -EQ '#microsoft.graph.directoryRole' | Export-Clixml -Path $OutputPath -Force
        }


        ## Get User App Role Assignments
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'App Role Assignments' -PercentComplete 50
        if (!$Prompt -or (Write-HostPrompt "Confirm" "Do you want to collect user application role assignment data?" -DefaultChoice 0 -Choices $PromptChoices) -eq 0) {
            $OutputPath = Join-Path $OutputDirectory 'AppRoleAssignments.xml'
            #[string[]] $SourceAttributes = 'id', 'principalType', 'principalId', 'principalDisplayName', 'resourceId', 'resourceDisplayName', 'appRoleId', 'createdDateTime', 'deletedDateTime'
            $listAppRoleAssignmentData = New-Object System.Collections.Generic.List[hashtable]
            Use-Progress -InputObjects $UserData -Activity "User Processing" -Property userPrincipalName -ScriptBlock {
                $User = $args[0]
                [hashtable[]] $AppRoleAssignmentData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri ('users/{0}/appRoleAssignments' -f $User.id)
                foreach ($AppRoleAssignment in $AppRoleAssignmentData) {
                    $AppRoleAssignment.Add('userId', $User.id)
                    $AppRoleAssignment.Add('userPrincipalName', $User.userPrincipalName)
                    $AppRoleAssignment.Add('userDisplayName', $User.displayName)
                    $AppRoleAssignment.Add('userType', $User.userType)
                }
                if ($AppRoleAssignmentData) { $listAppRoleAssignmentData.AddRange($AppRoleAssignmentData) }
            }
            $AppRoleAssignmentData = $listAppRoleAssignmentData | ForEach-Object { [pscustomobject]$_ }
            $AppRoleAssignmentData | Export-Clixml -Path $OutputPath -Force
        }


        ## Get User Team Membership Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'Team Memberships' -PercentComplete 60
        if (!$Prompt -or (Write-HostPrompt "Confirm" "Do you want to collect user Teams access data?" -DefaultChoice 0 -Choices $PromptChoices) -eq 0) {
            $OutputPath = Join-Path $OutputDirectory 'TeamMemberships.xml'
            [string[]] $SourceAttributes = 'id', 'displayName', 'description', 'classification', 'guestSettings', 'createdDateTime', 'deletedDateTime'
            $listTeamMembershipData = New-Object System.Collections.Generic.List[hashtable]
            Use-Progress -InputObjects $UserData -Activity "User Processing" -Property userPrincipalName -ScriptBlock {
                $User = $args[0]
                [hashtable[]] $TeamMembershipData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri ('users/{0}/joinedTeams' -f $User.id) -Select ($SourceAttributes -join ',')
                foreach ($Team in $TeamMembershipData) {
                    $Team.Add('userId', $User.id)
                    $Team.Add('userPrincipalName', $User.userPrincipalName)
                    $Team.Add('userDisplayName', $User.displayName)
                    $Team.Add('userType', $User.userType)
                }
                if ($TeamMembershipData) { $listTeamMembershipData.AddRange($TeamMembershipData) }
            }
            $TeamMembershipData = $listTeamMembershipData | ForEach-Object { [pscustomobject]$_ }
            $TeamMembershipData | Export-Clixml -Path $OutputPath -Force
        }


        ## Get Conditional Access Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'Conditional Access Policies' -PercentComplete 70
        $OutputPath = Join-Path $OutputDirectory 'ConditionalAccessPolicies.xml'
        $ConditionalAccessPolicyData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri 'identity/conditionalAccess/policies'
        $ConditionalAccessPolicyData = $ConditionalAccessPolicyData | ForEach-Object { [pscustomobject]$_ }
        $ConditionalAccessPolicyData | Export-Clixml -Path $OutputPath -Force


        ## Get User Signin Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'User Sign-in Logs' -PercentComplete 80
        if (!$Prompt -or (Write-HostPrompt "Confirm" "Do you want to collect user sign-in log data?" -DefaultChoice 0 -Choices $PromptChoices) -eq 0) {
            $OutputPath = Join-Path $OutputDirectory 'SignInLogs.xml'
            $listSignInData = New-Object System.Collections.Generic.List[hashtable]
            Use-Progress -InputObjects $UserData -Activity "User Processing" -Property userPrincipalName -ScriptBlock {
                $User = $args[0]
                [hashtable[]] $SignInData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri 'auditLogs/signIns' -Filter ("userId eq '{0}'" -f $User.id)
                if ($SignInData) { $listSignInData.AddRange($SignInData) }
            }
            $SignInData = $listSignInData | ForEach-Object { [pscustomobject]$_ }
            $SignInData | Export-Clixml -Path $OutputPath -Force
        }


        ## Get User Audit Data
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Status 'User Audit Logs' -PercentComplete 90
        if (!$Prompt -or (Write-HostPrompt "Confirm" "Do you want to collect user audit log data?" -DefaultChoice 0 -Choices $PromptChoices) -eq 0) {
            $OutputPath = Join-Path $OutputDirectory 'AuditLogs.xml'
            $listAuditData = New-Object System.Collections.Generic.List[hashtable]
            Use-Progress -InputObjects $UserData -Activity "User Processing" -Property userPrincipalName -ScriptBlock {
                $User = $args[0]
                [hashtable[]] $AuditData = Get-MsgraphResult -ApiVersion 'v1.0' -RelativeUri 'auditLogs/directoryaudits' -Filter ("initiatedBy/user/id eq '{0}'" -f $User.id)
                if ($AuditData) { $listAuditData.AddRange($AuditData) }
            }
            $AuditData = $listAuditData | ForEach-Object { [pscustomobject]$_ }
            $AuditData | Export-Clixml -Path $OutputPath -Force
        }

        ## Complete
        Write-Progress -Id 0 -Activity ('Microsoft Governance Workshop Data Collection - {0}' -f $InitialTenantDomain) -Completed

        ## Package Output
        Compress-Archive (Join-Path $OutputDirectory '\*') -DestinationPath "$OutputDirectory.zip" -Force

        ## Generate Reports
        if (!$SkipReportOutput) {
            Export-WorkshopReports -DataDirectory $OutputDirectory
        }
    }
    end {
        Disconnect-MgGraph
        Disconnect-SPOService
        Disconnect-MicrosoftTeams
    }
}