# Versionise

**Interactive versioning and release automation for Elixir packages.**

Versionise is a Mix task that guides you through the entire release process with interactive prompts, automating version bumps, changelog management, git operations, and more—without imposing workflow constraints.

## Features

- 🔢 **Semantic Version Bumping** - Automatically bump major, minor, or patch versions
- 📝 **Interactive Changelog** - Guided prompts for changelog entries (Added, Changed, Fixed)
- 🧪 **Test Integration** - Optionally run your test suite before releasing
- 🔖 **Git Automation** - Stage, commit, tag, and push with standard conventions
- 📦 **Hex.pm Ready** - Updates `mix.exs` and prepares for publishing
- 🎯 **Simple & Focused** - Does one thing well without unnecessary complexity

## Installation

Add `versionise` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:versionise, "~> 0.1.0", only: :dev, runtime: false}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Usage

Bump your project version with a single command:

```bash
# Bump patch version (1.0.0 -> 1.0.1)
mix version patch

# Bump minor version (1.0.0 -> 1.1.0)
mix version minor

# Bump major version (1.0.0 -> 2.0.0)
mix version major
```

### Interactive Workflow

Versionise will guide you through each step:

1. **Version Confirmation**
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
     - New authentication system
     - User profile page
     - [Enter]
   
   Changed (Changes to existing functionality)
     - [Enter]
   
   Fixed (Bug fixes)
     - Fixed login redirect bug
     - [Enter]
   ```

4. **Test Suite** (optional)
   ```
   === Running Tests ===
   Run test suite (mix precommit)? [Yn]
   ```

5. **Git Operations** (optional)
   ```
   === Git Operations ===
   Commit changes and create git tag? [Yn]
   Push to origin? [Yn]
   ```

6. **Hex Publishing**
   ```
   === Hex Publishing ===
   To publish to Hex.pm, run:
     mix hex.publish
   
   ✓ Release process complete!
   ```

## What Gets Updated

When you run `mix version`, the following files are automatically updated:

- **`mix.exs`** - The `version` field in your project definition
- **`mix.exs`** - The `source_ref` field (if present) for documentation
- **`CHANGELOG.md`** - New version entry with your changes (Keep a Changelog format)

## Why Versionise?

### vs Manual Process

**Manual releases are error-prone:**
- ❌ Forget to update version numbers
- ❌ Inconsistent changelog formatting
- ❌ Miss creating git tags
- ❌ Typos in version numbers
- ❌ Time-consuming and repetitive

**Versionise automates it all:**
- ✅ Zero manual file edits
- ✅ Consistent formatting
- ✅ Never miss a step
- ✅ Validated inputs
- ✅ Fast and reliable

### vs git_ops

[git_ops](https://github.com/timberio/git_ops) is a great tool, but it requires adopting conventional commits.

**git_ops:**
- Requires conventional commit format
- Automatically generates changelogs from commits
- Less control over changelog content
- Steeper learning curve for teams

**Versionise:**
- Works with any commit style
- You write the changelog entries
- Full control over release notes
- Simple and intuitive

### vs versioce

[versioce](https://github.com/mpanarin/versioce) offers basic versioning but lacks interactivity.

**versioce:**
- Non-interactive configuration
- Limited changelog support
- Basic automation

**Versionise:**
- Interactive and guided
- Rich changelog management (Keep a Changelog format)
- Comprehensive workflow (tests, git, publishing)
- Optional steps based on your needs

## Configuration

Versionise works out of the box with sensible defaults. For most projects, no configuration is needed.

However, you can customize the behavior by adding configuration to your `config/config.exs`:

```elixir
# config/config.exs
config :versionise,
  # Command to run for tests (default: "mix test")
  test_command: "mix precommit"
```

### Available Configuration Options

- **`:test_command`** - The command to run when testing before release
  - Default: `"mix test"`
  - Examples: `"mix precommit"`, `"mix test --cover"`, `"mix ci"`

## Requirements

- Elixir 1.12+
- Git (for git operations)

## Philosophy

Versionise follows these principles:

1. **Interactive by Default** - Guide developers through the process with clear prompts
2. **No Workflow Changes** - Works with your existing commit style and process
3. **Simple & Focused** - Does version management well without feature bloat
4. **Graceful Degradation** - Works even without git or in minimal environments
5. **Developer Control** - You confirm each step; no surprises

## FAQ

**Q: Does Versionise publish to Hex.pm automatically?**

A: No. Hex publishing requires interactive prompts (like organization selection), so we leave that as a manual step. Versionise will remind you to run `mix hex.publish` at the end.

**Q: Can I use this in CI/CD?**

A: Versionise is designed for interactive use. For automated releases, consider tools like `git_ops` or GitHub Actions with semantic-release.

**Q: Does it work without git?**

A: Yes! Versionise will update versions and changelogs even without git. The git operations are optional.

**Q: What changelog format does it use?**

A: [Keep a Changelog](https://keepachangelog.com/) - the widely-adopted standard for changelogs.

**Q: Can I customize the test command?**

A: Yes! Configure it in your `config/config.exs`:

```elixir
config :versionise,
  test_command: "mix precommit"
```

The default is `mix test` if not configured.

## Changelog Format

Versionise follows the [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

## [1.0.1] - 2024-01-15

### Added

- New feature description
- Another new feature

### Fixed

- Bug fix description
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Created by Dylan Blakemore

Inspired by the needs of Elixir package maintainers who want a simple, interactive release process.
