# Claude Code MCP Server Configuration Guide

**Date**: November 1, 2025
**Purpose**: Complete guide to configuring all MCP servers for Claude Code

---

## Overview

Claude Code uses Model Context Protocol (MCP) servers to extend its capabilities. Some MCP servers require API keys for authentication and access to external services.

## MCP Servers Status

### ✅ Configured & Working (No API Key Required)

1. **Sequential Thinking** (`mcp__sequential-thinking`)
   - **Purpose**: Structured multi-step reasoning and hypothesis testing
   - **Requirements**: None
   - **Status**: ✅ Working

2. **Morphllm Fast Apply** (`mcp__morphllm-fast-apply`)
   - **Purpose**: Efficient code editing with minimal context
   - **Requirements**: None
   - **Status**: ✅ Working

3. **Playwright** (`mcp__playwright`)
   - **Purpose**: Browser automation and testing
   - **Requirements**: None (Playwright binary auto-installed)
   - **Status**: ✅ Working

4. **Chrome DevTools** (`mcp__chrome-devtools`)
   - **Purpose**: Browser inspection, performance analysis, debugging
   - **Requirements**: None (Chrome/Chromium required on system)
   - **Status**: ✅ Working

### ⚠️ Requires Configuration

5. **Tavily** (`mcp__tavily`)
   - **Purpose**: Web search, content extraction, site crawling, site mapping
   - **Requirements**: `TAVILY_API_KEY`
   - **Status**: ❌ **NOT CONFIGURED** (causing failures)
   - **Sign up**: https://app.tavily.com/
   - **Free tier**: 1,000 credits/month
   - **Tools**:
     - `tavily-search`: AI-powered web search
     - `tavily-extract`: Content extraction from URLs
     - `tavily-crawl`: Website crawling
     - `tavily-map`: Site structure mapping

6. **Context7** (`mcp__context7`)
   - **Purpose**: Up-to-date library documentation and code examples
   - **Requirements**: `CONTEXT7_API_KEY` (optional but recommended)
   - **Status**: ⚠️ **OPTIONAL** (works without key but with rate limits)
   - **Sign up**: https://context7.com/dashboard
   - **Free tier**: Available
   - **Benefits with API key**:
     - Higher rate limits
     - Access to private repositories
     - Faster responses
   - **Tools**:
     - `resolve-library-id`: Find library documentation
     - `get-library-docs`: Retrieve documentation and examples

7. **Magic/21st.dev** (`mcp__magic`)
   - **Purpose**: UI component generation from 21st.dev library
   - **Requirements**: `TWENTY_FIRST_API_KEY`
   - **Status**: ❌ **NOT CONFIGURED** (if using UI generation features)
   - **Sign up**: https://21st.dev/magic/console
   - **Free tier**: Check 21st.dev pricing
   - **Tools**:
     - `21st_magic_component_builder`: Generate UI components
     - `21st_magic_component_inspiration`: Browse component library
     - `21st_magic_component_refiner`: Improve existing components
     - `logo_search`: Search for brand logos

---

## Configuration Instructions

### Step 1: Get Your API Keys

**Tavily (Required for web search)**:
1. Go to https://app.tavily.com/
2. Sign up or log in
3. Navigate to API Keys section
4. Copy your API key (starts with `tvly-dev-` or `tvly-prod-`)
5. Free tier: 1,000 credits/month

**Context7 (Optional but recommended)**:
1. Go to https://context7.com/dashboard
2. Sign up or log in
3. Generate API key
4. Copy your API key
5. Free tier available

**21st.dev Magic (Required only if using UI generation)**:
1. Go to https://21st.dev/magic/console
2. Sign up or log in
3. Generate API key
4. Copy your API key
5. Check pricing for usage limits

### Step 2: Configure Environment Variables

**Location**: `/Users/reesee/.config/fish/config.fish`

**Current configuration** (lines 39-58):
```fish
# ============================================
# Claude Code MCP Server API Keys
# ============================================

# Tavily API Key (Required for web search, extraction, crawling)
# Get your key from: https://app.tavily.com/
set -gx TAVILY_API_KEY "YOUR_TAVILY_API_KEY_HERE"

# Context7 API Key (Optional - provides higher rate limits)
# Get your key from: https://context7.com/dashboard
# set -gx CONTEXT7_API_KEY "YOUR_CONTEXT7_API_KEY_HERE"

# 21st.dev Magic API Key (Required for UI component generation)
# Get your key from: https://21st.dev/magic/console
# set -gx TWENTY_FIRST_API_KEY "YOUR_21ST_DEV_API_KEY_HERE"

# ============================================
```

**To configure**:
1. Open `/Users/reesee/.config/fish/config.fish` in editor
2. Replace `"YOUR_TAVILY_API_KEY_HERE"` with your actual Tavily API key
3. Uncomment and replace Context7 API key line if you have one
4. Uncomment and replace 21st.dev API key line if you have one

**Example** (with real keys):
```fish
# Tavily API Key
set -gx TAVILY_API_KEY "tvly-dev-abc123xyz789..."

# Context7 API Key (uncommented if you have one)
set -gx CONTEXT7_API_KEY "ctx7_abc123xyz789..."

# 21st.dev Magic API Key (uncommented if you have one)
set -gx TWENTY_FIRST_API_KEY "21st_abc123xyz789..."
```

### Step 3: Apply Configuration

**Option 1: Reload Fish configuration**
```fish
source ~/.config/fish/config.fish
```

**Option 2: Restart terminal/Claude Code**
- Close and reopen your terminal
- Restart Claude Code application

### Step 4: Verify Configuration

**Check environment variables**:
```fish
echo $TAVILY_API_KEY
echo $CONTEXT7_API_KEY
echo $TWENTY_FIRST_API_KEY
```

**Expected output**:
- Should show your actual API keys (not the placeholder text)
- If you see empty output, the variable isn't set

---

## Troubleshooting

### Issue: "Invalid API key" or "MCP error -32603"

**Cause**: API key not configured or incorrect

**Solutions**:
1. Verify API key is correctly copied (no extra spaces or quotes)
2. Check that you replaced the placeholder text
3. Reload Fish configuration: `source ~/.config/fish/config.fish`
4. Restart Claude Code
5. Verify with: `echo $TAVILY_API_KEY`

### Issue: MCP server tools not working

**Diagnosis**:
```fish
# Check if environment variables are set
env | grep -E "TAVILY|CONTEXT7|TWENTY_FIRST"
```

**Solutions**:
1. Ensure Fish configuration is loaded in interactive shells
2. Check for syntax errors in `config.fish`
3. Verify API keys are valid on respective dashboards
4. Check API key usage limits (may have exhausted free tier)

### Issue: Context7 rate limiting

**Symptoms**: Frequent rate limit errors when using Context7

**Solution**:
1. Get API key from https://context7.com/dashboard
2. Uncomment and configure `CONTEXT7_API_KEY`
3. Reload configuration

---

## Usage Examples

### Tavily Web Search
```
# Search for current information
/sc:research "Docker MacBook Pro M4 use cases"

# Extract content from URLs
mcp__tavily__tavily-extract with URLs

# Crawl website
mcp__tavily__tavily-crawl with base URL
```

### Context7 Documentation Lookup
```
# Find library documentation
mcp__context7__resolve-library-id with "helix editor"

# Get documentation
mcp__context7__get-library-docs with library ID
```

### Magic UI Component Generation
```
# Generate UI component
/ui "create a login form with email and password"

# Browse components
mcp__magic__21st_magic_component_inspiration

# Refine existing component
mcp__magic__21st_magic_component_refiner
```

---

## Security Best Practices

1. **Never commit API keys to git**:
   - `/Users/reesee/.config/fish/config.fish` is in dotfiles repo
   - Use `.gitignore` or secret management
   - Consider using 1Password for API key storage

2. **Use development keys for testing**:
   - Tavily provides dev vs prod keys
   - Test with dev keys first

3. **Monitor API usage**:
   - Check dashboards regularly for usage
   - Set up alerts for approaching limits
   - Rotate keys periodically

4. **Environment-specific keys**:
   - Use different keys for different machines if needed
   - Don't share keys across team members

---

## API Key Management with 1Password

**Recommended approach** (using 1Password CLI):

```fish
# Store API keys in 1Password
op item create --category=login \
  --title="Tavily API Key" \
  --field label=api_key,type=text,value="tvly-dev-..."

# Retrieve in config.fish
set -gx TAVILY_API_KEY (op item get "Tavily API Key" --fields api_key)
```

**Benefits**:
- API keys not stored in plaintext
- Synced across devices via 1Password
- Can rotate without editing config files
- Audit trail of key access

---

## MCP Server Capabilities Summary

| MCP Server | API Key Required | Primary Use Case | Free Tier |
|------------|-----------------|------------------|-----------|
| Tavily | ✅ Yes | Web search, research | 1,000 credits/month |
| Context7 | ⚠️ Optional | Library documentation | Yes (with limits) |
| Magic/21st.dev | ✅ Yes (for UI gen) | UI component generation | Check 21st.dev |
| Sequential Thinking | ❌ No | Structured reasoning | N/A |
| Morphllm | ❌ No | Code editing | N/A |
| Playwright | ❌ No | Browser automation | N/A |
| Chrome DevTools | ❌ No | Browser debugging | N/A |

---

## Current Status

**Last Updated**: November 1, 2025

**Configured**:
- ❌ Tavily - Placeholder configured, needs actual key
- ❌ Context7 - Commented out, needs key if desired
- ❌ Magic/21st.dev - Commented out, needs key if using UI features

**Required Actions**:
1. ✅ Sign up for Tavily at https://app.tavily.com/
2. ✅ Copy Tavily API key from dashboard
3. ⏳ Edit `/Users/reesee/.config/fish/config.fish`
4. ⏳ Replace `"YOUR_TAVILY_API_KEY_HERE"` with actual key
5. ⏳ Reload Fish configuration
6. ⏳ Test Tavily search functionality

**Optional**:
- Sign up for Context7 for better documentation access
- Sign up for 21st.dev if using UI component generation

---

## Support & Resources

**Tavily**:
- Dashboard: https://app.tavily.com/
- Documentation: https://docs.tavily.com/
- Support: support@tavily.com

**Context7**:
- Dashboard: https://context7.com/dashboard
- GitHub: https://github.com/upstash/context7
- Documentation: Check GitHub README

**Magic/21st.dev**:
- Console: https://21st.dev/magic/console
- GitHub: https://github.com/21st-dev/magic-mcp
- Documentation: Check GitHub README

**Claude Code**:
- Documentation: https://docs.claude.com/claude-code
- Issues: https://github.com/anthropics/claude-code/issues

---

**Configuration File Location**: `/Users/reesee/.config/fish/config.fish` (lines 39-58)
**This Documentation**: `/Users/reesee/.config/claudedocs/mcp_server_configuration_guide.md`
