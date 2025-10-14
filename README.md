# ClaudeUsage

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/ClaudeUsage?label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/ClaudeUsage)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)

Query Claude Code usage programmatically from PowerShell. Monitor your 5-hour, 7-day, and Opus usage limits directly from your terminal.

## Features

✅ **Automatic token reading** from `~/.claude/.credentials.json`
✅ **Token expiration checking**
✅ **Multiple output modes**: Default, Brief, ShowAll, Raw
✅ **Color-coded utilization**: Green (<50%), Yellow (50-80%), Red (>80%)
✅ **Detailed information**: utilization, next reset time, time remaining
✅ **Claude Max support**: 7-day, Opus, and OAuth app limits
✅ **Cross-platform**: Windows, macOS, Linux

## Installation

### From PowerShell Gallery (coming soon)

```powershell
Install-Module -Name ClaudeUsage -Scope CurrentUser
```

### Manual Installation

```powershell
# Clone or download the repository
git clone https://github.com/backmind/ClaudeUsage.git

# Copy to your PowerShell modules directory
Copy-Item -Path .\ClaudeUsage -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\" -Recurse

# Import the module
Import-Module ClaudeUsage
```

## Usage

### Basic Usage

```powershell
# Full formatted output
Get-ClaudeUsage
```

**Output:**
```
============================================
       Claude Code - Usage Status
============================================

  5-Hour Window:
    Utilization: 54%
    Next reset: 2025-10-15 00:00:00
    Time remaining: 3h 16m
```

### Brief Mode (One-liner)

```powershell
# Minimal output
Get-ClaudeUsage -Brief
```

**Output:**
```
54% | 3h 16m remaining
```

Perfect for status bars, prompts, or quick checks!

### Show All Limits

```powershell
# Display all available usage windows (Claude Max)
Get-ClaudeUsage -ShowAll
```

**Output:**
```
============================================
       Claude Code - Usage Status
============================================

  5-Hour Window:
    Utilization: 54%
    Next reset: 2025-10-15 00:00:00
    Time remaining: 3h 16m

  7-Day Window: Not available (requires Claude Max)

  7-Day OAuth Apps: Not available

  7-Day Opus: Not available (requires Claude Max)
```

### Raw JSON Output

```powershell
# Get the raw API response
Get-ClaudeUsage -Raw
```

**Output:**
```json
{
  "five_hour": {
    "utilization": 96,
    "resets_at": "2025-10-14T22:00:00.111065+00:00"
  },
  "seven_day": null,
  "seven_day_oauth_apps": null,
  "seven_day_opus": null
}
```

Perfect for scripting, piping to other tools, or saving to a file!

### With Custom Token

```powershell
# Use a specific token
Get-ClaudeUsage -Token "sk-ant-oat01-..."
```

## Creating an Alias

Add to your PowerShell profile (`$PROFILE`):

```powershell
# Import module
Import-Module ClaudeUsage

# Create short alias
Set-Alias -Name clau -Value Get-ClaudeUsage
```

Then use it:

```powershell
clau          # Full output
clau -Brief   # One-liner
clau -ShowAll # All limits
```

## Integration Examples

### In Your PowerShell Prompt

Add Claude usage to your prompt:

```powershell
function prompt {
    $usage = (Get-ClaudeUsage -Brief).Utilization
    Write-Host "[$usage%] " -NoNewline -ForegroundColor $(if ($usage -lt 50) { "Green" } elseif ($usage -lt 80) { "Yellow" } else { "Red" })
    "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}
```

### Automated Monitoring Script

```powershell
# Check usage every hour and alert if >80%
while ($true) {
    $result = Get-ClaudeUsage -Brief
    if ($result.Utilization -gt 80) {
        Write-Host "WARNING: Claude usage at $($result.Utilization)%!" -ForegroundColor Red
    }
    Start-Sleep -Seconds 3600
}
```

## Requirements

- PowerShell 5.1 or higher
- Claude Code CLI installed and authenticated (`claude setup-token`)
- Active Claude Pro or Max subscription

## How It Works

The module:

1. Reads your OAuth token from `~/.claude/.credentials.json`
2. Checks if the token has expired
3. Queries the Anthropic API endpoint: `https://api.anthropic.com/api/oauth/usage`
4. Parses and displays usage information

## Troubleshooting

### "Credentials file not found"

Run `claude setup-token` to authenticate Claude Code.

### "Token has expired"

Run `claude setup-token` again to renew your authentication.

### Module not loading

Verify the module is in your PowerShell module path:

```powershell
$env:PSModulePath -split ';'
```

### Still having issues?

Open an [issue](https://github.com/backmind/ClaudeUsage/issues) with:
- Your PowerShell version: `$PSVersionTable`
- Error message (if any)
- Steps to reproduce

## API Response Structure

The API returns:

```json
{
  "five_hour": {
    "resets_at": "2025-10-15T00:00:00.034642+00:00",
    "utilization": 54
  },
  "seven_day": null,
  "seven_day_oauth_apps": null,
  "seven_day_opus": null
}
```

**Note:** `seven_day`, `seven_day_oauth_apps`, and `seven_day_opus` are only available for Claude Max subscribers or enterprise accounts, not my case!

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

Areas we especially need help with:
- Claude Max features testing (7-day limits, Opus limits)
- Cross-platform testing (macOS, Linux)
- Documentation and examples

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Built with reverse engineering of Anthropic's API
- Inspired by the need for programmatic usage monitoring
- Community-driven development

## Disclaimer

This is an unofficial module and is not affiliated with or endorsed by Anthropic. Use at your own risk.

---

**Star ⭐ this repo if you find it useful!**
