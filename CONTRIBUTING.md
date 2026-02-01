# Contributing to /edgetest

Thank you for your interest in contributing to the `/edgetest` Claude Code skill! This document provides guidelines for contributions.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** first to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Claude Code version, etc.)
   - Screenshots/logs if applicable

### Suggesting Features

1. **Search existing feature requests** first
2. **Open a new discussion** in GitHub Discussions
3. Describe:
   - Use case and motivation
   - Proposed solution
   - Alternative approaches considered

### Submitting Code

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**:
   - Edit `edgetest.md` (the skill file)
   - Update README.md if needed
   - Add tests if applicable
4. **Test locally**:
   - Copy skill file to `~/.claude/commands/edgetest.md`
   - Test with sample apps
   - Verify all edge case categories work
5. **Commit with clear messages**:
   ```bash
   git commit -m "feat: add support for custom edge case categories"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request**

## Development Setup

### Prerequisites

- Claude Code CLI installed
- Playwright MCP configured
- Git repository for testing
- Test web app (for validation)

### Local Testing

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/edgetest-skill.git
   cd edgetest-skill
   ```

2. Copy skill file to Claude config:
   ```bash
   cp edgetest.md ~/.claude/commands/edgetest.md
   ```

3. Restart Claude Code

4. Test the skill:
   ```bash
   /edgetest https://your-test-app.vercel.app
   ```

## Code Style

### Skill File (`edgetest.md`)

- Use clear, descriptive section headers
- Include examples in code blocks
- Document all parameters and options
- Keep bash scripts portable (macOS/Linux/Windows)
- Use markdown formatting consistently

### README

- Keep examples practical and realistic
- Update feature list when adding capabilities
- Maintain comparison table accuracy
- Include screenshots for visual features

## Testing Guidelines

Before submitting a PR, test:

1. **Basic functionality**:
   - Full app testing
   - Focused testing with focus parameter
   - All 8 edge case categories

2. **Edge cases**:
   - Apps with authentication
   - Apps without authentication
   - Different deployment platforms (Vercel, Railway, custom)
   - Session restoration
   - Session expiry handling

3. **Error handling**:
   - Network failures
   - Build failures
   - Deployment failures
   - Invalid input

4. **Cross-platform**:
   - macOS
   - Linux
   - Windows

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Formatting, missing semicolons, etc.
- `refactor:` - Code change that neither fixes a bug nor adds a feature
- `test:` - Adding tests
- `chore:` - Maintenance

Examples:
```
feat: add custom edge case config support
fix: handle session expiry during testing
docs: update README with new examples
refactor: improve auto-fix root cause analysis
```

## Pull Request Guidelines

### Title

Use conventional commit format:
```
feat: add support for custom edge case categories
```

### Description

Include:
- **What:** Brief description of changes
- **Why:** Motivation and context
- **How:** Technical details (if complex)
- **Testing:** How you tested the changes
- **Breaking Changes:** If any (and migration guide)

### Checklist

- [ ] Code follows existing style
- [ ] All tests pass locally
- [ ] Documentation updated (README, skill file)
- [ ] Commit messages follow convention
- [ ] No breaking changes (or documented)
- [ ] Tested on multiple platforms (if applicable)

## Code of Conduct

Be respectful and constructive:
- Welcome newcomers
- Be patient with questions
- Focus on the issue, not the person
- Give and receive feedback gracefully

## Questions?

- **Documentation:** See README.md and edgetest.md
- **Discussions:** GitHub Discussions
- **Issues:** GitHub Issues
- **Direct contact:** Open a discussion first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing!** 🎉
