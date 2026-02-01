---
name: edgetest
description: Comprehensive edge case testing with auto-fix loop and production deployment
version: 1.0
author: Matt Johnston
tags: [testing, edge-cases, playwright, automation, production]
argument-hint: [focus] [url] [--options]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, ToolSearch, AskUserQuestion
---

# /edgetest - Comprehensive Edge Case Testing with Auto-Fix

**YOU ARE NOW IN EDGE CASE TESTING MODE.**

This skill performs comprehensive edge case testing with automatic fixing and production deployment verification. Unlike `/bigtest` (UI/UX audit) and `/perfect` (feature implementation), `/edgetest` focuses exclusively on **edge cases and error states** with production deployment after each fix.

## Core Capabilities

1. **Auto-Discovery** - Maps app structure to identify all testable surfaces
2. **Comprehensive Edge Case Generation** - 8 categories of edge case tests
3. **Systematic Testing** - Executes tests with Playwright MCP
4. **Auto-Fix Loop** - Analyzes failures and implements fixes
5. **Production Deployment** - Deploys each fix to production and retests
6. **Background Agent Spawning** - Creates tasks for complex issues
7. **100% Pass Requirement** - Loops until all tests pass or creates background tasks

---

## Command Syntax

```bash
/edgetest [focus] [url] [options]
```

### Arguments

**`focus`** (optional) - Scope testing to specific feature/area
- If **NOT specified** → Tests entire app (~50-100 tests)
- If **specified** → Tests only focused area (~10-30 tests)
- Examples: `email integration`, `payment flow`, `user authentication`, `dashboard widgets`

**`url`** (optional) - Production URL to test (defaults to localhost:3000)

### Options

- `--categories=cat1,cat2` - Test only specific categories (default: all)
- `--severity=level` - Test only specific severity (critical|high|medium|low, default: all)
- `--max-fixes=N` - Max auto-fix attempts per test (default: 3)
- `--skip-deploy` - Skip production deployment (test locally only)
- `--config=path` - Custom edge case config file

---

## Execution Flow Overview

```
START (/edgetest [focus] [url])
  ↓
PHASE 0: SCOPE DETECTION
• Determine if focus parameter provided
• Identify relevant components/pages/APIs
  ↓
PHASE 1: DISCOVERY
• Navigate to app
• Map pages, forms, inputs, data displays, APIs (scoped to focus if provided)
• Generate edge case tests (~10-100 depending on scope)
• Prioritize by severity
  ↓
PHASE 2: SYSTEMATIC TESTING
• Execute tests in priority order
• IF PASS → next test
• IF FAIL → GOTO PHASE 3
  ↓
PHASE 3: AUTO-FIX LOOP
• Analyze failure root cause
• Implement fix
• Validate build
• GOTO PHASE 4
  ↓
PHASE 4: PRODUCTION DEPLOYMENT
• Git commit + push
• Trigger deploy
• Wait for deployment + 2 min
• Clear cache
• GOTO PHASE 5
  ↓
PHASE 5: RE-TEST IN PRODUCTION
• Re-run failed test
• IF PASS → Mark fixed, GOTO PHASE 2
• IF FAIL (attempt < 3) → GOTO PHASE 3
• IF FAIL (attempt >= 3) → Spawn background agent, skip test
  ↓
PHASE 6: COMPLETION
• Generate comprehensive report
• List background tasks
  ↓
END
```

---

## PHASE 0: SCOPE DETECTION

**CRITICAL: Determine testing scope before discovery.**

### Step 0.1: Parse Focus Parameter

```bash
# If focus parameter provided
if [[ -n "$FOCUS" ]]; then
  SCOPE="focused"
  FOCUS_TEXT="$FOCUS"
else
  SCOPE="full-app"
  FOCUS_TEXT=""
fi
```

### Step 0.2: Identify Focus Scope (If Focused)

When `SCOPE=focused`, use AI analysis to identify:

1. **Relevant Pages/Routes**
   - Example: `focus="email integration"` → `/inbox`, `/send-email`, `/settings/email`

2. **Relevant Components**
   - Example: `EmailForm`, `EmailList`, `SendButton`, `EmailSettings`

3. **Relevant API Endpoints**
   - Example: `/api/email/send`, `/api/email/list`, `/api/email/delete`

4. **Relevant Files**
   - Example: `email.tsx`, `emailService.ts`, `email.api.ts`, `EmailForm.tsx`

**How to Identify:**
- Use Grep to search codebase for focus keywords
- Analyze route definitions for matching paths
- Identify components with matching names/props
- Find API endpoints with matching patterns

### Step 0.3: Report Scope

```markdown
SCOPE DETECTION COMPLETE

Scope: [FULL-APP | FOCUSED]
Focus: [focus text or "N/A"]

Identified Components:
- Pages: [list] or "All pages"
- Components: [list] or "All components"
- APIs: [list] or "All APIs"
- Files: [list] or "All files"

Estimated Tests: [10-30 for focused | 50-100 for full app]

Proceeding to discovery...
```

---

## PHASE 1: DISCOVERY

**CRITICAL: Map the app structure to generate comprehensive edge case tests.**

### Step 1.1: Load Playwright MCP

```bash
# Ensure Playwright MCP is available
# ToolSearch: "select:mcp__playwright__browser_navigate"
```

### Step 1.2: Navigate to App

```bash
# Navigate to production URL or localhost
mcp__playwright__browser_navigate to [URL]
```

### Step 1.2.5: Handle Authentication (If Required)

**CRITICAL: Many apps require authentication. Handle it automatically when possible, interactively when needed.**

**Check if authentication is required:**

```bash
# After navigating, check for login requirement
# Common indicators:
# - Redirected to /login, /signin, /auth
# - Login form visible
# - "Sign In" button present
# - localStorage/cookies missing auth tokens
```

**Session Restoration (Try First):**

```bash
SESSION_FILE="${PROJECT_DIR}/.edgetest/auth-session.json"

if [[ -f "$SESSION_FILE" ]]; then
  echo "Found saved session. Restoring authentication..."

  # Read saved session data
  SESSION_DATA=$(cat "$SESSION_FILE")

  # Restore session in browser
  mcp__playwright__browser_evaluate <<EOF
    const session = JSON.parse('${SESSION_DATA}');

    // Restore localStorage
    if (session.localStorage) {
      Object.keys(session.localStorage).forEach(key => {
        localStorage.setItem(key, session.localStorage[key]);
      });
    }

    // Restore sessionStorage
    if (session.sessionStorage) {
      Object.keys(session.sessionStorage).forEach(key => {
        sessionStorage.setItem(key, session.sessionStorage[key]);
      });
    }

    // Restore cookies (if applicable)
    if (session.cookies) {
      session.cookies.split(';').forEach(cookie => {
        document.cookie = cookie.trim();
      });
    }
EOF

  # Refresh page to apply authentication
  mcp__playwright__browser_navigate to [URL]

  # Wait a moment for auth to apply
  sleep 2

  # Verify authentication worked
  # Check for indicators like user menu, dashboard, etc.

  echo "✅ Session restored successfully"

else
  echo "No saved session found. First-time authentication required."
  SESSION_NEEDS_SAVE=true
fi
```

**Interactive Login (Fallback):**

If no saved session exists OR session restoration failed:

```bash
# Check if still on login page or see login form
IS_LOGGED_IN=$(mcp__playwright__browser_evaluate <<EOF
  // Check for common "logged in" indicators
  const hasUserMenu = document.querySelector('.user-menu, [data-testid="user-menu"], .profile-dropdown');
  const hasDashboard = document.querySelector('.dashboard, [data-testid="dashboard"]');
  const hasLogoutButton = document.querySelector('button:contains("Logout"), a:contains("Sign Out")');
  const noLoginForm = !document.querySelector('form[name="login"], form[action*="login"], input[name="password"]');

  !!(hasUserMenu || hasDashboard || hasLogoutButton || noLoginForm);
EOF
)

if [[ "$IS_LOGGED_IN" != "true" ]]; then
  # Need interactive login
  echo "Authentication required. Requesting user login..."

  AskUserQuestion: "Please login to the app in the browser window. I'll save your session for future /edgetest runs. Click 'Continue' when logged in."

  # Wait for user confirmation (implicit in AskUserQuestion response)

  # Verify login successful
  mcp__playwright__browser_wait_for selector=".user-menu, .dashboard, [data-testid='user-menu']" timeout=5000

  # Extract and save session for future use
  SESSION_DATA=$(mcp__playwright__browser_evaluate <<EOF
    JSON.stringify({
      localStorage: Object.fromEntries(Object.entries(localStorage)),
      sessionStorage: Object.fromEntries(Object.entries(sessionStorage)),
      cookies: document.cookie,
      url: window.location.href,
      timestamp: Date.now()
    })
EOF
  )

  # Save session to file
  mkdir -p "${PROJECT_DIR}/.edgetest"
  echo "$SESSION_DATA" > "$SESSION_FILE"

  echo "✅ Session saved to: $SESSION_FILE"
  echo "Future /edgetest runs will use this session automatically"

fi
```

**Session File Location:**

```
${PROJECT_DIR}/.edgetest/auth-session.json
```

**IMPORTANT:**
- `.edgetest/` folder is gitignored (contains sensitive session data)
- Session includes localStorage, sessionStorage, and cookies
- If session expires during testing, skill will prompt for re-authentication
- User can delete session file to force fresh login

**Session Expiry Handling:**

```bash
# During test execution, if 401/403 errors or redirected to login:
if [[ "$AUTH_FAILED" == "true" ]]; then
  echo "⚠️  Session expired during testing"

  # Delete expired session
  rm -f "$SESSION_FILE"

  # Prompt for re-authentication
  AskUserQuestion: "Your session expired. Please login again. I'll save the new session."

  # Follow same save process as above
fi
```

**Result:**

```markdown
AUTHENTICATION STATUS

Method: [Session Restored | Interactive Login]
Session File: [path]
Authenticated As: [extract from page if visible]
Ready to proceed: ✅

Proceeding to app structure discovery...
```

### Step 1.3: Discover App Structure (Scoped to Focus)

**Forms Discovery:**
- Find all `<form>` elements (within scope if focused)
- Extract input fields, validation rules, submit buttons
- Note: Login forms, contact forms, search forms, settings forms

**Input Discovery:**
- Find all input/textarea/select elements (within scope if focused)
- Identify types: text, email, number, date, file, etc.
- Note required/optional, min/max constraints

**Data Display Discovery:**
- Find tables, lists, cards, grids (within scope if focused)
- Note pagination, filters, sorting
- Identify empty states, loading states

**API Endpoint Discovery:**
- Check network tab for XHR/fetch requests (within scope if focused)
- Note endpoints, methods (GET/POST/DELETE), auth headers
- Monitor during form submission, data loading

**Navigation Discovery:**
- Map all pages/routes (within scope if focused)
- Note authentication requirements
- Identify protected routes

### Step 1.4: Generate Edge Case Tests

**CRITICAL: Generate tests across 8 categories, scoped to focus area if provided.**

For EACH discovered element (within scope):

#### Category 1: INPUT VALIDATION

**For each input field:**

| Test | Action | Expected | Severity |
|------|--------|----------|----------|
| Empty string | Submit with empty value | Validation error or safe handling | HIGH |
| Max length exceeded | Input 10,000 chars | Truncate or reject | MEDIUM |
| SQL injection | Input `'; DROP TABLE users; --` | Escaped or rejected | CRITICAL |
| XSS attempt | Input `<script>alert('xss')</script>` | Sanitized or escaped | CRITICAL |
| Unicode emoji | Input `👨‍👩‍👧‍👦 🎉` | Rendered correctly | LOW |
| Special chars | Input `!@#$%^&*()` | Handled correctly | MEDIUM |
| Leading/trailing spaces | Input `  value  ` | Trimmed or accepted | LOW |
| Only whitespace | Input `     ` | Rejected or handled | MEDIUM |
| Null bytes | Input `test\0value` | Rejected or sanitized | HIGH |
| Very long words | Input single word >1000 chars | Handled or wrapped | LOW |

#### Category 2: DATA STATES

**For each data display:**

| Test | Setup | Expected | Severity |
|------|-------|----------|----------|
| Empty state | Load with no data | Empty state message/UI | MEDIUM |
| Single item | Load with 1 item | No layout break | LOW |
| Exact page boundary | Load exactly 1 page of items | Pagination works | MEDIUM |
| Large dataset | Load 1000+ items | Pagination/virtualization works | HIGH |
| Missing fields | Load items with null/undefined fields | Graceful fallback | HIGH |
| Malformed data | Load invalid JSON/data | Error handling | HIGH |
| Duplicate keys | Load items with duplicate IDs | De-duped or handled | MEDIUM |

#### Category 3: NETWORK/API ERRORS

**For each API call:**

| Test | Simulate | Expected | Severity |
|------|----------|----------|----------|
| 404 Not Found | Mock 404 response | Error message shown | HIGH |
| 500 Server Error | Mock 500 response | Error message shown | CRITICAL |
| Timeout | Delay response 30+ seconds | Timeout error or loading state | HIGH |
| Rate limit | Mock 429 response | Rate limit message | MEDIUM |
| CORS error | Mock CORS failure | Error handled | MEDIUM |
| Network offline | Disable network | Offline message | HIGH |
| Slow network | Throttle to 2G speed | Loading states shown | LOW |
| Partial response | Mock incomplete JSON | Error handled | HIGH |
| Invalid auth | Mock 401 response | Redirect to login | CRITICAL |

#### Category 4: UI/INTERACTION

**For each interactive element:**

| Test | Action | Expected | Severity |
|------|--------|----------|----------|
| Rapid clicks | Click button 10x rapidly | Single action or debounced | HIGH |
| Double submit | Submit form twice quickly | Prevents duplicate | CRITICAL |
| Back button | Submit form, click back | State preserved or cleared | MEDIUM |
| Page refresh | Refresh mid-action | State lost gracefully | LOW |
| Resize window | Shrink to 320px width | Responsive layout works | MEDIUM |
| Focus/blur | Tab through inputs rapidly | Focus states correct | LOW |
| Right-click | Right-click on elements | Context menu or prevented | LOW |
| Drag/drop | Drag invalid elements | Rejected or handled | MEDIUM |

#### Category 5: AUTH/AUTHORIZATION

**For each protected route/action:**

| Test | Setup | Expected | Severity |
|------|-------|----------|----------|
| Session expired | Clear session mid-action | Redirect to login | CRITICAL |
| Logged out | Logout then access protected route | Redirect to login | CRITICAL |
| Invalid token | Use malformed JWT | Reject and redirect | CRITICAL |
| Expired token | Use expired JWT | Refresh or redirect | CRITICAL |
| Permission change | Remove permission mid-session | Access denied | HIGH |
| Concurrent login | Login from 2nd device | Handles gracefully | MEDIUM |

#### Category 6: BROWSER/DEVICE

**For each page:**

| Test | Setup | Expected | Severity |
|------|-------|----------|----------|
| Mobile viewport | Resize to 375px | Mobile layout works | HIGH |
| Tablet viewport | Resize to 768px | Tablet layout works | MEDIUM |
| Desktop viewport | Resize to 1920px | Desktop layout works | LOW |
| Zoom 200% | Browser zoom to 200% | Readable and usable | MEDIUM |
| Dark mode | Toggle OS dark mode | Dark theme works or graceful | LOW |
| Browser back/forward | Use browser navigation | State preserved | MEDIUM |
| Bookmark mid-flow | Bookmark during multi-step process | Graceful handling | LOW |

#### Category 7: TIMING/RACE CONDITIONS

**For each async operation:**

| Test | Setup | Expected | Severity |
|------|-------|----------|----------|
| Delayed script load | Delay React/app bundle | Loading state or error | HIGH |
| Concurrent API calls | Trigger multiple calls simultaneously | All resolve correctly | HIGH |
| Stale data | Load data, update elsewhere, refresh | Shows latest data | MEDIUM |
| Optimistic update fail | Update UI optimistically, API fails | Rolls back update | HIGH |
| Multiple tabs | Open app in 2 tabs, update in 1 | Other tab syncs or warns | LOW |

#### Category 8: BOUNDARY VALUES

**For each numeric/date input:**

| Test | Input | Expected | Severity |
|------|-------|----------|----------|
| Min value | Input minimum allowed | Accepted | MEDIUM |
| Max value | Input maximum allowed | Accepted | MEDIUM |
| Below min | Input min - 1 | Rejected | MEDIUM |
| Above max | Input max + 1 | Rejected | MEDIUM |
| Zero | Input 0 | Handled correctly | MEDIUM |
| Negative | Input -1 | Rejected or handled | MEDIUM |
| Decimal | Input 1.5 for integer field | Rounded or rejected | LOW |
| First item | Select first in list | Works correctly | LOW |
| Last item | Select last in list | Works correctly | LOW |

### Step 1.5: Prioritize Tests by Severity

```
CRITICAL > HIGH > MEDIUM > LOW
```

### Step 1.6: Output Test Plan

```markdown
EDGE CASE TEST PLAN GENERATED

Scope: [FULL-APP | FOCUSED: "focus text"]
Total Tests: [N]

Breakdown by Category:
  INPUT VALIDATION: [N] tests
  DATA STATES: [N] tests
  NETWORK/API ERRORS: [N] tests
  UI/INTERACTION: [N] tests
  AUTH/AUTHORIZATION: [N] tests
  BROWSER/DEVICE: [N] tests
  TIMING/RACE CONDITIONS: [N] tests
  BOUNDARY VALUES: [N] tests

Breakdown by Severity:
  CRITICAL: [N] tests
  HIGH: [N] tests
  MEDIUM: [N] tests
  LOW: [N] tests

Test Execution Order: CRITICAL → HIGH → MEDIUM → LOW

Proceeding to systematic testing...
```

---

## PHASE 2: SYSTEMATIC TESTING

**CRITICAL: Execute tests one by one, in priority order.**

### Step 2.1: Test Execution Loop

```
FOR EACH test IN prioritized_test_list:
  EXECUTE test
  EVALUATE result
  IF PASS:
    Log success
    Continue to next test
  ELSE IF FAIL:
    Log failure
    Capture screenshot
    GOTO PHASE 3 (Auto-Fix)
END FOR
```

### Step 2.2: Execute Single Test

**For EACH test:**

1. **Navigate to Test Location**
   ```bash
   mcp__playwright__browser_navigate to [test URL]
   ```

2. **Execute Test Steps**
   - Use Playwright MCP tools:
     - `browser_fill_form` for input
     - `browser_click` for buttons
     - `browser_type` for typing
     - `browser_wait_for` for async
     - `browser_network_requests` for API monitoring
     - `browser_console_messages` for errors

3. **Evaluate Acceptance Criteria**
   - Check expected behavior
   - Monitor console for errors
   - Verify no 500 errors
   - Confirm validation works
   - Check UI state

4. **Capture Evidence**
   ```bash
   mcp__playwright__browser_take_screenshot
   # Save to /temp/edgetest/test-[id]-[pass|fail].png
   ```

### Step 2.3: Log Test Result

```markdown
TEST: [Test Name]
CATEGORY: [Category]
SEVERITY: [Severity]
STATUS: [PASS | FAIL]
DURATION: [Xs]

DETAILS:
- Expected: [Description]
- Actual: [What happened]
- Console Errors: [List or "None"]
- Screenshot: [Path]

[If PASS: Continue to next test]
[If FAIL: Proceed to Phase 3]
```

---

## PHASE 3: AUTO-FIX LOOP

**CRITICAL: When a test fails, analyze and fix before continuing.**

### Step 3.1: Root Cause Analysis

**Analyze the failure:**

1. **Review Test Details**
   - What was the test trying to do?
   - What was expected?
   - What actually happened?

2. **Check Console Errors**
   - JavaScript errors?
   - React errors?
   - API errors?
   - Type errors?

3. **Review Screenshot**
   - UI broken?
   - Validation missing?
   - Error message missing?

4. **Identify Root Cause**
   - Input validation missing
   - Error handling missing
   - UI edge case not handled
   - API error not caught
   - Type safety issue
   - etc.

### Step 3.2: Implement Fix

**Based on root cause, implement the fix:**

1. **Find Relevant Files**
   ```bash
   # Use Grep/Glob to find files
   # Example: Find component with the form
   ```

2. **Read Current Code**
   ```bash
   # Read the file(s)
   ```

3. **Implement Fix**
   - Add validation
   - Add error handling
   - Add edge case check
   - Update UI logic
   - Fix type issue

4. **Example Fixes:**

   **Missing Input Validation:**
   ```typescript
   // BEFORE
   const handleSubmit = () => {
     api.send(formData.email);
   };

   // AFTER
   const handleSubmit = () => {
     if (!formData.email || !formData.email.trim()) {
       setError('Email is required');
       return;
     }
     if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
       setError('Invalid email format');
       return;
     }
     api.send(formData.email);
   };
   ```

   **Missing Error Handling:**
   ```typescript
   // BEFORE
   const fetchData = async () => {
     const res = await fetch('/api/data');
     const data = await res.json();
     setData(data);
   };

   // AFTER
   const fetchData = async () => {
     try {
       const res = await fetch('/api/data');
       if (!res.ok) {
         throw new Error(`HTTP ${res.status}: ${res.statusText}`);
       }
       const data = await res.json();
       setData(data);
     } catch (err) {
       setError('Failed to load data. Please try again.');
       console.error(err);
     }
   };
   ```

   **Missing Empty State:**
   ```typescript
   // BEFORE
   return (
     <ul>
       {items.map(item => <li>{item.name}</li>)}
     </ul>
   );

   // AFTER
   return (
     <ul>
       {items.length === 0 ? (
         <li className="empty-state">No items found.</li>
       ) : (
         items.map(item => <li>{item.name}</li>)
       )}
     </ul>
   );
   ```

### Step 3.3: Validate Build

**CRITICAL: Ensure the fix doesn't break the build.**

```bash
# Run build/type-check
npm run build || yarn build

# If build fails:
# - Review build errors
# - Fix type issues
# - Fix import errors
# - Re-validate

# Only proceed if build succeeds
```

### Step 3.4: Track Fix Attempt

```markdown
FIX ATTEMPT #[N] for Test: [Test Name]

ROOT CAUSE: [Description]
FILES MODIFIED: [List]
CHANGES:
- [Change 1]
- [Change 2]

BUILD VALIDATION: [PASS | FAIL]

[If PASS: Proceed to Phase 4]
[If FAIL: Fix build errors, re-validate]
```

---

## PHASE 4: PRODUCTION DEPLOYMENT

**CRITICAL: Deploy the fix to production and wait for it to go live.**

### Step 4.1: Git Commit & Push

```bash
# Commit the fix
git add .
git commit -m "fix: [edge case test name]

Auto-fixed by /edgetest
Test: [test-id]
Category: [category]
Severity: [severity]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Push to main
git push origin main
```

### Step 4.2: Detect Deployment Method

```bash
# Auto-detect deployment platform

if [[ -f "vercel.json" ]] || grep -q "vercel" package.json; then
  DEPLOY_METHOD="vercel"
  # Vercel auto-deploys on push to main

elif [[ -f "railway.json" ]] || [[ -f "railway.toml" ]]; then
  DEPLOY_METHOD="railway"
  # Railway auto-deploys on push

elif grep -q "\"deploy\"" package.json; then
  DEPLOY_METHOD="custom"
  # Run custom deploy script
  npm run deploy

else
  DEPLOY_METHOD="unknown"
  # Ask user how to deploy
  AskUserQuestion: "How should I deploy this app?"
fi
```

### Step 4.3: Wait for Deployment

```bash
# Wait for deployment to complete + buffer time
echo "Waiting for deployment to complete..."

# Deployment time + 2 min buffer for CDN propagation
sleep 120

echo "Deployment should be live. Proceeding to cache bust..."
```

### Step 4.4: Cache Bust & Hard Refresh

```bash
# Clear CDN cache if applicable
if [[ "$DEPLOY_METHOD" == "vercel" ]]; then
  # Vercel cache is auto-invalidated on deploy
  echo "Vercel cache auto-invalidated"
fi

# Hard refresh in browser
mcp__playwright__browser_navigate to [PRODUCTION_URL]
# Add cache-busting query param
mcp__playwright__browser_navigate to "[PRODUCTION_URL]?cachebust=$(date +%s)"
```

### Step 4.5: Log Deployment

```markdown
DEPLOYMENT #[N]

COMMIT: [commit hash]
METHOD: [vercel | railway | custom]
WAIT TIME: 2m 0s
PRODUCTION URL: [URL]

Proceeding to re-test in production...
```

---

## PHASE 5: RE-TEST IN PRODUCTION

**CRITICAL: Re-run the failed test in the live production environment.**

### Step 5.1: Re-Execute Test

```bash
# Re-run the EXACT same test that failed
# Use same steps, same inputs, same acceptance criteria
```

### Step 5.2: Evaluate Result

**IF TEST PASSES:**

```markdown
RE-TEST RESULT: ✅ PASS

Test: [Test Name]
Fix Attempt: #[N]
Status: RESOLVED
Total Fix Time: [Xm Ys]

Proceeding to next test...
```

**GOTO PHASE 2** (next test in queue)

---

**IF TEST FAILS (attempt < 3):**

```markdown
RE-TEST RESULT: ❌ FAIL (Attempt #[N])

Test: [Test Name]
Fix Attempt: #[N]
Status: Still failing

Analysis:
- Previous fix didn't resolve the issue
- Need different approach

Proceeding to another fix attempt...
```

**GOTO PHASE 3** (try different fix)

---

**IF TEST FAILS (attempt >= 3):**

```markdown
RE-TEST RESULT: ❌ FAIL (Attempt #3 - MAX REACHED)

Test: [Test Name]
Fix Attempts: 3 (all failed)
Status: BLOCKED

This edge case requires deeper investigation.
Spawning background agent...
```

**GOTO PHASE 5.3** (spawn background agent)

---

### Step 5.3: Spawn Background Agent (After 3 Failed Attempts)

**When a test fails 3 times, create a background task and continue.**

```bash
# Generate task file
TASK_FILE="/tasks/[Project] - Fix [Edge Case] - Due [+7 days].md"

cat > "$TASK_FILE" <<EOF
# Fix Edge Case: [Test Name]

## Context
- Test ID: [test-id]
- Category: [category]
- Severity: [severity]
- Status: ❌ BLOCKED after 3 auto-fix attempts

## Failure Description
[What the test does and what's failing]

## Expected Behavior
[What should happen]

## Actual Behavior
[What's actually happening]

## Evidence
- Screenshot: [path]
- Console Errors: [list]
- Network Errors: [list]

## Attempted Fixes (All Failed)

### Attempt 1
- Root Cause: [analysis]
- Fix: [what was changed]
- Files Modified: [list]
- Result: Still failing
- Commit: [hash]

### Attempt 2
- Root Cause: [analysis]
- Fix: [what was changed]
- Files Modified: [list]
- Result: Still failing
- Commit: [hash]

### Attempt 3
- Root Cause: [analysis]
- Fix: [what was changed]
- Files Modified: [list]
- Result: Still failing
- Commit: [hash]

## Suggested Next Steps
- [ ] [Recommendation 1]
- [ ] [Recommendation 2]
- [ ] [Recommendation 3]

## Full Test Definition

**Test Name:** [name]
**Category:** [category]
**Severity:** [severity]

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected:** [description]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

---

*Auto-generated by /edgetest on [date]*
EOF

echo "Background task created: $TASK_FILE"
```

**THEN:**

```markdown
BACKGROUND AGENT SPAWNED

Task File: [path]
Priority: [severity]
Issue: [test name]

Main test loop will continue with remaining tests.
This issue will be addressed separately.
```

**GOTO PHASE 2** (continue with next test, don't block)

---

## PHASE 6: COMPLETION

**CRITICAL: Generate comprehensive final report when all tests complete.**

### Step 6.1: Calculate Statistics

```
TOTAL_TESTS = [N]
PASSED_TESTS = [N]
FAILED_TESTS = [N]
FIXED_TESTS = [N]
BACKGROUND_TASKS = [N]
DEPLOYMENTS = [N]
```

### Step 6.2: Determine Final Status

```
IF FAILED_TESTS == 0:
  STATUS = "✅ 100% PASSING"
ELSE IF FAILED_TESTS > 0 AND BACKGROUND_TASKS == FAILED_TESTS:
  STATUS = "⚠️ PARTIAL (background tasks created)"
ELSE:
  STATUS = "❌ FAILED"
```

### Step 6.3: Generate Report

```markdown
===============================================================================
                      /EDGETEST EXECUTION REPORT
===============================================================================

APP: [App Name]
PRODUCTION URL: [URL]
SCOPE: [FULL-APP | FOCUSED: "focus text"]
TIMESTAMP: [YYYY-MM-DD HH:MM:SS]
STATUS: [STATUS]

===============================================================================
                              SUMMARY
===============================================================================

Total Tests: [TOTAL_TESTS]
  ✅ Passed: [PASSED_TESTS] ([percentage]%)
  ❌ Failed: [FAILED_TESTS] ([percentage]%)

Auto-Fixes:
  ✅ Resolved: [FIXED_TESTS]
  ⚠️  Background Tasks: [BACKGROUND_TASKS]

Deployments: [DEPLOYMENTS]
Total Execution Time: [Xh Ym Zs]

===============================================================================
                        TESTS BY CATEGORY
===============================================================================

INPUT VALIDATION ([N] tests)
  ✅ Empty string handling
  ✅ SQL injection attempt
  ⚠️  Unicode emoji (FIXED after 2 attempts)
  ✅ XSS attempt
  [... all tests in category]

DATA STATES ([N] tests)
  ✅ Empty state
  ⚠️  Large dataset (FIXED after 1 attempt)
  ❌ Rate limit UI (FAILED - background task #1)
  [... all tests in category]

NETWORK/API ERRORS ([N] tests)
  [... list]

UI/INTERACTION ([N] tests)
  [... list]

AUTH/AUTHORIZATION ([N] tests)
  [... list]

BROWSER/DEVICE ([N] tests)
  [... list]

TIMING/RACE CONDITIONS ([N] tests)
  [... list]

BOUNDARY VALUES ([N] tests)
  [... list]

===============================================================================
                           FIX HISTORY
===============================================================================

Fix #1: Unicode emoji rendering
  Test: Email field - Unicode emoji input
  Category: INPUT VALIDATION
  Severity: LOW
  Root Cause: Missing UTF-8 encoding in email display
  Files Modified:
    - src/components/UserCard.tsx
  Commit: abc123f
  Deployed: https://app.vercel.app
  Re-Test Result: ✅ PASS
  Fix Time: 3m 24s

Fix #2: Large dataset pagination
  Test: User list - 1000+ items
  Category: DATA STATES
  Severity: HIGH
  Root Cause: Missing pagination component
  Files Modified:
    - src/pages/UserList.tsx
    - src/components/Pagination.tsx (new)
  Commit: def456a
  Deployed: https://app.vercel.app
  Re-Test Result: ✅ PASS
  Fix Time: 5m 12s

[... all fixes]

===============================================================================
                        BACKGROUND TASKS
===============================================================================

Task #1: Rate limit error UI
  Test: API call - 429 rate limit response
  Category: NETWORK/API ERRORS
  Severity: HIGH
  Priority: HIGH
  Task File: /tasks/[Project] - Rate Limit UI - Due 2026-02-08.md

  Failed After 3 Attempts:
    Attempt 1: Added error state (still failing)
    Attempt 2: Updated API client (still failing)
    Attempt 3: Added retry logic (still failing)

  Recommended Next Steps:
    - Review API rate limit headers
    - Implement exponential backoff
    - Add rate limit UI indicator

Task #2: [...]

===============================================================================
                         DEPLOYMENTS
===============================================================================

1. abc123f - fix: Unicode emoji (deployed in 1m 34s)
2. def456a - fix: Large dataset pagination (deployed in 1m 28s)
3. [...]

Total Deployment Time: [Xm Ys]

===============================================================================
                          NEXT STEPS
===============================================================================

[If 100% passing:]
  ✅ All edge cases passing
  ✅ Production verified
  📝 Monitor for edge case issues in production

[If background tasks exist:]
  ⚠️  [N] tests require additional work
  📋 Complete background tasks:
      - /tasks/[Project] - Rate Limit UI - Due 2026-02-08.md
      - [...]
  🔄 Re-run /edgetest after completing background tasks

[If critical failures:]
  ❌ Critical edge cases failing
  🚨 Address immediately before production use

===============================================================================
                         DETAILED RESULTS
===============================================================================

[Full test-by-test breakdown if requested]

===============================================================================
```

### Step 6.4: Save Report

```bash
# Save report to file
REPORT_FILE="/temp/edgetest/edgetest-report-$(date +%Y%m%d-%H%M%S).md"
# Write report content

echo "Report saved: $REPORT_FILE"
```

### Step 6.5: Output Summary

```markdown
/EDGETEST COMPLETE

Status: [STATUS]
Tests: [PASSED]/[TOTAL] passing
Auto-Fixes: [FIXED_TESTS] deployed
Background Tasks: [BACKGROUND_TASKS]

Full Report: [REPORT_FILE]

[If 100% passing:]
  ✅ All edge cases verified in production!

[If background tasks:]
  ⚠️  Review background tasks and re-run /edgetest when ready.

[If failures:]
  ❌ Critical issues found. Address background tasks immediately.
```

---

## Edge Case Category Reference

### 1. INPUT VALIDATION
- Empty strings
- Max length exceeded
- SQL injection attempts
- XSS attempts
- Unicode/emoji
- Special characters
- Leading/trailing spaces
- Only whitespace
- Null bytes
- Very long single words

### 2. DATA STATES
- Empty state (no data)
- Single item
- Exact page boundary
- Large datasets (1000+ items)
- Missing fields (null/undefined)
- Malformed data
- Duplicate keys/IDs

### 3. NETWORK/API ERRORS
- 404 Not Found
- 500 Server Error
- Timeout (30+ seconds)
- Rate limit (429)
- CORS errors
- Network offline
- Slow network (2G)
- Partial/incomplete response
- Invalid authentication (401)

### 4. UI/INTERACTION
- Rapid clicks (10+ rapid)
- Double form submit
- Browser back button
- Page refresh mid-action
- Window resize
- Focus/blur rapid changes
- Right-click actions
- Drag/drop invalid elements

### 5. AUTH/AUTHORIZATION
- Session expired mid-action
- User logged out
- Invalid JWT token
- Expired JWT token
- Permission removed mid-session
- Concurrent login from 2nd device

### 6. BROWSER/DEVICE
- Mobile viewport (375px)
- Tablet viewport (768px)
- Desktop viewport (1920px)
- Browser zoom (200%)
- Dark mode toggle
- Browser back/forward navigation
- Bookmark mid-flow

### 7. TIMING/RACE CONDITIONS
- Delayed script load
- Concurrent API calls
- Stale data on refresh
- Optimistic update + API failure
- Multiple tabs open

### 8. BOUNDARY VALUES
- Minimum value
- Maximum value
- Below minimum (min - 1)
- Above maximum (max + 1)
- Zero value
- Negative values
- Decimal for integer field
- First item in list
- Last item in list

---

## Scoring System

**Unlike `/bigtest` and `/perfect`, /edgetest uses BINARY pass/fail.**

- **PASS** = Test passed, edge case handled correctly
- **FAIL** = Test failed, edge case not handled

**Final Status:**
- **100% PASSING** = All tests pass
- **PARTIAL** = Some tests pass, some failed after 3 attempts (background tasks created)
- **FAILED** = Critical tests failed

**No 0-100 scoring.** Edge cases are binary - they work or they don't.

---

## Prerequisites

### Required Tools

1. **Playwright MCP** - Browser automation
   ```bash
   # Must be configured in .mcp.json or ~/.claude.json
   ```

2. **Git** - Version control
   ```bash
   git --version
   ```

3. **Deployment Platform** - One of:
   - Vercel (auto-detected via vercel.json)
   - Railway (auto-detected via railway.json)
   - Custom deploy script (package.json "deploy")

### Required Files

- Production app URL (or localhost for testing)
- Git repository initialized
- Deployment configured

### Optional

- Custom edge case config file (`--config`)

---

## Troubleshooting

### Issue: Playwright MCP not available

**Solution:**
```bash
# Check MCP status
# Use ToolSearch to load playwright tools
ToolSearch: "select:mcp__playwright__browser_navigate"
```

### Issue: Deployment not detected

**Solution:**
```bash
# Ask user for deployment method
AskUserQuestion: "How should I deploy this app? (vercel/railway/custom command)"
```

### Issue: Tests timing out

**Solution:**
```bash
# Increase wait times in browser_wait_for calls
# Check network tab for slow API calls
```

### Issue: Auto-fix not working

**Solution:**
```bash
# Review fix attempts
# After 3 attempts, spawn background agent
# Don't block on complex issues
```

### Issue: Production deployment failing

**Solution:**
```bash
# Check git status
# Verify deployment credentials
# Check deployment logs
```

### Issue: Tests passing locally but failing in production

**Solution:**
```bash
# This is WHY we deploy to production!
# Different environment, different behavior
# Fix must work in production, not just locally
```

---

## Integration with Other Skills

### When to Use Each Skill

| Skill | Focus | Output | Deploy |
|-------|-------|--------|--------|
| `/bigtest` | **UI/UX + functionality audit** | Scoring report (0-100) | No |
| `/perfect` | **Feature implementation** | Scoring report (0-100) | No |
| `/edgetest` | **Edge cases only** | Binary pass/fail | **Yes** |

**Typical Flow:**
1. **Implement feature** with `/perfect` → 100/100 score
2. **Test edge cases** with `/edgetest` → Deploy fixes to production
3. **Full app audit** with `/bigtest` → Comprehensive QA report

---

## Examples

### Example 1: Full App Edge Case Testing

```bash
/edgetest https://myapp.vercel.app
```

**Output:**
- Tests entire app (~50-100 tests)
- All 8 edge case categories
- Auto-fixes failures
- Deploys each fix to production
- 100% passing or background tasks created

---

### Example 2: Focused Edge Case Testing

```bash
/edgetest email integration https://myapp.vercel.app
```

**Output:**
- Tests only email-related features (~10-30 tests)
- Scoped to email forms, email list, send buttons, etc.
- Auto-fixes failures in email code
- Deploys fixes to production
- Faster, more targeted

---

### Example 3: Critical Tests Only

```bash
/edgetest --severity=critical
```

**Output:**
- Tests only CRITICAL edge cases
- SQL injection, XSS, auth bypass, etc.
- Auto-fixes critical issues
- Deploys fixes immediately

---

### Example 4: Skip Production Deployment (Local Testing)

```bash
/edgetest --skip-deploy
```

**Output:**
- Tests edge cases locally
- Fixes failures
- Does NOT deploy to production
- Useful for pre-deploy validation

---

## Final Notes

**Key Differentiators:**
- **Only skill that deploys to production** after each fix
- **Only skill with 100% pass requirement** (binary, not scored)
- **Only skill that spawns background agents** for complex issues
- **Only skill focused exclusively on edge cases**

**Philosophy:**
Edge cases are where apps break in production. Testing locally isn't enough - edge cases behave differently in production (network, data, timing). This skill ensures edge cases work in the REAL environment.

**When in doubt:**
- Use `/edgetest` for **edge case hardening**
- Use `/perfect` for **feature implementation**
- Use `/bigtest` for **comprehensive audit**

---

**YOU ARE NOW READY TO EXECUTE /EDGETEST. BEGIN WITH PHASE 0: SCOPE DETECTION.**
