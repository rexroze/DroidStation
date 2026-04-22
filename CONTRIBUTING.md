# Contributing to DroidStation

Thanks for your interest in contributing! DroidStation is a community project and every improvement helps Android users everywhere get a better Linux desktop experience.

---

## Ways to Contribute

- **Bug reports** — found something broken? Open an issue with the bug report template
- **Feature requests** — have an idea? Open an issue with the feature request template
- **Code** — fix a bug or add a feature via a pull request
- **Testing** — test on a device we haven't confirmed yet and report results
- **Documentation** — improve the README, add examples, fix typos

---

## Before You Open a PR

1. **Check existing issues and PRs** to make sure you're not duplicating work
2. **For large changes**, open an issue first to discuss the approach before writing code
3. **For small fixes** (typos, minor bugs), just open a PR directly

---

## Development Setup

DroidStation is a single Bash script. No build tools required.

```bash
# Fork and clone
git clone https://github.com/rexroze/DroidStation.git
cd DroidStation

# Make your changes to droidstation-setup.sh

# Lint with ShellCheck before submitting
shellcheck droidstation-setup.sh
```

Install ShellCheck:
```bash
# On Termux
pkg install shellcheck

# On Linux/macOS
apt install shellcheck   # Debian/Ubuntu
brew install shellcheck  # macOS
```

---

## Code Style

- Use `#!/data/data/com.termux/files/usr/bin/bash` as the shebang (not `/bin/bash` — Termux doesn't have `/bin`)
- 2-space indentation
- Quote all variables: `"$VAR"` not `$VAR`
- Use `local` for all variables inside functions
- Color output using the existing color variables (`$GREEN`, `$RED`, etc.)
- All new install steps should use the `spinner` function and `pkg_install` helper
- New optional features should be behind a flag (e.g. `INSTALL_FEATURE="false"`) and prompted during `select_options`
- Append all package manager output to `$LOG_FILE`, not to stdout

---

## Adding a New Desktop Environment

1. Add it to the selection menus in both `select_options_prompt` and `select_options_tui`
2. Add a `case` block in `step_desktop` to install its packages
3. Add `DS_EXEC` and `DS_KILL` entries in `step_launchers`
4. Update the DE comparison table in `README.md`

---

## Adding a New Dev Stack

1. Add a prompt in `select_options_prompt` and a checklist entry in `select_options_tui`
2. Add a flag in `parse_flags` (e.g. `--dev=rust`)
3. Add an `INSTALL_RUST="false"` config variable at the top
4. Install it inside `step_dev`
5. Document it in `README.md` under Developer Tooling

---

## Tested Devices

If you've confirmed DroidStation works on a device not listed below, please open a PR adding it to this table or comment on the relevant issue.

| Device | Chipset | GPU | DE Tested | Status |
|---|---|---|---|---|
| Samsung Galaxy S23 | Snapdragon 8 Gen 2 | Adreno 740 | XFCE4, KDE | ✅ Working |
| Samsung Galaxy S22 | Snapdragon 8 Gen 1 | Adreno 730 | XFCE4 | ✅ Working |
| Samsung Galaxy S21 FE | Snapdragon 888 | Adreno 660 | XFCE4, LXQt | ✅ Working |
| Samsung Galaxy Tab S8 | Snapdragon 8 Gen 1 | Adreno 730 | XFCE4 + DeX | ✅ Working |
| Xiaomi 13 | Snapdragon 8 Gen 2 | Adreno 740 | XFCE4 | ✅ Working |
| OnePlus 11 | Snapdragon 8 Gen 2 | Adreno 740 | XFCE4 | ✅ Working |
| Samsung Galaxy S22 (EU) | Exynos 2200 | Xclipse 920 | XFCE4 | ⚠️ Software rendering |
| Samsung Galaxy S21 (EU) | Exynos 2100 | Mali-G78 | LXQt | ⚠️ Software rendering |

---

## Pull Request Checklist

Before submitting, confirm:

- [ ] `shellcheck droidstation-setup.sh` passes with no errors
- [ ] Tested on a real Android device (emulator is not sufficient)
- [ ] New options are added to both `select_options_prompt` and `select_options_tui`
- [ ] New flags are documented in `--help` and in `README.md`
- [ ] `CHANGELOG.md` has an entry under `[Unreleased]`
- [ ] No hardcoded paths outside of `/data/data/com.termux/files/` or `$PREFIX`

---

## Commit Message Format

```
type: short description (max 72 chars)

Optional longer explanation here. Wrap at 72 chars.

Fixes #123
```

Types: `feat` `fix` `docs` `style` `refactor` `test` `chore`

Examples:
```
feat: add Arch Linux as a proot distro option
fix: correct GPU detection on Xiaomi devices with MIUI
docs: add OnePlus 11 to tested devices table
```

---

## Code of Conduct

Be respectful. Criticism of code is fine; criticism of people is not. If someone is just getting started with shell scripting, help them out.
