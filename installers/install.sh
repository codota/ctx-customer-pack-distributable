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
BIN_DIR="${HOME}/bin"

while [[ $# -gt 0 ]]; do
  case $1 in
    --package) PACKAGE="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --bin-dir) BIN_DIR="$2"; shift 2 ;;
    --branch) BRANCH="$2"; RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"; API_BASE="https://api.github.com/repos/${REPO}/contents"; shift 2 ;;
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

# List directory entries from GitHub API
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

# ── Install core skills ─────────────────────────────────────────

install_core() {
  local agent=$1
  echo "  Installing core skills for ${agent}..."

  local skills
  local count=0

  case $agent in
    claude)
      skills=$(list_github_dir "core/agents/claude/skills")
      mkdir -p .claude/skills
      for skill in $skills; do
        mkdir -p ".claude/skills/${skill}"
        if fetch "${RAW_BASE}/core/agents/claude/skills/${skill}/SKILL.md" ".claude/skills/${skill}/SKILL.md"; then
          count=$((count + 1))
        fi
      done

      # Also fetch hooks and MCP proxy
      mkdir -p .claude/hooks .claude/scripts
      fetch "${RAW_BASE}/core/agents/claude/hooks/decision-context.py" ".claude/hooks/decision-context.py" || true
      fetch "${RAW_BASE}/core/agents/claude/hooks/change-confidence.py" ".claude/hooks/change-confidence.py" || true
      fetch "${RAW_BASE}/core/agents/claude/scripts/ctx-mcp-proxy.py" ".claude/scripts/ctx-mcp-proxy.py" || true
      ;;

    cursor)
      skills=$(list_github_dir "core/agents/cursor/.cursor/skills")
      mkdir -p .cursor/skills .cursor/rules
      for skill in $skills; do
        mkdir -p ".cursor/skills/${skill}"
        if fetch "${RAW_BASE}/core/agents/cursor/.cursor/skills/${skill}/SKILL.md" ".cursor/skills/${skill}/SKILL.md"; then
          count=$((count + 1))
        fi
        fetch "${RAW_BASE}/core/agents/cursor/.cursor/rules/${skill}.mdc" ".cursor/rules/${skill}.mdc" 2>/dev/null || true
      done
      ;;

    gemini)
      skills=$(list_github_dir "core/agents/gemini/.gemini/skills")
      mkdir -p .gemini/skills
      for skill in $skills; do
        mkdir -p ".gemini/skills/${skill}"
        if fetch "${RAW_BASE}/core/agents/gemini/.gemini/skills/${skill}/SKILL.md" ".gemini/skills/${skill}/SKILL.md"; then
          count=$((count + 1))
        fi
      done
      ;;

    tabnine)
      skills=$(list_github_dir "core/agents/tabnine/.tabnine/agent/skills")
      mkdir -p "${HOME}/.tabnine/agent/skills"
      for skill in $skills; do
        mkdir -p "${HOME}/.tabnine/agent/skills/${skill}"
        if fetch "${RAW_BASE}/core/agents/tabnine/.tabnine/agent/skills/${skill}/SKILL.md" "${HOME}/.tabnine/agent/skills/${skill}/SKILL.md"; then
          count=$((count + 1))
        fi
      done
      ;;

    *) echo "    Unknown agent: ${agent}"; return ;;
  esac

  echo "    ${count} skills installed."
}

# ── Install loader CLI ───────────────────────────────────────────

install_loader() {
  echo "  Installing ctx-loader CLI..."
  mkdir -p "$BIN_DIR"
  if fetch "${RAW_BASE}/loader/bin/ctx-loader" "${BIN_DIR}/ctx-loader"; then
    chmod +x "${BIN_DIR}/ctx-loader"
    echo "    Installed → ${BIN_DIR}/ctx-loader"
  else
    echo "    Failed to download ctx-loader."
  fi
}

# ── Install onboarder CLI + skills ───────────────────────────────

install_onboarder() {
  local agent=$1
  echo "  Installing ctx-onboard CLI..."
  mkdir -p "$BIN_DIR"
  if fetch "${RAW_BASE}/onboarder/bin/ctx-onboard" "${BIN_DIR}/ctx-onboard"; then
    chmod +x "${BIN_DIR}/ctx-onboard"
    echo "    Installed → ${BIN_DIR}/ctx-onboard"
  else
    echo "    Failed to download ctx-onboard."
  fi

  # Install onboarding skills for the agent
  local ob_skills="onboard-init onboard-test-lab onboard-load onboard-baseline onboard-domain onboard-measure onboard-rollout"
  local skill_dir=""
  case $agent in
    claude)  skill_dir=".claude/skills" ;;
    cursor)  skill_dir=".cursor/skills" ;;
    gemini)  skill_dir=".gemini/skills" ;;
    *) return ;;
  esac

  local count=0
  for skill in $ob_skills; do
    mkdir -p "${skill_dir}/${skill}"
    if fetch "${RAW_BASE}/onboarder/skills/${skill}/SKILL.md" "${skill_dir}/${skill}/SKILL.md"; then
      count=$((count + 1))
    fi
  done
  echo "    ${count} onboarding skills installed."
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
echo "Installing: ${packages}"
echo ""

for pkg in $packages; do
  case $pkg in
    core) install_core "$AGENT" ;;
    loader) install_loader ;;
    onboarder) install_onboarder "$AGENT" ;;
  esac
done

if [[ ":$PATH:" != *":${BIN_DIR}:"* ]] && [[ "$packages" == *"loader"* || "$packages" == *"onboarder"* ]]; then
  echo ""
  echo "Add to PATH: export PATH=\"${BIN_DIR}:\$PATH\""
fi

echo ""
echo "Done. Set CTX_API_URL and CTX_API_KEY to connect."
