# Changelog

All notable changes to the `/edgetest` skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-01

### Added
- **Core Features:**
  - Automated edge case discovery across 8 categories
  - Systematic testing with Playwright MCP integration
  - Auto-fix loop with root cause analysis
  - Production deployment after each fix
  - Re-testing in live environment
  - Background agent spawning for complex issues (after 3 failed attempts)
  - 100% pass requirement (binary pass/fail, not scored)

- **Edge Case Categories:**
  - Input Validation (SQL injection, XSS, Unicode, max length, etc.)
  - Data States (empty, pagination, large datasets, missing fields)
  - Network/API Errors (404, 500, timeouts, rate limits, CORS)
  - UI/Interaction (rapid clicks, double submit, back button, resize)
  - Auth/Authorization (session expiry, invalid tokens, permission changes)
  - Browser/Device (mobile/tablet/desktop, zoom, dark mode)
  - Timing/Race Conditions (delayed scripts, concurrent calls, stale data)
  - Boundary Values (min/max, off-by-one, zero, negative)

- **Authentication Handling:**
  - Automatic session restoration with interactive fallback
  - Session save to `.edgetest/auth-session.json`
  - localStorage, sessionStorage, and cookies capture
  - Session expiry detection (401/403) and recovery
  - Multi-user testing support (delete session between users)
  - Secure session storage (gitignored, local only)

- **Focus Parameter:**
  - Targeted testing for specific features/areas
  - AI-powered scope detection (identifies relevant components, pages, APIs)
  - Faster iteration (~10-30 tests vs ~50-100 for full app)

- **Deployment Integration:**
  - Auto-detection of deployment platform (Vercel, Railway, custom)
  - Git commit + push workflow
  - 2-minute wait for deployment + CDN propagation
  - Cache busting and hard refresh
  - Deployment history tracking

- **Reporting:**
  - Comprehensive final report with statistics
  - Tests by category breakdown
  - Fix history with root cause analysis
  - Background tasks documentation
  - Deployment history

- **Options:**
  - `--categories` - Test only specific categories
  - `--severity` - Test only specific severity level
  - `--max-fixes` - Customize max auto-fix attempts
  - `--skip-deploy` - Local testing only (no production deployment)
  - `--config` - Custom edge case configuration file

- **Documentation:**
  - Comprehensive README with examples
  - Installation scripts (Unix and Windows)
  - Contributing guidelines
  - MIT License
  - Full skill file with 6 phases of execution

### Fixed
- N/A (initial release)

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Security
- Session files gitignored to prevent committing auth tokens
- Session data stored locally only (not in memory system)
- Build validation before deployment to prevent broken deploys

---

## Release Notes

### v1.0.0 - Initial Release

This is the first public release of `/edgetest`, a comprehensive edge case testing skill for Claude Code.

**Key Highlights:**
- 🔍 Auto-discovers edge cases (no manual test writing)
- 🔧 Auto-fixes failures intelligently
- 🚀 Deploys to production and retests
- 🔐 Handles authentication automatically
- ✅ Requires 100% pass (no compromises)

**What makes it unique:**
- Only testing tool that deploys to production after each fix
- Only testing tool with automatic session restoration
- Only testing tool focused exclusively on edge cases
- Only testing tool with background agent spawning for complex issues

**Recommended workflow:**
1. Implement feature with `/perfect` (100/100 score)
2. Test edge cases with `/edgetest` (deploy fixes to production)
3. Periodically run `/bigtest` (comprehensive full-app audit)

**Get started:**
```bash
curl -fsSL https://raw.githubusercontent.com/mrchevyceleb/edgetest-skill/main/install.sh | bash
/edgetest https://your-app.vercel.app
```

---

[1.0.0]: https://github.com/mrchevyceleb/edgetest-skill/releases/tag/v1.0.0
