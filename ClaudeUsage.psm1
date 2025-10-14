# ============================================
# ClaudeUsage PowerShell Module
# Query Claude Code usage programmatically
# ============================================

function Get-ClaudeUsage {
    <#
    .SYNOPSIS
    Query Claude Code usage information

    .DESCRIPTION
    Gets information about current usage windows:
    - Five-hour window: resets_at, utilization
    - Seven-day window (if applicable)
    - Opus limits (if applicable)

    Automatically reads the token from ~/.claude/.credentials.json

    .PARAMETER Raw
    Returns the raw JSON response without formatting

    .PARAMETER Token
    OAuth authentication token (optional, read automatically if not provided)

    .PARAMETER ShowAll
    Show all available limit windows (5-hour, 7-day, Opus, etc.)

    .PARAMETER Brief
    Show minimal one-line output: usage percentage and time remaining

    .EXAMPLE
    Get-ClaudeUsage
    Shows current usage formatted

    .EXAMPLE
    Get-ClaudeUsage -ShowAll
    Shows all available usage limits

    .EXAMPLE
    Get-ClaudeUsage -Brief
    54% | 3h 16m remaining

    .EXAMPLE
    Get-ClaudeUsage -Raw
    Returns the complete JSON object

    .EXAMPLE
    clau
    Short alias for Get-ClaudeUsage

    .LINK
    https://github.com/backmind/ClaudeUsage

    .NOTES
    Version: 1.1.0
    Author: Yass Fuentes
    Note: seven_day, seven_day_oauth_apps, and seven_day_opus limits
    are only available for Claude Max subscribers or enterprise accounts.
    #>

    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName='Raw')]
        [switch]$Raw,

        [Parameter(ParameterSetName='Default')]
        [switch]$ShowAll,

        [Parameter(ParameterSetName='Brief')]
        [switch]$Brief,

        [Parameter()]
        [string]$Token = $null
    )

    # If no token provided, try to read from config files
    if (-not $Token) {
        # Read token from Claude credentials file
        $credentialsPath = "$env:USERPROFILE\.claude\.credentials.json"

        if (Test-Path $credentialsPath) {
            try {
                $credentials = Get-Content $credentialsPath | ConvertFrom-Json

                if ($credentials.claudeAiOauth.accessToken) {
                    $Token = $credentials.claudeAiOauth.accessToken

                    # Check if token has expired
                    $expiresAt = $credentials.claudeAiOauth.expiresAt
                    if ($expiresAt) {
                        $expiryDate = [DateTimeOffset]::FromUnixTimeMilliseconds($expiresAt).LocalDateTime
                        if ((Get-Date) -gt $expiryDate) {
                            Write-Host "Warning: Token has expired. Please run:" -ForegroundColor Yellow
                            Write-Host "    claude setup-token" -ForegroundColor Cyan
                            Write-Host "  to renew your authentication." -ForegroundColor Yellow
                            return
                        }
                    }
                }
            } catch {
                Write-Host "Error reading credentials file:" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }

        # If token not found
        if (-not $Token) {
            Write-Host "Credentials file not found." -ForegroundColor Yellow
            Write-Host "Please run:" -ForegroundColor Yellow
            Write-Host "    claude setup-token" -ForegroundColor Cyan
            Write-Host "  to configure your authentication." -ForegroundColor Yellow
            return
        }
    }

    # API endpoint and headers
    $uri = "https://api.anthropic.com/api/oauth/usage"
    $headers = @{
        "Accept" = "application/json, text/plain, */*"
        "Content-Type" = "application/json"
        "User-Agent" = "claude-code/2.0.15"
        "Authorization" = "Bearer $Token"
        "anthropic-beta" = "oauth-2025-04-20"
    }

    try {
        # Make API request
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        if ($Raw) {
            return $response
        }

        # Brief mode: one-liner output
        if ($Brief) {
            if ($response.five_hour) {
                $utilization = $response.five_hour.utilization

                # Handle both string and DateTime objects
                if ($response.five_hour.resets_at -is [DateTime]) {
                    $resetsAt = $response.five_hour.resets_at.ToLocalTime()
                } else {
                    try {
                        $resetsAt = [DateTime]::ParseExact($response.five_hour.resets_at, "yyyy-MM-ddTHH:mm:ss.ffffffK", [System.Globalization.CultureInfo]::InvariantCulture).ToLocalTime()
                    } catch {
                        # Fallback to generic parse if format doesn't match
                        $resetsAt = ([DateTime]$response.five_hour.resets_at).ToLocalTime()
                    }
                }

                $timeRemaining = $resetsAt - (Get-Date)

                $color = if ($utilization -lt 50) { "Green" } elseif ($utilization -lt 80) { "Yellow" } else { "Red" }

                Write-Host "$utilization% " -NoNewline -ForegroundColor $color
                Write-Host "| " -NoNewline -ForegroundColor Gray
                Write-Host "$([Math]::Floor($timeRemaining.TotalHours))h $($timeRemaining.Minutes)m remaining" -ForegroundColor Cyan
                return
            } else {
                Write-Host "No usage data available" -ForegroundColor Yellow
                return
            }
        }

        # Helper function to display a usage window
        function Show-UsageWindow {
            param($WindowData, $WindowName)

            if (-not $WindowData) { return $null }

            # Handle both string and DateTime objects
            if ($WindowData.resets_at -is [DateTime]) {
                $resetsAt = $WindowData.resets_at.ToLocalTime()
            } else {
                try {
                    $resetsAt = [DateTime]::ParseExact($WindowData.resets_at, "yyyy-MM-ddTHH:mm:ss.ffffffK", [System.Globalization.CultureInfo]::InvariantCulture).ToLocalTime()
                } catch {
                    # Fallback to generic parse if format doesn't match
                    $resetsAt = ([DateTime]$WindowData.resets_at).ToLocalTime()
                }
            }

            $utilization = $WindowData.utilization
            $timeRemaining = $resetsAt - (Get-Date)

            Write-Host "  $WindowName Window:" -ForegroundColor White
            Write-Host "    Utilization: " -NoNewline -ForegroundColor Gray
            if ($utilization -lt 50) {
                Write-Host "$utilization%" -ForegroundColor Green
            } elseif ($utilization -lt 80) {
                Write-Host "$utilization%" -ForegroundColor Yellow
            } else {
                Write-Host "$utilization%" -ForegroundColor Red
            }

            Write-Host "    Next reset: " -NoNewline -ForegroundColor Gray
            Write-Host $resetsAt.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor Cyan

            Write-Host "    Time remaining: " -NoNewline -ForegroundColor Gray
            Write-Host "$([Math]::Floor($timeRemaining.TotalHours))h $($timeRemaining.Minutes)m" -ForegroundColor Magenta
            Write-Host ""
        }

        # Display header
        Write-Host "`n============================================" -ForegroundColor Cyan
        Write-Host "       Claude Code - Usage Status" -ForegroundColor Cyan
        Write-Host "============================================`n" -ForegroundColor Cyan

        $results = @()

        # Always show 5-hour window (primary limit)
        if ($response.five_hour) {
            Show-UsageWindow -WindowData $response.five_hour -WindowName "5-Hour" | Out-Null
        } else {
            Write-Host "  No 5-hour window information available" -ForegroundColor Yellow
        }

        # Show additional windows if -ShowAll or if they have data
        if ($ShowAll -or $response.seven_day) {
            if ($response.seven_day) {
                Show-UsageWindow -WindowData $response.seven_day -WindowName "7-Day" | Out-Null
            } elseif ($ShowAll) {
                Write-Host "  7-Day Window: Not available (requires Claude Max)" -ForegroundColor DarkGray
                Write-Host ""
            }
        }

        if ($ShowAll -or $response.seven_day_oauth_apps) {
            if ($response.seven_day_oauth_apps) {
                Show-UsageWindow -WindowData $response.seven_day_oauth_apps -WindowName "7-Day OAuth Apps" | Out-Null
            } elseif ($ShowAll) {
                Write-Host "  7-Day OAuth Apps: Not available" -ForegroundColor DarkGray
                Write-Host ""
            }
        }

        if ($ShowAll -or $response.seven_day_opus) {
            if ($response.seven_day_opus) {
                Show-UsageWindow -WindowData $response.seven_day_opus -WindowName "7-Day Opus" | Out-Null
            } elseif ($ShowAll) {
                Write-Host "  7-Day Opus: Not available (requires Claude Max)" -ForegroundColor DarkGray
                Write-Host ""
            }
        }

    } catch {
        Write-Host "Error querying Claude usage:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red

        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Host "`nToken appears to be invalid. Please verify it's correct." -ForegroundColor Yellow
        }
    }
}

# Export function
Export-ModuleMember -Function Get-ClaudeUsage
