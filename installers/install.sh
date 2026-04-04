#!/usr/bin/env bash
set -euo pipefail

# CTX Customer Pack Installer
#
# Downloads and installs Context Engine packages directly from GitHub.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh \
#     | bash -s -- --package all --agent claude
#
# Environment:
#   CTX_API_URL  — Context Engine server URL
#   CTX_API_KEY  — API key (never passed as CLI flag)

REPO="codota/ctx-customer-pack-distributable"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API_BASE="https://api.github.com/repos/${REPO}/contents"

PACKAGE=""
AGENT=""
NON_INTERACTIVE=false
BIN_DIR=""

# Detect a user-writable directory already in PATH
detect_bin_dir() {
  # Check common user-writable locations that are typically in PATH
  for candidate in "${HOME}/.local/bin" "/usr/local/bin"; do
    if [ -d "$candidate" ] && [ -w "$candidate" ]; then
      # Verify it's actually in PATH
      if [[ ":$PATH:" == *":${candidate}:"* ]]; then
        echo "$candidate"
        return
      fi
    fi
  done

  # macOS: ~/.local/bin is standard per XDG but often missing; create if on macOS
  if [ "$(uname -s)" = "Darwin" ] && [ -d "${HOME}/.local" ] && [ -w "${HOME}/.local" ]; then
    mkdir -p "${HOME}/.local/bin"
    echo "${HOME}/.local/bin"
    return
  fi

  # Linux: ~/.local/bin is XDG standard, many distros add it to PATH
  if [ "$(uname -s)" = "Linux" ]; then
    mkdir -p "${HOME}/.local/bin"
    echo "${HOME}/.local/bin"
    return
  fi

  # Fallback: current directory
  echo "."
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --package) PACKAGE="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --bin-dir) BIN_DIR="$2"; shift 2 ;;
    --branch) BRANCH="$2"; RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"; shift 2 ;;
    --non-interactive) NON_INTERACTIVE=true; shift ;;
    --help|-h)
      echo "Usage: curl -fsSL ...install.sh | bash -s -- [OPTIONS]"
      echo ""
      echo "  --package core|loader|onboarder|all"
      echo "  --agent claude|cursor|gemini|tabnine"
      echo "  --bin-dir <path>  (default: ~/bin)"
      echo "  --non-interactive"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

fetch() {
  curl -fsSL "$1" -o "$2" 2>/dev/null
}

list_github_dir() {
  curl -fsSL "${API_BASE}/$1?ref=${BRANCH}" 2>/dev/null \
    | grep '"name"' \
    | sed 's/.*"name": *"\([^"]*\)".*/\1/'
}

resolve_packages() {
  case $1 in
    core) echo "core" ;;
    loader) echo "core cli loader" ;;
    onboarder|all) echo "core cli loader onboarder" ;;
    *) echo "Unknown package: $1" >&2; exit 1 ;;
  esac
}

# ── Install functions ────────────────────────────────────────────

install_core() {
  local agent=$1
  local skills count=0 total

  case $agent in
    claude)
      skills=$(list_github_dir "core/agents/claude/skills")
      total=$(echo "$skills" | wc -w | tr -d ' ')
      echo "[core] Downloading ${total} skills for ${agent}..."
      mkdir -p .claude/skills .claude/commands
      for skill in $skills; do
        count=$((count + 1))
        printf "\r\033[K[core] %d/%d %s" "$count" "$total" "$skill"
        mkdir -p ".claude/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/claude/skills/${skill}/SKILL.md" ".claude/skills/${skill}/SKILL.md" || true
        fetch "${RAW_BASE}/core/agents/claude/commands/${skill}.md" ".claude/commands/${skill}.md" 2>/dev/null || true
      done
      echo ""
      echo "[core] Downloading hooks + MCP proxy..."
      mkdir -p .claude/hooks .claude/scripts
      fetch "${RAW_BASE}/core/agents/claude/hooks/decision-context.py" ".claude/hooks/decision-context.py" || true
      fetch "${RAW_BASE}/core/agents/claude/hooks/change-confidence.py" ".claude/hooks/change-confidence.py" || true
      fetch "${RAW_BASE}/core/agents/claude/scripts/ctx-mcp-proxy.py" ".claude/scripts/ctx-mcp-proxy.py" || true
      chmod +x .claude/hooks/*.py .claude/scripts/*.py 2>/dev/null || true

      # Configure MCP server, hooks, and permissions in settings.local.json
      echo "[core] Configuring Claude Code settings..."
      local abs_scripts
      abs_scripts="$(cd .claude/scripts 2>/dev/null && pwd)"
      local abs_hooks
      abs_hooks="$(cd .claude/hooks 2>/dev/null && pwd)"
      cat > .claude/settings.local.json <<SETTINGS_EOF
{
  "permissions": {
    "allow": [
      "Bash(ctx-loader:*)",
      "Bash(ctx-onboard:*)",
      "Bash(ctx-cli:*)",
      "Bash(which ctx-onboard:*)",
      "Bash(which ctx-loader:*)",
      "Bash(which ctx-cli:*)"
    ]
  },
  "mcpServers": {
    "ctx-cloud": {
      "command": "python3",
      "args": ["${abs_scripts}/ctx-mcp-proxy.py"]
    }
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${abs_hooks}/decision-context.py",
            "timeout": 3000
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${abs_hooks}/change-confidence.py",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF

      # Generate CLAUDE.md project guide
      echo "[core] Creating CLAUDE.md..."
      cat > CLAUDE.md <<'CLAUDE_EOF'
# Tabnine Context Engine

The Context Engine customer pack is fully installed and configured. All skills, MCP tools, and hooks are ALREADY LOADED into your context automatically. Do not read or explore the .claude/ directory — everything is available to you right now.

## Step 1: Set up credentials

If `ctx-settings.yaml` does not exist in this directory, create it now:

```yaml
CTX_API_URL: <Context Engine URL>
CTX_API_KEY: <your API key>
PROJECT_NAME: <project name>
GITHUB_ORG: <GitHub org or owner>
GITHUB_REPO: <repo name>
DATA_VOLUME: standard
GH_PAT: <GitHub PAT>
```

This file is read automatically by all CLIs — no need to export environment variables.

## Step 2: Use the Context Engine

Once `ctx-settings.yaml` exists, use your tools directly:

- **To query the knowledge graph**: use the `/ctx` skill or call MCP tools like `mcp__ctx-cloud__search_knowledge`, `mcp__ctx-cloud__query_entities`
- **To investigate a service**: `/investigate-service`
- **To assess change impact**: `/blast-radius` or `mcp__ctx-cloud__blast_radius`
- **To review a PR**: `/review-pr`
- **To onboard a new project**: `/onboard` (7-step methodology with data loading)
- **CLIs**: `ctx-loader` (data loading), `ctx-onboard` (onboarding), `ctx-cli` (queries)

## Rules

- Credentials come from `ctx-settings.yaml` or environment variables only. Never pass secrets as CLI arguments.
- If data loading fails, run `ctx-loader diagnose --json` for structured error output.
- Do not explore parent directories or the .claude/ directory. Everything is already loaded and configured.
CLAUDE_EOF

      echo "[core] Done: ${count} skills + ${count} commands + 2 hooks + MCP proxy + settings + CLAUDE.md."
      ;;
    cursor)
      skills=$(list_github_dir "core/agents/cursor/.cursor/skills")
      total=$(echo "$skills" | wc -w | tr -d ' ')
      echo "[core] Downloading ${total} skills for ${agent}..."
      mkdir -p .cursor/skills .cursor/rules
      for skill in $skills; do
        count=$((count + 1))
        printf "\r\033[K[core] %d/%d %s" "$count" "$total" "$skill"
        mkdir -p ".cursor/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/cursor/.cursor/skills/${skill}/SKILL.md" ".cursor/skills/${skill}/SKILL.md" || true
        fetch "${RAW_BASE}/core/agents/cursor/.cursor/rules/${skill}.mdc" ".cursor/rules/${skill}.mdc" 2>/dev/null || true
      done
      echo ""
      echo "[core] Done: ${count} skills + ${count} rules."
      ;;
    gemini)
      skills=$(list_github_dir "core/agents/gemini/.gemini/skills")
      total=$(echo "$skills" | wc -w | tr -d ' ')
      echo "[core] Downloading ${total} skills for ${agent}..."
      mkdir -p .gemini/skills
      for skill in $skills; do
        count=$((count + 1))
        printf "\r\033[K[core] %d/%d %s" "$count" "$total" "$skill"
        mkdir -p ".gemini/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/gemini/.gemini/skills/${skill}/SKILL.md" ".gemini/skills/${skill}/SKILL.md" || true
      done
      echo ""
      echo "[core] Done: ${count} skills."
      ;;
    tabnine)
      skills=$(list_github_dir "core/agents/tabnine/.tabnine/agent/skills")
      total=$(echo "$skills" | wc -w | tr -d ' ')
      echo "[core] Downloading ${total} skills for ${agent}..."
      mkdir -p "${HOME}/.tabnine/agent/skills"
      for skill in $skills; do
        count=$((count + 1))
        printf "\r\033[K[core] %d/%d %s" "$count" "$total" "$skill"
        mkdir -p "${HOME}/.tabnine/agent/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/tabnine/.tabnine/agent/skills/${skill}/SKILL.md" "${HOME}/.tabnine/agent/skills/${skill}/SKILL.md" || true
      done
      echo ""
      echo "[core] Done: ${count} skills."
      ;;
    *) echo "[core] Unknown agent: ${agent}"; return ;;
  esac
}

install_cli() {
  echo "[cli] Downloading ctx-cli..."
  mkdir -p "$BIN_DIR"
  if fetch "${RAW_BASE}/cli/bin/ctx-cli" "${BIN_DIR}/ctx-cli"; then
    chmod +x "${BIN_DIR}/ctx-cli"
    echo "[cli] Installed → ${BIN_DIR}/ctx-cli"
  else
    echo "[cli] Failed to download (ctx-cli may not be built yet)."
  fi
}

install_loader() {
  echo "[loader] Downloading ctx-loader CLI..."
  mkdir -p "$BIN_DIR"
  if fetch "${RAW_BASE}/loader/bin/ctx-loader" "${BIN_DIR}/ctx-loader"; then
    chmod +x "${BIN_DIR}/ctx-loader"
    echo "[loader] Installed → ${BIN_DIR}/ctx-loader"
  else
    echo "[loader] Failed to download."
  fi
}

install_onboarder() {
  local agent=$1
  echo "[onboarder] Downloading ctx-onboard CLI..."
  mkdir -p "$BIN_DIR"
  if fetch "${RAW_BASE}/onboarder/bin/ctx-onboard" "${BIN_DIR}/ctx-onboard"; then
    chmod +x "${BIN_DIR}/ctx-onboard"
    echo "[onboarder] Installed → ${BIN_DIR}/ctx-onboard"
  else
    echo "[onboarder] Failed to download."
    return
  fi

  local skill_dir=""
  case $agent in
    claude) skill_dir=".claude/skills" ;;
    cursor) skill_dir=".cursor/skills" ;;
    gemini) skill_dir=".gemini/skills" ;;
    *) return ;;
  esac

  local ob_skills="onboard-init onboard-test-lab onboard-load onboard-baseline onboard-domain onboard-measure onboard-rollout"
  local count=0
  for skill in $ob_skills; do
    mkdir -p "${skill_dir}/${skill}"
    fetch "${RAW_BASE}/onboarder/skills/${skill}/SKILL.md" "${skill_dir}/${skill}/SKILL.md" && count=$((count + 1))
  done
  echo "[onboarder] ${count} onboarding skills installed."
}

# ── Main ─────────────────────────────────────────────────────────

echo "CTX Customer Pack Installer"
echo ""

if [ -z "$PACKAGE" ]; then
  if $NON_INTERACTIVE; then echo "Error: --package required with --non-interactive"; exit 1; fi
  echo "Which package?"
  echo "  1) core       — Skills for your AI agent"
  echo "  2) loader     — Data loading CLI (includes core)"
  echo "  3) all        — Everything"
  read -rp "Choice [1-3]: " choice
  case $choice in 1) PACKAGE="core" ;; 2) PACKAGE="loader" ;; 3) PACKAGE="all" ;; *) echo "Invalid."; exit 1 ;; esac
fi

if [ -z "$AGENT" ]; then
  if $NON_INTERACTIVE; then echo "Error: --agent required with --non-interactive"; exit 1; fi
  read -rp "Agent (claude/cursor/gemini/tabnine): " AGENT
fi

packages=$(resolve_packages "$PACKAGE")

# Resolve BIN_DIR if not set via --bin-dir
if [ -z "$BIN_DIR" ]; then
  BIN_DIR=$(detect_bin_dir)
fi

for pkg in $packages; do
  case $pkg in
    core) install_core "$AGENT" ;;
    cli) install_cli ;;
    loader) install_loader ;;
    onboarder) install_onboarder "$AGENT" ;;
  esac
done

# ── Post-install instructions ────────────────────────────────────

echo ""

# Detect shell rc file (used for both PATH and env var instructions)
shell_name=$(basename "${SHELL:-/bin/bash}")
case $shell_name in
  zsh)  rc_file="${HOME}/.zshrc" ;;
  bash)
    if [ "$(uname -s)" = "Darwin" ]; then
      rc_file="${HOME}/.bash_profile"
    else
      rc_file="${HOME}/.bashrc"
    fi
    ;;
  fish) rc_file="${HOME}/.config/fish/config.fish" ;;
  *)    rc_file="${HOME}/.profile" ;;
esac

if [[ "$packages" == *"loader"* || "$packages" == *"onboarder"* ]]; then
  abs_bin=$(cd "$BIN_DIR" 2>/dev/null && pwd || echo "$BIN_DIR")

  if [ "$shell_name" = "fish" ]; then
    path_line="fish_add_path ${abs_bin}"
  else
    path_line="export PATH=\"${abs_bin}:\$PATH\""
  fi

  echo "CLIs installed to: ${abs_bin}"
  echo ""
  echo "If not already in your PATH, add it permanently:"
  echo ""
  echo "  echo '${path_line}' >> ${rc_file}"
  echo ""
  echo "Verify:"
  [[ "$packages" == *"cli"* ]] && echo "  ctx-cli --version"
  [[ "$packages" == *"loader"* ]] && echo "  ctx-loader --version"
  [[ "$packages" == *"onboarder"* ]] && echo "  ctx-onboard --version"
  echo ""
fi

echo "Next steps:"
echo ""
echo "  1. Start your AI agent (e.g. Claude Code) in this directory"
echo "  2. Run /onboard — it will guide you through creating ctx-settings.yaml"
echo "     with your Context Engine URL, API key, and repository details"
echo ""
echo "  Or create ctx-settings.yaml manually:"
echo ""
echo "    CTX_API_URL: https://ctx.your-company.com"
echo "    CTX_API_KEY: ctx_your_key_here"
echo "    PROJECT_NAME: my-project"
echo "    GITHUB_ORG: your-org"
echo "    GITHUB_REPO: your-repo"
echo "    DATA_VOLUME: standard"
echo "    GH_PAT: ghp_your_token_here"
