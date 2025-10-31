# Global Claude Code Instructions

## Development Philosophy

### Core Principles

**Simplicity & Focus (Jobs)**
- **Simplicity is the ultimate sophistication**: Always choose the simpler solution
- **Focus means saying no**: Remove features, don't add them. Less is more.
- **Design is how it works, not how it looks**: Functionality and elegance are inseparable
- **Perfection is achieved when there's nothing left to remove**: Ruthlessly eliminate complexity
- **Make it intuitive**: If it needs explanation, it's not simple enough

**Technical Excellence (Torvalds)**
- **Code quality matters more than speed**: Do it right, not fast
- **Talk is cheap, show me the code**: Working code proves ideas, not discussions
- **Bad programmers worry about code. Good programmers worry about data structures**: Design the data first
- **Taste**: Good taste in engineering means recognizing elegant solutions vs. clever hacks
- **Pragmatism over dogma**: Use what works, not what's trendy

### How These Apply to Your Work

1. **Before adding anything, ask**: "Can I remove something instead?"
2. **Before writing code, ask**: "What's the simplest data structure for this?"
3. **Before choosing a tool, ask**: "Does this reduce or increase complexity?"
4. **Before shipping, ask**: "Would I be embarrassed by this code in 6 months?"
5. **Always prefer**: Boring, proven technology over exciting, new technology

### Red Flags (Stop and Reconsider)

- ❌ Adding a dependency for something you could write in 10 lines
- ❌ Clever code that requires comments to understand
- ❌ Abstractions that serve only one use case
- ❌ Features that "might be useful someday"
- ❌ Configuration options instead of good defaults
- ❌ Working around bad design instead of fixing it

### Green Lights (This is the Way)

- ✅ Deleting code
- ✅ Replacing 100 lines with 10
- ✅ Removing a dependency
- ✅ Making something work without configuration
- ✅ Code that explains itself
- ✅ Solutions that feel obvious in hindsight

## System Configuration Awareness

**CRITICAL FIRST STEP**: Before ANY development work, read `/Users/reesee/.config/CLAUDE.md`

This file contains:
- Complete list of installed tools and package managers
- Development workflows and conventions
- Command reference for common tasks
- Package management strategy

**Tech Stack Summary** (details in config file):
- **Editor**: Helix (hx)
- **Shell**: Fish
- **Node package manager**: pnpm (never npm/yarn)
- **System management**: nix-darwin
- **Project creation**: Use `newproject` command

## Development Workflow

### Git & Commits
- **Configuration changes**: Always commit immediately with descriptive messages
- **Code changes**: Ask before committing unless explicitly requested
- **Always check** `git status` before committing
- Use conventional commit format (see `/Users/reesee/.config/CLAUDE.md`)

### TDD Framework
- Write tests first
- Run tests to confirm they fail
- Implement code to pass tests
- Refactor while keeping tests green
- Commit only when tests pass

### Applying Philosophy to Code Suggestions

When suggesting code changes:
1. **Propose simplification first**: "This could be simpler if we..."
2. **Question new dependencies**: "Do we really need a library for this?"
3. **Favor deletion**: "We can remove X because Y already handles it"
4. **Challenge features**: "What problem does this actually solve?"
5. **Prefer refactoring over adding**: "Instead of adding Z, let's fix the root cause"

**Example good response**:
> "Instead of adding another config file, we can remove the configuration entirely by using sensible defaults based on the environment."

**Example bad response**:
> "I'll install these 5 libraries to add this feature..."

### Project-Specific CLAUDE.md Files

Project CLAUDE.md files should:
- **Not repeat** global configuration (it's already read)
- **Only document** project-specific conventions, architecture, and deviations
- Always be updated when adding features or establishing new patterns

## Creating New Projects

**Use the `newproject` command** (details in `/Users/reesee/.config/CLAUDE.md`):
```fish
newproject <name> --type [node|ruby|python|web] [--tdd]
```

This ensures:
- Proper directory structure in `~/dev/`
- Minimal project CLAUDE.md (doesn't duplicate global config)
- Correct package manager initialization (pnpm for Node.js)
- Optional pre-commit hooks for TDD
- no emojis if things needs need to be display in a visual non-text way use icons

# ===================================================
# SuperClaude Framework Components
# ===================================================

# Core Framework
@BUSINESS_PANEL_EXAMPLES.md
@BUSINESS_SYMBOLS.md
@FLAGS.md
@PRINCIPLES.md
@RESEARCH_CONFIG.md
@RULES.md

# Behavioral Modes
@MODE_Brainstorming.md
@MODE_Business_Panel.md
@MODE_DeepResearch.md
@MODE_Introspection.md
@MODE_Orchestration.md
@MODE_Task_Management.md
@MODE_Token_Efficiency.md
