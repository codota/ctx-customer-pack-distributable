---
name: confluence-tools
description: >-
  Confluence tools: add_confluence_comment, create_confluence_page,
  get_confluence_page, search_confluence_pages, update_confluence_page
allowed-tools: >-
  mcp__ctx-cloud__add_confluence_comment,
  mcp__ctx-cloud__create_confluence_page, mcp__ctx-cloud__get_confluence_page,
  mcp__ctx-cloud__search_confluence_pages,
  mcp__ctx-cloud__update_confluence_page
---
# Confluence Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## add_confluence_comment

Add a footer comment to a Confluence page. Requires a connected and enabled Confluence data source. Comments are visible at the bottom of the page.

Call `mcp__ctx-cloud__add_confluence_comment` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| pageId | string | Yes | The ID of the Confluence page to comment on. |
| body | string | Yes | The comment content in Confluence storage format (XHTML). For example: "<p>This looks good!</p>". |

## create_confluence_page

Create a new page in a Confluence space. Requires a connected and enabled Confluence data source. The body should be in Confluence storage format (XHTML). Returns the created page ID, title, and URL.

Call `mcp__ctx-cloud__create_confluence_page` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| spaceId | string | Yes | The Confluence space ID to create the page in. This is the space's internal ID (not the human-readable key). Use search_confluence_pages with CQL 'type = "space"' to find space IDs. |
| title | string | Yes | The title of the new page. |
| body | string | Yes | The page content in Confluence storage format (XHTML). For example: "<p>Hello world</p>" or "<h1>Title</h1><p>Content</p>". |
| parentId | string | No | Optional parent page ID. If provided, the new page will be created as a child of this page. |
| status | string | No | Page status. Defaults to "current" (published). Use "draft" for unpublished pages. |

## get_confluence_page

Retrieve a Confluence page's content and metadata. Use this to get page context before updating, including the current version number needed for updates. Requires a connected and enabled Confluence data source.

Call `mcp__ctx-cloud__get_confluence_page` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| pageId | string | Yes | The ID of the Confluence page to retrieve. |

## search_confluence_pages

Search for Confluence pages using CQL (Confluence Query Language). Requires a connected and enabled Confluence data source. Example queries: 'title = "Meeting Notes"', 'space = "ENG" AND type = "page"', 'text ~ "deployment"'.

Call `mcp__ctx-cloud__search_confluence_pages` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | CQL query string. Examples: 'title = "Page Title"', 'space = "ENG" AND text ~ "search term"', 'label = "runbook"'. |
| limit | number | No | Maximum number of results to return. Defaults to 10. |

## update_confluence_page

Update an existing Confluence page's content. Requires a connected and enabled Confluence data source. You must provide the current version number (incremented by 1). Use get_confluence_page first to retrieve the current version.

Call `mcp__ctx-cloud__update_confluence_page` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| pageId | string | Yes | The ID of the Confluence page to update. |
| title | string | Yes | The updated title of the page. |
| body | string | Yes | The updated page content in Confluence storage format (XHTML). |
| version | number | Yes | The new version number. Must be the current version + 1. Use get_confluence_page to retrieve the current version first. |
