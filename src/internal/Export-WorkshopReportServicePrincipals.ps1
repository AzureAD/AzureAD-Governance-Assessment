function Export-WorkshopReportServicePrincipals {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # Service Principal data
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $ServicePrincipalData = '.\ServicePrincipals.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\ServicePrincipals.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: Service Principals'
        if ($ServicePrincipalData -is [string]) { $ServicePrincipalData = Import-Clixml (Resolve-FullPath $ServicePrincipalData $DataDirectory -ErrorAction Stop) }

        [object[]] $OutputAttributes = @(
            'id', 'appId', 'displayName'
            'servicePrincipalType', 'appOwnerOrganizationId', 'accountEnabled', 'appRoleAssignmentRequired'
            #@{ Name = 'appRoles'; Expression = { ($_.appRoles | foreach { '{0} - {1}' -f $_.id, $_.displayName }) -join "`r`n" } }
            @{ Name = 'appRoles.id'; Expression = { $_.appRoles.id -join "`r`n" } }
            @{ Name = 'appRoles.displayName'; Expression = { $_.appRoles.displayName -join "`r`n" } }
            'createdDateTime'
        )

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $ServicePrincipalData | Where-Object appOwnerOrganizationId -NotIn 'f8cdef31-a31e-4b4a-93e4-5f571e91255a', '47df5bb7-e6bc-4256-afb0-dd8c8e3c1ce8' | Select-Object -Property $OutputAttributes | Sort-Object -Property @{Expression = "accountEnabled"; Descending = $true }, appRoleAssignmentRequired, displayName | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}