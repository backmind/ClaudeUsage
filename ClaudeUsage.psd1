@{
    # Module metadata
    ModuleVersion = '1.1.1'
    GUID = 'a8b9c0d1-e2f3-4a5b-6c7d-8e9f0a1b2c3d'
    Author = 'Yass Fuentes'
    CompanyName = ''
    Copyright = '(c) 2025. All rights reserved.'
    Description = 'Query Claude Code usage programmatically from PowerShell. Monitor 5-hour, 7-day, and Opus usage limits.'

    # Module file
    RootModule = 'ClaudeUsage.psm1'

    # Minimum PowerShell version
    PowerShellVersion = '5.1'

    # Functions to export
    FunctionsToExport = @('Get-ClaudeUsage')

    # Cmdlets to export
    CmdletsToExport = @()

    # Variables to export
    VariablesToExport = '*'

    # Aliases to export
    AliasesToExport = @()

    # Private data
    PrivateData = @{
        PSData = @{
            # Tags for PowerShell Gallery
            Tags = @('Claude', 'ClaudeCode', 'AI', 'Anthropic', 'Usage', 'Monitoring', 'API', 'CLI')

            # License URI
            LicenseUri = 'https://github.com/backmind/ClaudeUsage/blob/main/LICENSE'

            # Project URI
            ProjectUri = 'https://github.com/backmind/ClaudeUsage'

            # Icon URI
            # IconUri = ''

            # Release notes
            ReleaseNotes = @'
Version 1.1.0:
- Added -Brief paramater to show onliner information for 5h window
- Added -ShowAll parameter to display all available usage windows
- Support for 7-day, Opus, and OAuth app limits (Claude Max)
- Improved formatting and color-coding
- Full English translation
- Better error handling

Version 1.0.0:
- Initial release
- Basic 5-hour window usage query
- Automatic token reading from credentials file
'@
        }
    }
}
