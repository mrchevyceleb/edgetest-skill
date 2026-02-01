# /edgetest - Comprehensive Edge Case Testing for Claude Code

**Automated edge case testing with auto-fix loop and production deployment verification**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blue)](https://github.com/anthropics/claude-code)

---

## Overview

`/edgetest` is a Claude Code skill that automatically discovers, tests, and fixes edge cases in web applications. Unlike traditional testing tools, it:

- 🔍 **Auto-discovers** edge cases across 8 categories
- 🔧 **Auto-fixes** failures with intelligent root cause analysis
- 🚀 **Deploys to production** and retests in live environment
- 🤖 **Spawns background agents** for complex issues
- ✅ **Requires 100% pass** (binary, not scored)
- 🔐 **Handles authentication** automatically with session restoration

---

## Features

### 8 Edge Case Categories

1. **Input Validation** - SQL injection, XSS, Unicode, max length, special chars
2. **Data States** - Empty, single item, pagination, large datasets, missing fields
3. **Network/API Errors** - 404, 500, timeouts, rate limits, CORS, offline
4. **UI/Interaction** - Rapid clicks, double submit, back button, resize, focus/blur
5. **Auth/Authorization** - Session expiry, invalid tokens, permission changes
6. **Browser/Device** - Mobile/tablet/desktop, zoom, dark mode, navigation
7. **Timing/Race Conditions** - Delayed scripts, concurrent calls, stale data
8. **Boundary Values** - Min/max, off-by-one, zero, negative, decimals

### Auto-Fix Loop

When a test fails:
1. Analyzes root cause
2. Implements fix
3. Validates build
4. **Deploys to production**
5. **Retests in live environment**
6. Repeats up to 3 times
7. Creates background task if unresolved

### Authentication Handling

- **First run:** Prompts user to login, saves session automatically
- **Subsequent runs:** Restores session (localStorage, sessionStorage, cookies)
- **Session expiry:** Detects 401/403, prompts for re-auth, saves new session
- **Secure:** Session files gitignored, stored locally only

---

## Installation

### Prerequisites

1. **[Claude Code CLI](https://github.com/anthropics/claude-code)** installed
2. **[Playwright MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/playwright)** configured
3. **Git** repository initialized
4. **Deployment platform** (Vercel, Railway, or custom)

### Quick Install

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/mrchevyceleb/edgetest-skill/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
iwr -useb https://raw.githubusercontent.com/mrchevyceleb/edgetest-skill/main/install.ps1 | iex
```

### Manual Install

1. **Download the skill file:**
   ```bash
   curl -o ~/.claude/commands/edgetest.md https://raw.githubusercontent.com/mrchevyceleb/edgetest-skill/main/edgetest.md
   ```

2. **Restart Claude Code** to load the skill

3. **Verify installation:**
   ```bash
   # The skill should appear in autocomplete
   /edgetest --help
   ```

---

## Usage

### Basic Syntax

```bash
/edgetest [focus] [url] [options]
```

### Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `focus` | Scope testing to specific feature (optional) | `email integration`, `payment flow` |
| `url` | Production URL to test (optional) | `https://myapp.vercel.app` |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--categories=cat1,cat2` | Test only specific categories | All 8 categories |
| `--severity=level` | Test only specific severity | All severities |
| `--max-fixes=N` | Max auto-fix attempts per test | 3 |
| `--skip-deploy` | Skip production deployment | false |
| `--config=path` | Custom edge case config file | None |

---

## Examples

### Example 1: Full App Testing

```bash
/edgetest https://myapp.vercel.app
```

**Result:** Tests entire app (~50-100 tests), auto-fixes failures, deploys to production

---

### Example 2: Focused Testing

```bash
/edgetest email integration https://myapp.vercel.app
```

**Result:** Tests only email-related features (~10-30 tests), faster iteration

---

### Example 3: Critical Tests Only

```bash
/edgetest --severity=critical
```

**Result:** Tests only CRITICAL edge cases (SQL injection, XSS, auth bypass, etc.)

---

### Example 4: Local Testing (No Deploy)

```bash
/edgetest --skip-deploy
```

**Result:** Tests edge cases locally without deploying to production

---

## How It Works

### Workflow

```
1. SCOPE DETECTION
   ↓ Determine full app vs focused testing

2. DISCOVERY
   ↓ Map forms, inputs, APIs, pages
   ↓ Generate ~10-100 edge case tests
   ↓ Prioritize by severity

3. SYSTEMATIC TESTING
   ↓ Execute tests with Playwright
   ↓ IF FAIL → Auto-Fix Loop

4. AUTO-FIX LOOP
   ↓ Analyze root cause
   ↓ Implement fix
   ↓ Validate build

5. PRODUCTION DEPLOYMENT
   ↓ Git commit + push
   ↓ Deploy (Vercel/Railway/custom)
   ↓ Wait 2 minutes

6. RE-TEST IN PRODUCTION
   ↓ Re-run failed test
   ↓ IF PASS → Next test
   ↓ IF FAIL (< 3 attempts) → Try different fix
   ↓ IF FAIL (>= 3 attempts) → Spawn background agent

7. COMPLETION
   ↓ Generate comprehensive report
```

---

## Comparison with Other Testing Tools

| Feature | /edgetest | /bigtest | /perfect | Jest | Playwright |
|---------|-----------|----------|----------|------|------------|
| **Focus** | Edge cases only | UI/UX audit | Feature impl | Unit tests | E2E tests |
| **Auto-discovery** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Auto-fix** | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Production deploy** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Auth handling** | ✅ Auto | Manual | Manual | Manual | Manual |
| **Pass criteria** | 100% binary | 0-100 score | 0-100 score | % coverage | Manual |

---

## Authentication

For apps requiring login, `/edgetest` handles authentication automatically:

### First Run
1. Navigate to app
2. Detect login requirement
3. **Prompt user to login**
4. Save session to `.edgetest/auth-session.json`
5. Proceed with testing

### Subsequent Runs
1. Navigate to app
2. **Auto-restore session** (no login needed!)
3. Proceed with testing

### Session Expiry
1. Detect 401/403 errors
2. Delete expired session
3. Prompt for re-auth
4. Save new session

**Security:** Session files are gitignored and stored locally only.

---

## Output

### Final Report

```markdown
===============================================================================
                      /EDGETEST EXECUTION REPORT
===============================================================================

APP: MyApp
PRODUCTION URL: https://myapp.vercel.app
STATUS: ✅ 100% PASSING

SUMMARY:
  Total Tests: 87
  Passed: 87 (100%)
  Failed: 0 (0%)

Auto-Fixes:
  ✅ Resolved: 12
  ⚠️  Background Tasks: 0

Deployments: 12
Total Execution Time: 1h 23m 15s

===============================================================================
```

---

## Configuration

### Custom Edge Cases

Create `edgetest-config.json`:

```json
{
  "categories": {
    "input": {
      "enabled": true,
      "customTests": [
        {
          "name": "Credit card validation",
          "input": "4111 1111 1111 1111",
          "expected": "Accepted or formatted"
        }
      ]
    }
  },
  "exclusions": [
    "/admin/*",
    "/debug/*"
  ]
}
```

Use:
```bash
/edgetest --config=edgetest-config.json
```

---

## Troubleshooting

### Issue: Playwright MCP not available

**Solution:**
```bash
# Check .mcp.json or ~/.claude.json for playwright config
# Restart Claude Code to reload MCPs
```

### Issue: Deployment not detected

**Solution:**
Add `vercel.json`, `railway.json`, or deploy script to `package.json`:
```json
{
  "scripts": {
    "deploy": "your-deploy-command"
  }
}
```

### Issue: Session expired

**Solution:**
```bash
# Delete session file to force fresh login
rm .edgetest/auth-session.json
```

---

## Best Practices

### 1. Run after implementing features

```bash
# Implement feature first
/perfect implement payment flow

# THEN test edge cases
/edgetest payment flow
```

### 2. Use focus parameter for faster iteration

```bash
# Focused testing (10-30 tests, faster)
/edgetest email integration

# Full app testing (50-100 tests, comprehensive)
/edgetest
```

### 3. Review background tasks promptly

After `/edgetest` completes, check `/tasks/` for background tasks and fix manually.

### 4. Combine with other skills

**Recommended workflow:**
1. `/perfect` - Implement feature (100/100 score)
2. `/edgetest` - Test edge cases (deploy fixes)
3. `/bigtest` - Full app audit (periodically)

---

## FAQ

### Q: How is /edgetest different from /bigtest?

**A:** `/bigtest` is a comprehensive UI/UX audit (0-100 score). `/edgetest` focuses ONLY on edge cases, auto-fixes failures, and deploys to production (100% binary pass).

### Q: Will it break my production app?

**A:** No. Each fix is build-validated, tested locally, and deployed incrementally. If re-test fails, the loop tries a different approach.

### Q: What if auto-fix doesn't work?

**A:** After 3 failed attempts, a background task is created with full context, attempted fixes, and recommended next steps.

### Q: Does it work with all frameworks?

**A:** Yes! Framework-agnostic (React, Vue, Angular, Svelte, etc.). Works with any web app accessible via URL.

---

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

### Development Setup

1. Clone the repository
2. Edit `edgetest.md` (the skill file)
3. Test locally by copying to `~/.claude/commands/edgetest.md`
4. Submit a pull request

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Support

- **Issues:** [GitHub Issues](https://github.com/mrchevyceleb/edgetest-skill/issues)
- **Discussions:** [GitHub Discussions](https://github.com/mrchevyceleb/edgetest-skill/discussions)
- **Documentation:** Full guide in `edgetest.md`

---

## Acknowledgments

- Built for [Claude Code CLI](https://github.com/anthropics/claude-code)
- Uses [Playwright MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/playwright) for browser automation
- Inspired by the need for comprehensive edge case testing in production apps

---

**Made with ❤️ by [Matt Johnston](https://github.com/mrchevyceleb)**

**Star ⭐ this repo if you find it useful!**
