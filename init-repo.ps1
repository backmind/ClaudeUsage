# Initialize Git Repository for ClaudeUsage Module
# Run this script to create a Git repo and push to GitHub

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername,

    [Parameter()]
    [string]$RepoName = "ClaudeUsage"
)

Write-Host "Initializing ClaudeUsage Git Repository..." -ForegroundColor Cyan
Write-Host ""

# Navigate to module directory
$moduleDir = $PSScriptRoot
Set-Location $moduleDir

# Initialize git if not already initialized
if (-not (Test-Path ".git")) {
    Write-Host "[1/6] Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "      Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "[1/6] Git repository already exists" -ForegroundColor Gray
}

# Create initial commit
Write-Host "[2/6] Adding files to Git..." -ForegroundColor Yellow
git add .
git commit -m "Initial commit: ClaudeUsage PowerShell module v1.1.0

- Query Claude Code usage programmatically
- Support for 5-hour, 7-day, and Opus limits
- Brief, ShowAll, and Raw output modes
- Automatic token management
- Cross-platform support"

Write-Host "      Files committed" -ForegroundColor Green

# Set main branch
Write-Host "[3/6] Setting default branch to 'main'..." -ForegroundColor Yellow
git branch -M main
Write-Host "      Branch set to main" -ForegroundColor Green

# Update README and manifest with actual GitHub username
Write-Host "[4/6] Updating GitHub URLs..." -ForegroundColor Yellow

$readmePath = Join-Path $moduleDir "README.md"
$manifestPath = Join-Path $moduleDir "ClaudeUsage.psd1"

if (Test-Path $readmePath) {
    $readme = Get-Content $readmePath -Raw
    $readme = $readme -replace 'github\.com/yourusername/', "github.com/$GitHubUsername/"
    Set-Content -Path $readmePath -Value $readme -NoNewline
}

if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw
    $manifest = $manifest -replace 'github\.com/yourusername/', "github.com/$GitHubUsername/"
    Set-Content -Path $manifestPath -Value $manifest -NoNewline
}

git add README.md ClaudeUsage.psd1
git commit -m "Update GitHub URLs with username: $GitHubUsername" -ErrorAction SilentlyContinue

Write-Host "      URLs updated" -ForegroundColor Green

# Instructions for GitHub
Write-Host ""
Write-Host "[5/6] Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Create a new repository on GitHub:"
Write-Host "     https://github.com/new" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Repository name: $RepoName"
Write-Host "  3. Description: Query Claude Code usage programmatically from PowerShell"
Write-Host "  4. Make it public"
Write-Host "  5. DO NOT initialize with README, .gitignore, or license"
Write-Host ""
Write-Host "  6. Then run these commands:"
Write-Host ""
Write-Host "     git remote add origin https://github.com/$GitHubUsername/$RepoName.git" -ForegroundColor Cyan
Write-Host "     git push -u origin main" -ForegroundColor Cyan
Write-Host ""

# Offer to add remote automatically
Write-Host "[6/6] Add remote automatically? (y/n)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq 'y' -or $response -eq 'Y') {
    $remoteUrl = "https://github.com/$GitHubUsername/$RepoName.git"

    # Check if remote already exists
    $existingRemote = git remote get-url origin 2>$null
    if ($existingRemote) {
        Write-Host "      Remote 'origin' already exists: $existingRemote" -ForegroundColor Gray
        Write-Host "      To change it, run: git remote set-url origin $remoteUrl" -ForegroundColor Gray
    } else {
        git remote add origin $remoteUrl
        Write-Host "      Remote 'origin' added: $remoteUrl" -ForegroundColor Green
        Write-Host ""
        Write-Host "Now push with: git push -u origin main" -ForegroundColor Cyan
    }
} else {
    Write-Host "      Skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Repository initialization complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To publish to PowerShell Gallery:" -ForegroundColor Yellow
Write-Host "  1. Get an API key from https://www.powershellgallery.com/" -ForegroundColor Gray
Write-Host "  2. Run: Publish-Module -Name ClaudeUsage -NuGetApiKey YOUR_API_KEY" -ForegroundColor Cyan
Write-Host ""
