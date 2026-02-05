# AI Agents & Skills Guide

This repository contains specialized "skills" for AI agents to assist with development workflows. These skills are located in the `.agents/skills/` directory.

## Available Skills

### 1. `git-commit`
**Location**: [.agents/skills/git-commit/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/git-commit/SKILL.md)

**What it does**:
- Analyzes staged and unstaged changes.
- Generates standardized **Conventional Commits** messages (e.g., `feat: add new script`).
- Can auto-stage files if requested.

**Usage**:
- Ask the agent: *"Commit these changes"*, *"Create a fix commit"*, or *"Stage and commit"*.

### 2. `context7`
**Location**: [.agents/skills/context7/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/context7/SKILL.md)

**What it does**:
- Connects to the **Context7 MCP Server**.
- Provides real-time, up-to-date documentation and code examples for libraries to prevent hallucinations.

**Configuration**:
- Requires an API key in `.env`: `CONTEXT7_API_KEY=...`
- See [.agents/skills/context7/mcp_config.json](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/context7/mcp_config.json) for the MCP server config block.

### 3. `bash-pro`
**Location**: [.agents/skills/bash-pro/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/bash-pro/SKILL.md)
**Purpose**: Expert Bash scripting patterns, safety checks, and performance tips.

### 4. `hyprland`
**Location**: [.agents/skills/hyprland/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/hyprland/SKILL.md)
**Purpose**: Configuration and management of Hyprland (Wayland compositor).

### 5. `docker-expert`
**Location**: [.agents/skills/docker-expert/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/docker-expert/SKILL.md)
**Purpose**: Docker container management, Dockerfile best practices, and optimization.

### 6. `mise-en-place`
**Location**: [.agents/skills/mise-en-place/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/mise-en-place/SKILL.md)
**Purpose**: Structured PRD generation and task decomposition (`prd.json` creation).

### 7. `zsh-path-skill`
**Location**: [.agents/skills/zsh-path-skill/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/zsh-path-skill/SKILL.md)
**Purpose**: Troubleshooting and managing Zsh PATH issues.

### 8. `markdown-documentation`
**Location**: [.agents/skills/markdown-documentation/SKILL.md](file:///home/debasmitr/workspace/dotFileV2/.agents/skills/markdown-documentation/SKILL.md)
**Purpose**: Templates and best practices for writing documentation.

## Directory Structure

```
.agents/
└── skills/
    ├── git-commit/
    ├── context7/
    ├── bash-pro/
    ├── hyprland/
    ├── docker-expert/
    ├── mise-en-place/
    ├── zsh-path-skill/
    └── markdown-documentation/
```
