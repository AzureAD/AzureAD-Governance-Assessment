function Export-WorkshopReportUserAuditLogs {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # User data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $UserData = '.\Users.xml',
        # Audit data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $AuditData = '.\AuditLogs.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\AuditLogs.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: User Audit Logs'
        try {
            if ($UserData -is [string]) { $UserData = Import-Clixml (Resolve-FullPath $UserData $DataDirectory -ErrorAction Stop) }
            if ($AuditData -is [string]) { $AuditData = Import-Clixml (Resolve-FullPath $AuditData $DataDirectory -ErrorAction Stop) }
        }
        catch { return }

        foreach ($AuditLog in $AuditData) {
            $User = $UserData | Where-Object id -EQ $AuditLog.initiatedBy.user.id
            #$AuditLog.initiatedBy.user['userPrincipalName'] = $User.userPrincipalName
            $AuditLog.initiatedBy.user['displayName'] = $User.displayName
            #$AuditLog.initiatedBy.user | Add-Member 'userType' -MemberType NoteProperty -Value $User.userType
            $AuditLog.initiatedBy.user.Add('userType', $User.userType)
        }

        [object[]] $OutputAttributes = @(
            @{ Name = 'initiatedByUserId'; Expression = { $_.initiatedBy.user.id } }
            @{ Name = 'initiatedByUserPrincipalName'; Expression = { $_.initiatedBy.user.userPrincipalName } }
            @{ Name = 'initiatedByUserDisplayName'; Expression = { $_.initiatedBy.user.displayName } }
            @{ Name = 'initiatedByUserType'; Expression = { $_.initiatedBy.user.userType } }
            'id', 'activityDisplayName', 'activityDateTime', 'correlationId',
            'loggedByService', 'category'
            'operationType', 'result', 'resultReason'
            @{ Name = 'targetResourceId'; Expression = { $_.targetResources.id -join "`r`n" } }
            @{ Name = 'targetResourceDisplayName'; Expression = { $_.targetResources.displayName -join "`r`n" } }
            @{ Name = 'targetResourceType'; Expression = { $_.targetResources.type -join "`r`n" } }
        )

        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $AuditData | Select-Object -Property $OutputAttributes | Sort-Object -Property initiatedByUserPrincipalName, activityDateTime | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}