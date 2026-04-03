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
    loader) echo "core loader" ;;
    onboarder|all) echo "core loader onboarder" ;;
    *) echo "Unknown package: $1" >&2; exit 1 ;;
  esac
}

# ── Install functions ────────────────────────────────────────────

install_core() {
  local agent=$1
  local skills count=0

  echo "[core] Downloading skills for ${agent}..."

  case $agent in
    claude)
      skills=$(list_github_dir "core/agents/claude/skills")
      mkdir -p .claude/skills
      for skill in $skills; do
        mkdir -p ".claude/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/claude/skills/${skill}/SKILL.md" ".claude/skills/${skill}/SKILL.md" && count=$((count + 1))
      done
      mkdir -p .claude/hooks .claude/scripts
      fetch "${RAW_BASE}/core/agents/claude/hooks/decision-context.py" ".claude/hooks/decision-context.py" || true
      fetch "${RAW_BASE}/core/agents/claude/hooks/change-confidence.py" ".claude/hooks/change-confidence.py" || true
      fetch "${RAW_BASE}/core/agents/claude/scripts/ctx-mcp-proxy.py" ".claude/scripts/ctx-mcp-proxy.py" || true
      echo "[core] ${count} skills + 2 hooks + MCP proxy installed."
      ;;
    cursor)
      skills=$(list_github_dir "core/agents/cursor/.cursor/skills")
      mkdir -p .cursor/skills .cursor/rules
      for skill in $skills; do
        mkdir -p ".cursor/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/cursor/.cursor/skills/${skill}/SKILL.md" ".cursor/skills/${skill}/SKILL.md" && count=$((count + 1))
        fetch "${RAW_BASE}/core/agents/cursor/.cursor/rules/${skill}.mdc" ".cursor/rules/${skill}.mdc" 2>/dev/null || true
      done
      echo "[core] ${count} skills + ${count} rules installed."
      ;;
    gemini)
      skills=$(list_github_dir "core/agents/gemini/.gemini/skills")
      mkdir -p .gemini/skills
      for skill in $skills; do
        mkdir -p ".gemini/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/gemini/.gemini/skills/${skill}/SKILL.md" ".gemini/skills/${skill}/SKILL.md" && count=$((count + 1))
      done
      echo "[core] ${count} skills installed."
      ;;
    tabnine)
      skills=$(list_github_dir "core/agents/tabnine/.tabnine/agent/skills")
      mkdir -p "${HOME}/.tabnine/agent/skills"
      for skill in $skills; do
        mkdir -p "${HOME}/.tabnine/agent/skills/${skill}"
        fetch "${RAW_BASE}/core/agents/tabnine/.tabnine/agent/skills/${skill}/SKILL.md" "${HOME}/.tabnine/agent/skills/${skill}/SKILL.md" && count=$((count + 1))
      done
      echo "[core] ${count} skills installed."
      ;;
    *) echo "[core] Unknown agent: ${agent}"; return ;;
  esac
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
  [[ "$packages" == *"loader"* ]] && echo "  ctx-loader --version"
  [[ "$packages" == *"onboarder"* ]] && echo "  ctx-onboard --version"
  echo ""
fi

echo "To connect to the Context Engine, add to ${rc_file}:"
echo ""
if [ "$shell_name" = "fish" ]; then
  echo "  set -Ux CTX_API_URL https://ctx.your-company.com"
  echo "  set -Ux CTX_API_KEY ctx_your_key_here"
else
  echo "  export CTX_API_URL=https://ctx.your-company.com"
  echo "  export CTX_API_KEY=ctx_your_key_here"
fi
echo ""
echo "Then run: source ${rc_file}"
