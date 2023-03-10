@{

    # Script module or binary module file associated with this manifest.
    # RootModule = 'AzureAdGovernanceAssessment.psm1'

    # Version number of this module.
    ModuleVersion     = '4.0'

    # Supported PSEditions
    # CompatiblePSEditions = @('Desktop')

    # ID used to uniquely identify this module
    GUID              = 'd5ed2d45-5210-4ed4-802b-45ad40c65b58'

    # Author of this module
    Author            = 'Microsoft Identity'

    # Company or vendor of this module
    CompanyName       = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright         = '(c) 2023 Microsoft Corporation. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'The module is used to run an Azure AD Guest user governance assessment.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        @{
            ModuleName    = 'Microsoft.Graph.Authentication'
            ModuleVersion = '1.1.0'
        }
        @{
            ModuleName    = 'MicrosoftTeams'
            ModuleVersion = '4.9.3'
        }
        @{
            ModuleName    = 'Microsoft.Online.SharePoint.PowerShell'
            ModuleVersion = '16.0.23311.12000'
        }
    )

    # Assemblies that must be loaded prior to importing this module
    #RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules     = @(
        '.\internal\Assert-Module.ps1',
        '.\internal\Assert-DirectoryExists.ps1',
        '.\internal\ConvertFrom-QueryString.ps1',
        '.\internal\ConvertTo-QueryString.ps1',
        '.\internal\Export-WorkshopReportGuestSettings.ps1',
        '.\internal\Export-WorkshopReports.ps1',
        '.\internal\Export-WorkshopReportServicePrincipals.ps1',
        '.\internal\Export-WorkshopReportTenantDetails.ps1',
        '.\internal\Export-WorkshopReportUserAppRoleAssignments.ps1',
        '.\internal\Export-WorkshopReportUserAuditLogs.ps1',
        '.\internal\Export-WorkshopReportUserCaPolicyExclusions.ps1',
        '.\internal\Export-WorkshopReportUserDirectoryRoleAssignments.ps1',
        '.\internal\Export-WorkshopReportUsers.ps1',
        '.\internal\Export-WorkshopReportUserSignInLogs.ps1',
        '.\internal\Export-WorkshopReportUserTeamsAccess.ps1',
        '.\internal\Resolve-FullPath.ps1',
        '.\internal\Write-HostPrompt.ps1',
        '.\internal\Use-Progress.ps1',
        '.\Invoke-MSGovernanceDataCollection.ps1',
        '.\Get-MsGraphResult.ps1',
        '.\Initialize-MSGovernanceWorkshop.ps1'
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Initialize-MSGovernanceWorkshop',
        'Invoke-MSGovernanceDataCollection',
        'Get-MsGraphResult'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = 'Microsoft', 'Identity', 'Azure', 'AzureActiveDirectory', 'AzureAD', 'AAD', 'PSEdition_Desktop', 'Windows'

            # A URL to the license for this module.
            LicenseUri = 'https://raw.githubusercontent.com/AzureAD/AzureAD-Governance-Assessment/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/AzureAD/AzureAD-Governance-Assessment'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

