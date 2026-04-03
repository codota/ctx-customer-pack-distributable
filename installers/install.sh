#!/usr/bin/env bash
set -euo pipefail

# CTX Customer Pack Installer
#
# Downloads and installs Context Engine packages directly from GitHub.
# No git clone required.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package core --agent claude
#   curl -fsSL .../install.sh | bash -s -- --package all --agent claude
#   curl -fsSL .../install.sh | bash -s -- --package loader --agent claude
#
# Environment:
#   CTX_API_URL  — Context Engine server URL
#   CTX_API_KEY  — API key (never passed as CLI flag)

REPO="codota/ctx-customer-pack-distributable"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

PACKAGE=""
AGENT=""
NON_INTERACTIVE=false
BIN_DIR="${HOME}/bin"
WORK_DIR=""

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
      echo "Options:"
      echo "  --package core|loader|onboarder|all   Package to install"
      echo "  --agent claude|cursor|gemini|tabnine   Target agent"
      echo "  --bin-dir <path>                       CLI install dir (default: ~/bin)"
      echo "  --non-interactive                      No prompts"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

cleanup() {
  if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
  fi
}
trap cleanup EXIT

fetch() {
  local url=$1
  local dest=$2
  mkdir -p "$(dirname "$dest")"
  curl -fsSL "$url" -o "$dest"
}

resolve_packages() {
  case $1 in
    core) echo "core" ;;
    loader) echo "core loader" ;;
    onboarder|all) echo "core loader onboarder" ;;
    *) echo "Unknown package: $1" >&2; exit 1 ;;
  esac
}

# ── Fetch skill list from GitHub ─────────────────────────────────

fetch_skill_list() {
  local agent=$1
  local path_prefix=$2
  # Use GitHub API to list directory contents
  local api_url="https://api.github.com/repos/${REPO}/contents/${path_prefix}?ref=${BRANCH}"
  curl -fsSL "$api_url" 2>/dev/null | grep '"name"' | sed 's/.*"name": "\(.*\)".*/\1/' || echo ""
}

# ── Install core ─────────────────────────────────────────────────

install_core() {
  local agent=$1
  echo "  Installing core skills for ${agent}..."

  case $agent in
    claude)
      # For Claude: download the full plugin bundle
      WORK_DIR=$(mktemp -d)
      local plugin_dir="${WORK_DIR}/claude-plugin"
      mkdir -p "${plugin_dir}/.claude-plugin" "${plugin_dir}/skills" "${plugin_dir}/hooks" "${plugin_dir}/scripts"

      fetch "${RAW_BASE}/core/agents/claude/.claude-plugin/plugin.json" "${plugin_dir}/.claude-plugin/plugin.json"
      fetch "${RAW_BASE}/core/agents/claude/hooks/decision-context.py" "${plugin_dir}/hooks/decision-context.py"
      fetch "${RAW_BASE}/core/agents/claude/hooks/change-confidence.py" "${plugin_dir}/hooks/change-confidence.py"
      fetch "${RAW_BASE}/core/agents/claude/scripts/ctx-mcp-proxy.py" "${plugin_dir}/scripts/ctx-mcp-proxy.py"

      # Fetch skill list and download each
      local skills
      skills=$(fetch_skill_list "$agent" "core/agents/claude/skills")
      for skill in $skills; do
        fetch "${RAW_BASE}/core/agents/claude/skills/${skill}/SKILL.md" "${plugin_dir}/skills/${skill}/SKILL.md" 2>/dev/null || true
      done

      # Try plugin install, fall back to file copy
      if command -v claude >/dev/null 2>&1; then
        claude plugin install "${plugin_dir}/" 2>/dev/null && echo "    Installed as Claude plugin." || {
          cp -r "${plugin_dir}/skills/"* .claude/skills/ 2>/dev/null || true
          echo "    Copied skills (plugin install unavailable)."
        }
      else
        mkdir -p .claude/skills
        cp -r "${plugin_dir}/skills/"* .claude/skills/ 2>/dev/null || true
        echo "    Copied skills."
      fi
      ;;

    cursor)
      local skills
      skills=$(fetch_skill_list "$agent" "core/agents/cursor/.cursor/skills")
      mkdir -p .cursor/skills .cursor/rules
      for skill in $skills; do
        fetch "${RAW_BASE}/core/agents/cursor/.cursor/skills/${skill}/SKILL.md" ".cursor/skills/${skill}/SKILL.md" 2>/dev/null || true
        fetch "${RAW_BASE}/core/agents/cursor/.cursor/rules/${skill}.mdc" ".cursor/rules/${skill}.mdc" 2>/dev/null || true
      done
      echo "    Installed skills + rules."
      ;;

    gemini)
      local skills
      skills=$(fetch_skill_list "$agent" "core/agents/gemini/.gemini/skills")
      mkdir -p .gemini/skills
      for skill in $skills; do
        fetch "${RAW_BASE}/core/agents/gemini/.gemini/skills/${skill}/SKILL.md" ".gemini/skills/${skill}/SKILL.md" 2>/dev/null || true
      done
      echo "    Installed skills."
      ;;

    tabnine)
      local skills
      skills=$(fetch_skill_list "$agent" "core/agents/tabnine/.tabnine/agent/skills")
      mkdir -p "${HOME}/.tabnine/agent/skills"
      for skill in $skills; do
        fetch "${RAW_BASE}/core/agents/tabnine/.tabnine/agent/skills/${skill}/SKILL.md" "${HOME}/.tabnine/agent/skills/${skill}/SKILL.md" 2>/dev/null || true
      done
      echo "    Installed skills (global)."
      ;;

    *) echo "    Unknown agent: ${agent}" ;;
  esac
}

# ── Install loader CLI ───────────────────────────────────────────

install_loader() {
  echo "  Installing ctx-loader CLI..."
  mkdir -p "$BIN_DIR"
  fetch "${RAW_BASE}/loader/bin/ctx-loader" "${BIN_DIR}/ctx-loader"
  chmod +x "${BIN_DIR}/ctx-loader"
  echo "    Installed → ${BIN_DIR}/ctx-loader"
}

# ── Install onboarder CLI + skills ───────────────────────────────

install_onboarder() {
  local agent=$1
  echo "  Installing ctx-onboard CLI..."
  mkdir -p "$BIN_DIR"
  fetch "${RAW_BASE}/onboarder/bin/ctx-onboard" "${BIN_DIR}/ctx-onboard"
  chmod +x "${BIN_DIR}/ctx-onboard"
  echo "    Installed → ${BIN_DIR}/ctx-onboard"

  # Install onboarding skills for the agent
  local ob_skills="onboard-init onboard-test-lab onboard-load onboard-baseline onboard-domain onboard-measure onboard-rollout"
  case $agent in
    claude) local skill_dir=".claude/skills" ;;
    cursor) local skill_dir=".cursor/skills" ;;
    gemini) local skill_dir=".gemini/skills" ;;
    *) return ;;
  esac
  mkdir -p "$skill_dir"
  for skill in $ob_skills; do
    fetch "${RAW_BASE}/onboarder/skills/${skill}/SKILL.md" "${skill_dir}/${skill}/SKILL.md" 2>/dev/null || true
  done
  echo "    Installed onboarding skills."
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
