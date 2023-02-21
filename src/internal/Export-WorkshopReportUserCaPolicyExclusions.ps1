function Export-WorkshopReportUserCaPolicyExclusions {
    [CmdletBinding()]
    param
    (
        # Data Directory
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DataDirectory,
        # User data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $UserData = '.\Users.xml',
        # Conditional Access Policy data or file path
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [object] $ConditionalAccessPolicyData = '.\ConditionalAccessPolicies.xml',
        # Report output file
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $OutputPath = '.\Reports\UserConditionalAccessPolicyExclusions.csv'
    )

    process {
        Write-Verbose 'Generating Workshop Report: User Conditional Access Policy Exclusions'
        if ($UserData -is [string]) { $UserData = Import-Clixml (Resolve-FullPath $UserData $DataDirectory -ErrorAction Stop) }
        if ($ConditionalAccessPolicyData -is [string]) { $ConditionalAccessPolicyData = Import-Clixml (Resolve-FullPath $ConditionalAccessPolicyData $DataDirectory -ErrorAction Stop) }

        [object[]] $OutputAttributes = @(
            'userId', 'userPrincipalName', 'userDisplayName', 'userType'
            'id', 'displayName'
            'state'
        )

        $listConditionalAccessPolicy = New-Object System.Collections.Generic.List[pscustomobject]
        #$UserIds = $UserData.id
        foreach ($Policy in $ConditionalAccessPolicyData) {
            foreach ($ExcludeUserId in $Policy.conditions.users.excludeUsers) {
                # if ($UserIds.contains($ExcludeUserId)) {
                #     $listConditionalAccessPolicy.Add($Policy)
                #     break
                # }

                foreach ($User in $UserData) {
                    if ($User.id -eq $ExcludeUserId) {
                        $NewPolicyEntry = $Policy.PsObject.Copy()
                        $NewPolicyEntry | Add-Member 'userId' -MemberType NoteProperty -Value $User.id
                        $NewPolicyEntry | Add-Member 'userPrincipalName' -MemberType NoteProperty -Value $User.userPrincipalName
                        $NewPolicyEntry | Add-Member 'userDisplayName' -MemberType NoteProperty -Value $User.displayName
                        $NewPolicyEntry | Add-Member 'userType' -MemberType NoteProperty -Value $User.userType
                        $listConditionalAccessPolicy.Add($NewPolicyEntry)
                        break
                    }
                }
            }
        }
        
        $OutputPath = Join-Path $DataDirectory $OutputPath
        Assert-DirectoryExists (Split-Path $OutputPath) | Out-Null
        $listConditionalAccessPolicy.ToArray() | Select-Object -Property $OutputAttributes | Export-Csv -Path $OutputPath -NoTypeInformation
    }
}