<#
.SYNOPSIS
    Checks whether the required version of a module is installed and if not, installs that module
.DESCRIPTION

.EXAMPLE
    PS assert-module -modulename Microsoft.Graph.Authentication -minmoduleversion 1.1.0
.INPUTS
    System.String
    System.Version   
 #>
function assert-module {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] 
        [string] $moduleName,
        [Parameter(Mandatory = $false)] 
        [string] $minmoduleVersion
    )
    process {
        $notinstalled = $true
        
        $minversion = New-Object -TypeName System.Version -ArgumentList $minmoduleversion
        $module = get-module $moduleName -ListAvailable

        if ($null -ne $module) {     
            if ($module.version.CompareTo($minversion) -ge 0 ) {
                $notinstalled = $false
            }
            else {
                $notinstalled = $true
            }
        }

        if ($notinstalled) {   
            Install-Module $moduleName -MinimumVersion $minversion -force -AllowClobber -ErrorAction Stop -WarningAction SilentlyContinue 
        } 
    }
}