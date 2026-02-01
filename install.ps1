# /edgetest skill installation script for Windows (PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  /edgetest - Claude Code Skill Installer" -ForegroundColor Cyan
Write-Host "  Comprehensive Edge Case Testing with Auto-Fix & Production Deploy" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

# Check if Claude Code is installed
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Claude Code CLI not found" -ForegroundColor Red
    Write-Host "   Please install Claude Code first: https://github.com/anthropics/claude-code" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Claude Code CLI found" -ForegroundColor Green

# Check if ~/.claude/commands directory exists
$CommandsDir = "$env:USERPROFILE\.claude\commands"
if (-not (Test-Path $CommandsDir)) {
    Write-Host "📁 Creating ~/.claude/commands directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null
}
Write-Host "✅ Commands directory ready" -ForegroundColor Green

# Download skill file
Write-Host ""
Write-Host "📥 Downloading /edgetest skill..." -ForegroundColor Yellow

$RepoUrl = "https://raw.githubusercontent.com/mrchevyceleb/edgetest-skill/main/edgetest.md"
$SkillFile = "$CommandsDir\edgetest.md"

try {
    Invoke-WebRequest -Uri $RepoUrl -OutFile $SkillFile -UseBasicParsing
    Write-Host "✅ Skill file downloaded" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download skill file" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "   Please check your internet connection and try again" -ForegroundColor Red
    exit 1
}

# Verify file was downloaded
if (-not (Test-Path $SkillFile)) {
    Write-Host "❌ Skill file not found after download" -ForegroundColor Red
    exit 1
}

$FileSize = (Get-Item $SkillFile).Length
if ($FileSize -lt 1000) {
    Write-Host "❌ Downloaded file appears to be incomplete (too small)" -ForegroundColor Red
    exit 1
}

$FileSizeKB = [math]::Round($FileSize / 1KB, 2)
Write-Host "✅ Skill file verified ($FileSizeKB KB)" -ForegroundColor Green

# Success message
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  ✅ Installation Complete!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Skill installed to: $SkillFile" -ForegroundColor White
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Restart Claude Code to load the skill" -ForegroundColor White
Write-Host "   2. Ensure Playwright MCP is configured:" -ForegroundColor White
Write-Host "      See: https://github.com/modelcontextprotocol/servers/tree/main/src/playwright" -ForegroundColor White
Write-Host "   3. Run your first edge case test:" -ForegroundColor White
Write-Host "      /edgetest https://your-app.vercel.app" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Yellow
Write-Host "   - README: https://github.com/mrchevyceleb/edgetest-skill" -ForegroundColor White
Write-Host "   - Full guide in skill file: $SkillFile" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Happy testing!" -ForegroundColor Green
Write-Host ""
