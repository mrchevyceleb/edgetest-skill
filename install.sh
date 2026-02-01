#!/bin/bash
# /edgetest skill installation script for macOS/Linux

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  /edgetest - Claude Code Skill Installer"
echo "  Comprehensive Edge Case Testing with Auto-Fix & Production Deploy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo "❌ Claude Code CLI not found"
    echo "   Please install Claude Code first: https://github.com/anthropics/claude-code"
    exit 1
fi
echo "✅ Claude Code CLI found"

# Check if ~/.claude/commands directory exists
COMMANDS_DIR="$HOME/.claude/commands"
if [ ! -d "$COMMANDS_DIR" ]; then
    echo "📁 Creating ~/.claude/commands directory..."
    mkdir -p "$COMMANDS_DIR"
fi
echo "✅ Commands directory ready"

# Download skill file
echo
echo "📥 Downloading /edgetest skill..."

REPO_URL="https://raw.githubusercontent.com/mrchevyceleb/edgetest-skill/main/edgetest.md"
SKILL_FILE="$COMMANDS_DIR/edgetest.md"

if curl -fsSL "$REPO_URL" -o "$SKILL_FILE"; then
    echo "✅ Skill file downloaded"
else
    echo "❌ Failed to download skill file"
    echo "   Please check your internet connection and try again"
    exit 1
fi

# Verify file was downloaded
if [ ! -f "$SKILL_FILE" ]; then
    echo "❌ Skill file not found after download"
    exit 1
fi

FILE_SIZE=$(wc -c < "$SKILL_FILE")
if [ "$FILE_SIZE" -lt 1000 ]; then
    echo "❌ Downloaded file appears to be incomplete (too small)"
    exit 1
fi

echo "✅ Skill file verified ($(numfmt --to=iec-i --suffix=B $FILE_SIZE))"

# Success message
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📍 Skill installed to: $SKILL_FILE"
echo
echo "📝 Next Steps:"
echo "   1. Restart Claude Code to load the skill"
echo "   2. Ensure Playwright MCP is configured:"
echo "      See: https://github.com/modelcontextprotocol/servers/tree/main/src/playwright"
echo "   3. Run your first edge case test:"
echo "      /edgetest https://your-app.vercel.app"
echo
echo "📚 Documentation:"
echo "   - README: https://github.com/mrchevyceleb/edgetest-skill"
echo "   - Full guide in skill file: $SKILL_FILE"
echo
echo "🎉 Happy testing!"
echo
