function Export-WorkshopReportGuestSettings {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # Entitlement Lifecycle Manager settings data
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $ElmSettingsData = '.\ElmSettings.xml',
        # SharePoint Online settings data
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $SpoSettingsData = '.\SpoSettings.xml',
        # Teams settings data
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $TeamsSettingsData = '.\TeamsSettings.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\GuestSettings.json'
    )

    process {
        Write-Verbose 'Generating Workshop Report: Guest Settings'
        if ($ElmSettingsData -is [string]) { $ElmSettingsData = Import-Clixml (Resolve-FullPath $ElmSettingsData $DataDirectory -ErrorAction Stop) }
        if ($SpoSettingsData -is [string]) { $SpoSettingsData = Import-Clixml (Resolve-FullPath $SpoSettingsData $DataDirectory -ErrorAction Stop) }
        if ($TeamsSettingsData -is [string]) { $TeamsSettingsData = Import-Clixml (Resolve-FullPath $TeamsSettingsData $DataDirectory -ErrorAction Stop) }

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        New-Object PsObject -Property ([ordered]@{
                'SpoSharingCapability'                        = $SpoSettingsData.SharingCapability
                'SpoSharingDomainRestrictionMode'             = $SpoSettingsData.SharingDomainRestrictionMode
                'SpoSharingAllowedDomainList'                 = $SpoSettingsData.SharingAllowedDomainList
                'SpoSharingBlockedDomainList'                 = $SpoSettingsData.SharingBlockedDomainList
                'SpoEnableAzureADB2BIntegration'              = $SpoSettingsData.EnableAzureADB2BIntegration
                'TeamsAllowGuestUser'                         = $TeamsSettingsData.AllowGuestUser
                'ElmExternalUserLifecycleAction'              = $ElmSettingsData.externalUserLifecycleAction
                'ElmDaysUntilExternalUserDeletedAfterBlocked' = $ElmSettingsData.daysUntilExternalUserDeletedAfterBlocked
            }) | ConvertTo-Json | Set-Content -Path $OutputPath
        #} | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}