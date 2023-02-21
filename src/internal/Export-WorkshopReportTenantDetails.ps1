function Export-WorkshopReportTenantDetails {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # Microsoft Graph Context data
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $MsGraphContextData = '.\MsGraphContext.xml',
        # Tenant Domain data
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $OrganizationData = '.\Organization.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\TenantDetails.json'
    )

    process {
        Write-Verbose 'Generating Workshop Report: Tenant Details'
        if ($MsGraphContextData -is [string]) { $MsGraphContextData = Import-Clixml (Resolve-FullPath $MsGraphContextData $DataDirectory -ErrorAction Stop) }
        if ($OrganizationData -is [string]) { $OrganizationData = Import-Clixml (Resolve-FullPath $OrganizationData $DataDirectory -ErrorAction Stop) }

        $VerifiedDomains = $OrganizationData.verifiedDomains | ForEach-Object { [pscustomobject]$_ }
        $FederatedDomains = $VerifiedDomains | Where-Object type -EQ 'Federated'
        $TenantDomainInitial = $VerifiedDomains | Where-Object isInitial -EQ $true | Select-Object -ExpandProperty name -First 1
        $TenantDomainDefault = $VerifiedDomains | Where-Object isDefault -EQ $true | Select-Object -ExpandProperty name -First 1
        $TenantName = $TenantDomainInitial.Replace('.onmicrosoft.com', '')

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        New-Object PsObject -Property ([ordered]@{
                'tenantId'                     = $OrganizationData.id
                'tenantDomainDefault'          = $TenantDomainDefault
                'tenantDomainInitial'          = $TenantDomainInitial
                'tenantName'                   = $TenantName
                'tenantDisplayName'            = $OrganizationData.displayName
                'tenantType'                   = $OrganizationData.tenantType
                'createdDateTime'              = $OrganizationData.createdDateTime
                'organizationCity'             = $OrganizationData.city
                'organizationState'            = $OrganizationData.state
                'organizationCountry'          = $OrganizationData.countryLetterCode
                'technicalNotificationMails'   = $OrganizationData.technicalNotificationMails
                'onPremisesSyncEnabled'        = $OrganizationData.onPremisesSyncEnabled
                'onPremisesLastSyncDateTime'   = $OrganizationData.onPremisesLastSyncDateTime
                'verifiedDomains'              = $VerifiedDomains.name
                'federatedDomains'             = $FederatedDomains.name
                'AccountUsedForDataCollection' = $MsGraphContextData.Account
            }) | ConvertTo-Json | Set-Content -Path $OutputPath
        #} | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}