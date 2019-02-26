#region Header
using module ..\helper.psm1
using module ..\..\PowerStig.psm1
#endregion Header

#region Composite

<#
    .SYNOPSIS
        A composite DSC resource to manage the IIS Site STIG settings
    .PARAMETER IisVersion
        The version of the IIS Stig to apply
    .PARAMETER WebsiteName
        Array of website names used for MimeTypeRule, WebConfigurationPropertyRule, and IisLoggingRule.
    .PARAMETER WebAppPool
        Array of web application pool names used for WebAppPoolRule
    .PARAMETER StigVersion
        The version of the IIS Site STIG version to apply and monitor
    .PARAMETER Exception
        A hashtable of StigId=Value key pairs that are injected into the STIG data and applied to
        the target node. The title of STIG settings are tagged with the text ‘Exception’ to identify
        the exceptions to policy across the data center when you centralize DSC log collection.
    .PARAMETER OrgSettings
        The path to the xml file that contains the local organizations preferred settings for STIG
        items that have allowable ranges.
    .PARAMETER SkipRule
        The SkipRule Node is injected into the STIG data and applied to the taget node. The title
        of STIG settings are tagged with the text 'Skip' to identify the skips to policy across the
        data center when you centralize DSC log collection.
    .PARAMETER SkipRuleType
        All STIG rule IDs of the specified type are collected in an array and passed to the Skip-Rule
        function. Each rule follows the same process as the SkipRule parameter.
#>
Configuration IisSite
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Version]
        $IisVersion,

        [Parameter(Mandatory = $true)]
        [String[]]
        $WebsiteName,

        [Parameter()]
        [String[]]
        $WebAppPool,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Version]
        $StigVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Exception,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $OrgSettings,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $SkipRule,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $SkipRuleType
    )

    ##### BEGIN DO NOT MODIFY #####
    $stig = [STIG]::New('IISSite', $IisVersion, $StigVersion)
    $stig.LoadRules($OrgSettings, $Exception, $SkipRule, $SkipRuleType)

    # $resourcePath is exported from the helper module in the header
    # Process Skipped rules
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    . "$resourcePath\windows.Script.skip.ps1"
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.3.0.0
    . "$resourcePath\windows.xWindowsFeature.ps1"

    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 2.5.0.0
    . "$resourcePath\windows.xWebSite.ps1"
    . "$resourcePath\windows.xWebAppPool.ps1"
    . "$resourcePath\windows.xIisMimeTypeMapping.ps1"
    . "$resourcePath\windows.xWebConfigProperty.ps1"
}

#endregion Composite
