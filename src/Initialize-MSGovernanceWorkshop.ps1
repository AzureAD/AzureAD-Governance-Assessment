function Initialize-MSGovernanceWorkshop {
    [CmdletBinding()]
    param
    (
    
    )
    process {
        try {
            try {
                ## Install Required Modules
                
                #Install-Module 'Microsoft.Graph.Authentication' -MinimumVersion 1.1.0 -Force -AllowClobber -ErrorAction Stop -WarningAction SilentlyContinue 
                #Install-Module 'Microsoft.Online.SharePoint.PowerShell' -MinimumVersion 16.0.20616.12000 -Force -AllowClobber -ErrorAction Stop -WarningAction SilentlyContinue
                #Install-Module 'MicrosoftTeams' -MinimumVersion 1.1.6 -Force -AllowClobber -ErrorAction Stop -WarningAction SilentlyContinue

                assert-module -moduleName 'Microsoft.Graph.Authentication' -minmoduleVersion 1.1.0
                assert-module -moduleName 'Microsoft.Online.SharePoint.PowerShell' -minmoduleVersion 16.0.20616.12000
                assert-module -moduleName 'MicrosoftTeams' -minmoduleVersion 1.1.6

                ## Import Module
                Import-Module 'Microsoft.Graph.Authentication' -MinimumVersion 1.1.0 -Force -ErrorAction Stop
                Import-Module 'Microsoft.Online.SharePoint.PowerShell' -MinimumVersion 16.0.20616.12000 -DisableNameChecking -Force -ErrorAction Stop
                Import-Module 'MicrosoftTeams' -MinimumVersion 1.1.6 -Force -ErrorAction Stop

                ## Extract PowerShell Module
                #Write-Host 'Extracting MSGovernanceWorkshop PowerShell Module...'
                #Expand-Archive "$PSScriptRoot/MSGovernanceWorkshopModule.zip" -DestinationPath $PSScriptRoot -Force -ErrorAction Stop
                #Import-Module "$PSScriptRoot/MSGovernanceWorkshop" -Force -ErrorAction Stop
            }
            catch { Write-Error $_ }

            ## Collection Tenant Data
            Write-Host 'Execute MSGovernanceWorkshop Data Collection...'
            Invoke-MSGovernanceDataCollection -Prompt # This will prompt the user for OutputDirectory. Add the -Prompt parameter to confirm optional sections for data collection.

            # Or provide the values when executing the command
            #Invoke-MSGovernanceDataCollection -TenantName '<TenantName>' -TenantId '<TenantId>' -OutputDirectory "$PSScriptRoot/MSGovernanceWorkshopOutput"
        }
        finally {
            Write-Host "Press any key to continue..."
            $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }

    }    
}






















#Initialize-MSGovernanceWorkshop

