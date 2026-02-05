---
name: context7
description: 'Integration with Context7 Model Context Protocol (MCP) server. Provides up-to-date, version-specific documentation and code examples to the AI agent to prevent hallucinations and outdated code generation.'
license: MIT
allowed-tools: MCP
---

# Context7 MCP Integration

## Overview

Context7 is an automated documentation provider that integrates via the Model Context Protocol (MCP). It helps the agent access the latest library documentation, API references, and code examples without needing to browse the web manually for every query.

## Configuration

This skill requires an MCP configuration. A template is provided in `mcp_config.json`.

1.  **Get API Key**: Obtain your API key from [Context7](https://context7.com).
2.  **Configure Environment**: Ensure `CONTEXT7_API_KEY` is set in your `.env` file (added to `.gitignore` for security).
3.  **MCP Settings**: Add the server configuration to your MCP client settings (e.g., in VS Code, Cursor, or Claude Desktop).

### JSON Configuration Template

```json
{
  "mcpServers": {
    "context7": {
      "serverUrl": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

## Usage

Once configured, the agent can automatically query Context7 for:
- Library usage examples
- API parameter details
- Version-specific migration guides
