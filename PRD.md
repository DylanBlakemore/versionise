# Mix Version - Product Requirements Document

## Overview

**Product Name:** mix_version (or elixir_release)  
**Version:** 0.1.0  
**Purpose:** An interactive Mix task for automating the release process of Elixir packages, including version bumping, changelog management, git operations, and publishing.

## Problem Statement

Releasing Elixir packages involves many manual, error-prone steps:
- Manually updating version numbers in multiple places
- Writing changelog entries in the correct format
- Running test suites before release
- Creating git commits and tags
- Pushing to GitHub
- Creating GitHub releases
- Publishing to Hex.pm

Existing solutions like `git_ops` require adopting conventional commits, while `versioce` lacks interactivity and GitHub integration. There's a gap for a simple, interactive tool that guides developers through the release process without imposing workflow constraints.

## Goals & Objectives

### Primary Goals
- Automate repetitive release tasks while maintaining developer control
- Provide an interactive, guided release experience
- Reduce human error in the release process
- Support standard Elixir/Hex.pm workflows

### Success Metrics
- < 2 minutes to complete a full release
- Zero manual file edits required for version bumps
- 100% of version-related files updated correctly
- Clear feedback at each step
- Graceful handling of missing tools (gh CLI)

## Target Users

- **Primary:** Elixir package maintainers releasing to Hex.pm
- **Secondary:** Teams with standardized release processes
- **Tertiary:** Open source maintainers managing multiple packages

## Core Features

### 1. Version Bumping
- Support semantic versioning (major, minor, patch)
- Automatically update `mix.exs` version
- Update documentation `source_ref` in `mix.exs`
- Validate version format

### 2. Interactive Changelog Management
- Prompt for changelog entries by category:
  - Added (new features)
  - Changed (changes to existing functionality)
  - Fixed (bug fixes)
- Support multiple entries per category
- Generate properly formatted CHANGELOG.md entries
- Include release date automatically

### 3. Test Suite Integration
- Optional test suite execution
- Run configurable test command (default: `mix precommit`)
- Halt release on test failures
- Display test output in real-time

### 4. Git Operations
- Stage all changes
- Create commit with standard message format
- Create git tag with version
- Optional push to remote
- Configurable branch name

### 5. GitHub Integration
- Check for GitHub CLI (`gh`) availability
- Create GitHub releases with changelog notes
- Graceful fallback if `gh` not installed
- Support for release notes formatting

### 6. Hex Publishing
- Clear instructions for manual publishing
- Explain why manual step is needed (interactive prompts)
- Future: Automated publishing if feasible

## User Stories

### As a Package Maintainer
- I want to bump versions without manually editing files so that I avoid typos
- I want to be guided through writing changelog entries so that I don't forget important changes
- I want tests to run automatically so that I don't publish broken releases
- I want git operations automated so that I don't forget to tag or push
- I want GitHub releases created automatically so that users can see release notes

### As a Team Lead
- I want consistent release formats across all packages so that our changelog is standardized
- I want the release process to be foolproof so that junior developers can release confidently
- I want to be able to skip steps so that I can customize the workflow when needed

### As an Open Source Maintainer
- I want a simple command to release so that I can focus on code, not process
- I want clear feedback at each step so that I know what's happening
- I want to be able to abort at any point so that I can fix issues before publishing

## Non-Goals (Future Considerations)

- Automated Hex publishing (requires solving interactive prompt issues)
- Support for non-semantic versioning schemes
- Integration with CI/CD for automated releases
- Support for monorepos with multiple packages
- Pre-release version support (alpha, beta, rc)
- Changelog generation from git history
- Conventional commit parsing

## Technical Requirements

### Compatibility
- Elixir 1.12+
- Mix 1.12+
- Git 2.0+
- GitHub CLI (optional, for GitHub releases)

### Performance
- Complete version bump in < 1 second
- Test suite execution time depends on project
- Git operations in < 5 seconds
- Total release time < 2 minutes (excluding tests)

### Reliability
- Validate all inputs before making changes
- Provide clear error messages
- Allow cancellation at any step
- Never leave repository in inconsistent state

## Configuration Schema

```elixir
# config/config.exs
config :mix_version,
  # Command to run for tests (default: "mix precommit")
  test_command: "mix test",
  
  # Git branch to push to (default: "main")
  default_branch: "main",
  
  # Files to update with version (default: ["mix.exs"])
  version_files: ["mix.exs", "README.md"],
  
  # Changelog file location (default: "CHANGELOG.md")
  changelog_file: "CHANGELOG.md",
  
  # GitHub repository (auto-detected from git remote)
  github_repo: "username/repo",
  
  # Skip prompts and use defaults (for CI)
  non_interactive: false
```

## API Design

### CLI Interface

```bash
# Basic usage
mix version patch

# Bump minor version
mix version minor

# Bump major version
mix version major

# Show help
mix version --help

# Non-interactive mode (future)
mix version patch --yes
```

### Programmatic API (Future)

```elixir
# For integration with other tools
MixVersion.bump(:patch, changelog: %{
  added: ["New feature"],
  changed: [],
  fixed: ["Bug fix"]
})
```

## Workflow

### Interactive Flow

1. **Version Selection**
   ```
   Current version: 0.1.0
   New version: 0.1.1
   Continue with version 0.1.1? [Yn]
   ```

2. **File Updates**
   ```
   === Updating Files ===
   ✓ Updated mix.exs
   ```

3. **Changelog Entries**
   ```
   === Changelog Entries ===
   Enter changelog entries (press Enter with empty line to skip)
   
   Added (New features or functionality)
     - Feature 1
     - Feature 2
     - [Enter]
   
   Changed (Changes to existing functionality)
     - [Enter]
   
   Fixed (Bug fixes)
     - Bug fix 1
     - [Enter]
   ```

4. **Test Suite**
   ```
   === Running Tests ===
   Run test suite (mix precommit)? [Yn] y
   Running mix precommit...
   [test output]
   ✓ All tests passed!
   ```

5. **Git Operations**
   ```
   === Git Operations ===
   Commit changes and create git tag? [Yn] y
   Staging changes...
   Committing...
   Creating tag...
   Push to origin? [Yn] y
   Pushing to origin...
   ✓ Pushed to origin
   ```

6. **GitHub Release**
   ```
   === GitHub Release ===
   Create GitHub release? [Yn] y
   Creating GitHub release...
   ✓ GitHub release created!
   ```

7. **Hex Publishing**
   ```
   === Hex Publishing ===
   To publish to Hex.pm, run:
     mix hex.publish
   
   ✓ Release process complete!
   ```

## Architecture

### Key Design Decisions

#### 1. Interactive by Default
**Decision:** Make the tool interactive with prompts at each step.

**Rationale:**
- Gives developers control and confidence
- Allows review before destructive operations
- Educational for new maintainers
- Can be made non-interactive later for CI

#### 2. Modular Architecture
**Decision:** Separate concerns into distinct modules.

**Rationale:**
- Easy to test individual components
- Can swap implementations (e.g., different VCS)
- Clear separation of concerns
- Easier to maintain and extend

#### 3. Graceful Degradation
**Decision:** Continue working even if optional tools are missing.

**Rationale:**
- GitHub CLI is optional
- Some users may not use GitHub
- Tool should work in minimal environments
- Clear messaging about missing features

#### 4. No Automated Hex Publishing
**Decision:** Require manual `mix hex.publish` step.

**Rationale:**
- Hex publish has interactive prompts (organization selection)
- Hard to automate reliably
- Final manual check is valuable
- Can be revisited in future versions

#### 5. Changelog in CHANGELOG.md
**Decision:** Use standard CHANGELOG.md format following Keep a Changelog.

**Rationale:**
- Industry standard
- Human-readable
- GitHub displays it automatically
- Easy to parse and generate

#### 6. Semantic Versioning Only
**Decision:** Support only major.minor.patch versioning.

**Rationale:**
- Standard for Elixir packages
- Keeps implementation simple
- Pre-release versions can be added later
- Covers 95% of use cases

### Data Flow

```
User Input (patch/minor/major)
  ↓
Version Calculation
  ↓
File Updates (mix.exs)
  ↓
Interactive Changelog Collection
  ↓
Changelog File Update
  ↓
Test Execution (optional)
  ↓
Git Operations (optional)
  ↓
GitHub Release (optional)
  ↓
Hex Instructions
```

### Error Handling

```elixir
defmodule MixVersion.Error do
  defexception [:message, :type, :recoverable]
  
  @type t :: %__MODULE__{
    message: String.t(),
    type: :version_error | :git_error | :test_failure | :file_error,
    recoverable: boolean()
  }
end
```

**Error Types:**
- **Version Error**: Invalid version format, version already exists
- **Git Error**: No git repository, uncommitted changes, push failure
- **Test Failure**: Test suite failed
- **File Error**: Cannot read/write files

**Recovery Strategy:**
- Validate before making changes
- Rollback on critical errors
- Clear instructions for manual recovery
- Never leave repository in broken state

## Testing Strategy

### Unit Tests
- Version parsing and bumping logic
- Changelog formatting
- File update operations
- Git command construction

### Integration Tests
- Full release workflow in test repository
- Changelog generation from real entries
- Git operations in temporary repository
- Mock GitHub CLI interactions

### Property-Based Tests
- Version bumping with various inputs
- Changelog entry parsing
- File path handling

## Dependencies

### Runtime
- None (uses only Elixir/Erlang standard library)

### Development
- `credo` - Code quality
- `dialyxir` - Type checking
- `ex_doc` - Documentation

### External Tools (Optional)
- `git` - Required for git operations
- `gh` - Optional for GitHub releases

## Success Criteria

- [ ] Can bump patch, minor, and major versions
- [ ] Updates all version-related files correctly
- [ ] Generates properly formatted changelog entries
- [ ] Executes test suite and halts on failure
- [ ] Creates git commits and tags
- [ ] Pushes to remote repository
- [ ] Creates GitHub releases (when `gh` available)
- [ ] Provides clear instructions for Hex publishing
- [ ] Handles errors gracefully
- [ ] Works without GitHub CLI installed
- [ ] Completes release in < 2 minutes
- [ ] Zero manual file edits required

## Roadmap

### Phase 1: Core Functionality (v0.1.0)
- Version bumping
- File updates
- Interactive changelog
- Basic git operations

### Phase 2: Enhanced Features (v0.2.0)
- Test suite integration
- GitHub release creation
- Configuration support
- Better error handling

### Phase 3: Advanced Features (v0.3.0)
- Non-interactive mode
- Pre-release versions (alpha, beta, rc)
- Custom version file patterns
- Changelog generation from git history

### Phase 4: Ecosystem Integration (v0.4.0)
- CI/CD integration
- Monorepo support
- Multiple package management
- Hex publishing automation (if feasible)

## Comparison with Existing Tools

### vs git_ops
- **git_ops**: Requires conventional commits, automatic changelog
- **mix_version**: No commit format requirements, interactive changelog
- **Advantage**: More flexible, works with any commit style

### vs versioce
- **versioce**: Non-interactive, basic features
- **mix_version**: Interactive, comprehensive release workflow
- **Advantage**: Guides user through process, includes GitHub integration

### vs Manual Process
- **Manual**: Error-prone, time-consuming, inconsistent
- **mix_version**: Automated, fast, consistent
- **Advantage**: Saves time, reduces errors, standardizes process

## Marketing & Positioning

**Tagline:** "Interactive release automation for Elixir packages"

**Key Messages:**
- "Release with confidence" - Interactive prompts prevent mistakes
- "Works your way" - No workflow changes required
- "Complete automation" - From version bump to GitHub release
- "Graceful degradation" - Works even without optional tools

**Target Channels:**
- Hex.pm package listing
- Elixir Forum announcement
- ElixirWeekly newsletter
- Reddit r/elixir
- Twitter/X #MyElixirStatus

---

This PRD provides a comprehensive foundation for extracting the version script into its own package, with clear requirements, architecture, and roadmap for future development.
