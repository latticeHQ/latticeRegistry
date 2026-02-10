---
display_name: "Enterprise Search"
description: "Search across all of your company's tools in one place. Find anything across email, chat, documents, and wikis without switching between apps."
icon: "../../.icons/1f4cb.png"
verified: true
tags: ["search", "knowledge", "enterprise", "discovery"]
---

# Enterprise Search

Search across all of your company's tools in one place. Find anything across email, chat, documents, and wikis without switching between apps.

## Skills

| Name | Type | Description |
|------|------|-------------|
| `enterprise-search-digest` | command | Generate digests from across connected sources |
| `enterprise-search-search` | command | Search across all connected enterprise tools |
| `enterprise-search-knowledge-synthesis` | skill | Synthesize knowledge from multiple sources |
| `enterprise-search-search-strategy` | skill | Develop and optimize search strategies |
| `enterprise-search-source-management` | skill | Manage and organize connected data sources |

## MCP Servers

| Server | URL |
|--------|-----|
| slack | https://mcp.slack.com/mcp |
| notion | https://mcp.notion.com/mcp |
| guru | https://mcp.api.getguru.com/mcp |
| atlassian | https://mcp.atlassian.com/v1/mcp |
| asana | https://mcp.asana.com/v2/mcp |
| ms365 | https://microsoft365.mcp.claude.com/mcp |

## Connectors

| Category | Placeholder | Included servers | Other options |
|----------|-------------|-----------------|---------------|
| Chat | `~~chat` | Slack | Microsoft Teams, Discord |
| Email | `~~email` | Microsoft 365 | -- |
| Cloud storage | `~~cloud storage` | Microsoft 365 | Dropbox |
| Knowledge base | `~~knowledge base` | Notion, Guru | Confluence, Slite |
| Project tracker | `~~project tracker` | Atlassian (Jira/Confluence), Asana | Linear, monday.com |
| CRM | `~~CRM` | *(not pre-configured)* | Salesforce, HubSpot |
| Office suite | `~~office suite` | Microsoft 365 | Google Workspace |
