# Distribution & Deployment Guide

## Final Deployment Checklist

✅ **GitHub Repository**: https://github.com/enriquemastalli/global-dev-environment
✅ **Release v1.0**: Published with assets
✅ **Remote Installer**: `install-from-github.sh` tested and working
✅ **Documentation**: Complete README with all sections
✅ **Installation Method**: Works from 30-second curl command

## Installation Command (For Teams)

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

## Verification

After installation, verify everything works:

```bash
# Check installation
~/.opencode/bin/verify-installation.sh

# Validate a project
~/.opencode/bin/validate-project.sh /path/to/project

# List all skills
ls ~/.opencode/skills/

# Read core documentation
cat ~/.opencode/README.md
```

## What Gets Installed

**Location:** `~/.opencode/`

**Files (28 total):**
- 8 markdown documentation files
- 3 shell scripts (install, export, etc.)
- 3 utility scripts in `bin/`
- 9 skills directories with SKILL.md files

**Size:** ~404 KB

**Time:** ~30 seconds to download and extract

## Distribution Methods

### Method 1: Direct Installation (RECOMMENDED)
Users run one command and everything is installed automatically.

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

### Method 2: Git Clone
For teams using version control:

```bash
git clone https://github.com/enriquemastalli/global-dev-environment.git
cd global-dev-environment
bash install.sh
```

### Method 3: Tarball Export
For offline distribution or air-gapped environments:

```bash
# Create tarball
~/.opencode/export.sh

# Or manually
tar -czf environment.tar.gz ~/.opencode --exclude=node_modules --exclude=.git

# Share the tarball
# User extracts:
tar -xzf environment.tar.gz -C ~/
```

### Method 4: Docker Integration
For containerized deployments:

```dockerfile
FROM node:18-alpine
RUN curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
ENV PATH="$HOME/.opencode/bin:$PATH"
```

## Team Onboarding

1. **Send install link** to team members
   ```
   https://github.com/enriquemastalli/global-dev-environment
   ```

2. **They run one command**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
   ```

3. **Verify installation**
   ```bash
   ~/.opencode/bin/verify-installation.sh
   ```

4. **Start using skills**
   - Skills auto-load when appropriate
   - Read documentation in `~/.opencode/README.md`

## Updates

To update to latest version:

```bash
cd ~/.opencode
git pull origin main
```

Or re-run installation (will prompt to replace):

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

## GitHub Release Assets

**v1.0 Release:**
- `global-dev-environment-v1.0.tar.gz` (28 KB)
- `global-dev-environment-v1.0.tar.gz.sha256` (checksum)

**Verify tarball integrity:**
```bash
curl -fsSL https://github.com/enriquemastalli/global-dev-environment/releases/download/v1.0/global-dev-environment-v1.0.tar.gz.sha256 | sha256sum -c
```

## Success Criteria

After deployment, users should be able to:

✅ Install in <30 seconds with one command
✅ Verify installation with `verify-installation.sh`
✅ Access all 9 skills automatically
✅ Validate projects with `validate-project.sh`
✅ Auto-generate AGENTS.md with `auto-create-agents-md.sh`
✅ Read complete documentation in `~/.opencode/`
✅ Export environment for offline sharing
✅ Stay synced with `git pull`

## Troubleshooting

### Installation fails with "No such file"
- Check internet connection
- Try cloning repository instead:
  ```bash
  git clone https://github.com/enriquemastalli/global-dev-environment.git
  cd global-dev-environment
  bash install.sh
  ```

### Skills not showing
- Verify installation:
  ```bash
  ls ~/.opencode/skills/
  ```
- Check if .opencode in PATH:
  ```bash
  echo $PATH | grep opencode
  ```

### Permission denied
- Make scripts executable:
  ```bash
  chmod +x ~/.opencode/bin/*.sh
  chmod +x ~/.opencode/*.sh
  ```

## Future Versions

When updating to v2.0 or later:

1. Create new GitHub release
2. Generate new tarball with checksums
3. Update `install-from-github.sh` to reference new release (if needed)
4. Announce in README.md and CHANGELOG.md
5. Maintain backward compatibility

## Support

- **Issues**: https://github.com/enriquemastalli/global-dev-environment/issues
- **Discussions**: https://github.com/enriquemastalli/global-dev-environment/discussions
- **Wiki**: https://github.com/enriquemastalli/global-dev-environment/wiki

---

**Global Development Environment is ready for distribution.**
