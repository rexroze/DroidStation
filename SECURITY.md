# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.x (latest) | ✅ Active |

Older versions do not receive security fixes. Always use the latest release.

---

## Scope

DroidStation is a Bash installer that runs inside Termux on Android. The following are considered in scope for security reports:

- **Script injection** — user input or device properties being unsafely interpolated into shell commands
- **Unsafe downloads** — fetching scripts or binaries over plain HTTP without verification
- **Privilege escalation** — unintended ways the script could gain elevated privileges outside Termux's sandbox
- **Proot container escapes** — unintended access from inside the Proot container to the host Android system
- **Dependency confusion** — package names that could be hijacked via a malicious Termux/TUR repository
- **Credential exposure** — VNC passwords or other secrets being stored or logged insecurely

The following are **out of scope**:

- Security of tools installed by the user (Metasploit, Wireshark, etc.) — these are intentional and the user's responsibility
- Android system vulnerabilities
- Termux or Termux-X11 vulnerabilities — report those to their respective projects
- Wine/Hangover security issues

---

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Report security issues privately by emailing:

**security@rexroze.github.io** *(replace with your actual contact)*

Or via GitHub's private vulnerability reporting:
**Security → Report a vulnerability** (in the repo's Security tab)

Include in your report:
- A clear description of the vulnerability
- Steps to reproduce
- Potential impact
- Your suggested fix (if any)

---

## Response Timeline

| Stage | Target Time |
|---|---|
| Acknowledgement | Within 48 hours |
| Initial assessment | Within 7 days |
| Fix or mitigation | Within 30 days for critical issues |
| Public disclosure | After fix is released |

---

## Security Notes for Users

**VNC passwords** are stored in `~/.vnc/passwd` as a VNC-format hashed file (not plaintext). Still, avoid weak passwords if your device is on a shared network.

**Proot is not a security sandbox.** It provides filesystem isolation but does not prevent a process inside the container from accessing the Android host via Termux's shared `/proc`, shared temp directories, or X11 socket. Do not run untrusted code inside the Proot container and expect it to be isolated.

**The install script requires no root.** DroidStation runs entirely inside Termux's unprivileged user space. It does not request, use, or require Android root access at any point.

**Verify the script before running it.** Before piping a curl to bash, you can inspect the script first:

```bash
curl -fsSL https://raw.githubusercontent.com/rexroze/DroidStation/main/droidstation-setup.sh -o setup.sh
less setup.sh
bash setup.sh
```
