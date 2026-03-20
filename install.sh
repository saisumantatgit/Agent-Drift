#!/bin/bash
# Agent-Drift Installer
# Detects your CLI tool and installs the right adapter.

set -e

echo "⚡ Agent-Drift Installer"
echo "========================"
echo ""

# Detect CLI tool
if [ -d ".claude" ]; then
    CLI="claude-code"
    echo "Detected: Claude Code"
elif [ -d ".cursor" ]; then
    CLI="cursor"
    echo "Detected: Cursor"
elif [ -f ".aider.conf.yml" ]; then
    CLI="aider"
    echo "Detected: Aider"
elif [ -f "AGENTS.md" ]; then
    CLI="codex"
    echo "Detected: Codex"
else
    CLI="generic"
    echo "No specific CLI detected — installing generic prompts"
fi

echo ""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Copy core prompts
if [ -d "prompts" ]; then echo "WARNING: Existing prompts/ directory will be overwritten"; fi
echo "Installing prompts..."
cp -r "$SCRIPT_DIR/prompts" .

# Copy references
if [ -d "references" ]; then echo "WARNING: Existing references/ directory will be overwritten"; fi
echo "Installing references..."
cp -r "$SCRIPT_DIR/references" .

# Copy drift protocol template
echo "Installing drift protocol template..."
if [ ! -f "drift-protocol.yaml" ] && [ ! -f ".drift/drift-protocol.yaml" ]; then
    cp "$SCRIPT_DIR/templates/drift-protocol.yaml" .
    echo "  Created drift-protocol.yaml (customize for your project)"
else
    echo "  Skipped (drift-protocol.yaml already exists)"
fi

# Install CLI-specific adapter
echo ""
echo "Installing $CLI adapter..."
case $CLI in
    claude-code)
        mkdir -p .claude/commands .claude/agents .claude/skills/{intent-capture,drift-analysis,constraint-enforcement,status-dashboard,session-audit}
        cp "$SCRIPT_DIR/adapters/claude-code/commands/"*.md .claude/commands/
        cp "$SCRIPT_DIR/.claude/agents/"*.md .claude/agents/
        cp "$SCRIPT_DIR/.claude/skills/intent-capture/SKILL.md" .claude/skills/intent-capture/
        cp "$SCRIPT_DIR/.claude/skills/drift-analysis/SKILL.md" .claude/skills/drift-analysis/
        cp "$SCRIPT_DIR/.claude/skills/constraint-enforcement/SKILL.md" .claude/skills/constraint-enforcement/
        cp "$SCRIPT_DIR/.claude/skills/status-dashboard/SKILL.md" .claude/skills/status-dashboard/
        cp "$SCRIPT_DIR/.claude/skills/session-audit/SKILL.md" .claude/skills/session-audit/
        echo ""
        echo "Plugin hook: Add this to your .claude/settings.json hooks:"
        echo '  "hooks": { "SessionStart": [{ "command": "echo ⚡ Agent-Drift loaded. Commands: /drift-lock, /drift-check, /drift-fence, /drift-status, /drift-report" }] }'
        ;;
    codex)
        if [ -f "AGENTS.md" ]; then
            if ! grep -q "# Agent-Drift" AGENTS.md 2>/dev/null; then
                echo "" >> AGENTS.md
                cat "$SCRIPT_DIR/adapters/codex/AGENTS.md" >> AGENTS.md
                echo "Appended drift protocol to existing AGENTS.md"
            else
                echo "Agent-Drift already present in AGENTS.md — skipped"
            fi
        else
            cp "$SCRIPT_DIR/adapters/codex/AGENTS.md" .
        fi
        ;;
    cursor)
        mkdir -p .cursor/rules
        cp "$SCRIPT_DIR/adapters/cursor/.cursor/rules/drift.md" .cursor/rules/
        ;;
    aider)
        if [ -f ".aider.conf.yml" ]; then
            if ! grep -q "agent-drift" .aider.conf.yml 2>/dev/null; then
                echo "" >> .aider.conf.yml
                cat "$SCRIPT_DIR/adapters/aider/.aider.conf.yml" >> .aider.conf.yml
                echo "Appended drift protocol to existing .aider.conf.yml"
            else
                echo "Agent-Drift already present in .aider.conf.yml — skipped"
            fi
        else
            cp "$SCRIPT_DIR/adapters/aider/.aider.conf.yml" .
        fi
        ;;
    generic)
        echo "Prompts and references installed. See prompts/ for usage."
        ;;
esac

echo ""
echo "✅ Agent-Drift installed for $CLI"
echo ""
echo "Commands available:"
echo "  /drift-lock <instructions>  — Lock instructions into a structured spec"
echo "  /drift-check                — Check for drift against the spec"
echo "  /drift-fence <constraint>   — Add an enforceable constraint mid-session"
echo "  /drift-status               — Quick status dashboard"
echo "  /drift-report               — End-of-session compliance report"
echo ""
echo "Next steps:"
echo "  1. Run /drift-lock with your task instructions"
echo "  2. Work on the task — Agent-Drift monitors for drift"
echo "  3. Run /drift-report at session end for compliance verdict"
