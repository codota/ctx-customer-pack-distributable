---
name: servicenow-tools
description: >-
  Servicenow tools: add_servicenow_work_note, create_servicenow_change_request,
  create_servicenow_incident, list_servicenow_incidents,
  update_servicenow_incident
allowed-tools: >-
  mcp__ctx-cloud__add_servicenow_work_note,
  mcp__ctx-cloud__create_servicenow_change_request,
  mcp__ctx-cloud__create_servicenow_incident,
  mcp__ctx-cloud__list_servicenow_incidents,
  mcp__ctx-cloud__update_servicenow_incident
---
# Servicenow Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## add_servicenow_work_note

Add a work note to an existing ServiceNow record (incident, change request, or problem). Requires a connected and enabled ServiceNow data source. Work notes are internal comments visible only to IT staff.

Call `mcp__ctx-cloud__add_servicenow_work_note` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| table | string | Yes | The ServiceNow table name. Must be one of: "incident", "change_request", "problem". Other table names are not supported. |
| sys_id | string | Yes | The sys_id of the record to add the work note to. |
| work_notes | string | Yes | The work note content to add to the record. |

## create_servicenow_change_request

Create a new ServiceNow change request. Requires a connected and enabled ServiceNow data source. Returns the created change request number and sys_id.

Call `mcp__ctx-cloud__create_servicenow_change_request` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| short_description | string | Yes | Brief summary of the change request (one-line title). |
| description | string | No | Detailed description of the change, including justification and plan. |
| type | string | No | Change type: "Normal", "Standard", or "Emergency". Defaults to "Normal". |
| priority | string | No | Priority level: "1" (Critical), "2" (High), "3" (Moderate), "4" (Low). |
| risk | string | No | Risk level: "1" (High), "2" (Medium), "3" (Low). |
| impact | string | No | Impact level: "1" (High), "2" (Medium), "3" (Low). |
| category | string | No | Change category (e.g., "Software", "Hardware", "Network"). |
| assignment_group | string | No | Sys ID of the assignment group for the change request. |
| start_date | string | No | Planned start date in ISO 8601 format (e.g., "2025-06-15T10:00:00Z"). |
| end_date | string | No | Planned end date in ISO 8601 format (e.g., "2025-06-15T12:00:00Z"). |

## create_servicenow_incident

Create a new ServiceNow incident. Requires a connected and enabled ServiceNow data source. Returns the created incident number and sys_id.

Call `mcp__ctx-cloud__create_servicenow_incident` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| short_description | string | Yes | Brief summary of the incident (one-line title). |
| description | string | No | Detailed description of the incident. Defaults to empty if omitted. |
| urgency | string | No | Urgency level: "1" (High), "2" (Medium), "3" (Low). Defaults to "3". |
| impact | string | No | Impact level: "1" (High), "2" (Medium), "3" (Low). Defaults to "3". |
| category | string | No | Incident category (e.g., "Software", "Hardware", "Network"). |
| assignment_group | string | No | Sys ID of the assignment group to assign the incident to. |
| caller_id | string | No | Sys ID or user name of the caller reporting the incident. |

## list_servicenow_incidents

List or search ServiceNow incidents. Requires a connected and enabled ServiceNow data source. Supports filtering by state, priority, assignment group, and encoded query. Returns up to the specified limit of incidents.

Call `mcp__ctx-cloud__list_servicenow_incidents` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| state | string | No | Filter by incident state: "1" (New), "2" (In Progress), "3" (On Hold), "6" (Resolved), "7" (Closed). Omit to return all states. |
| priority | string | No | Filter by priority: "1" (Critical), "2" (High), "3" (Moderate), "4" (Low), "5" (Planning). |
| assignment_group | string | No | Filter by assignment group sys_id. |
| sysparm_query | string | No | ServiceNow encoded query string for advanced filtering (e.g., "short_descriptionLIKEnetwork^priority=1"). Combined with individual filters (state, priority, assignment_group) when both are provided. Avoid including '&' or '=' characters that could inject additional query parameters into the URL. |
| sysparm_limit | string | No | Maximum number of incidents to return. Defaults to "20". |

## update_servicenow_incident

Update an existing ServiceNow incident. Requires a connected and enabled ServiceNow data source. IMPORTANT: All fields in the request body are sent to ServiceNow — omitted optional parameters are sent as empty strings, which may clear those fields. Only call this tool with ALL fields you want to preserve on the record.

Call `mcp__ctx-cloud__update_servicenow_incident` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sys_id | string | Yes | The sys_id of the incident to update. |
| state | string | No | Incident state: "1" (New), "2" (In Progress), "3" (On Hold), "6" (Resolved), "7" (Closed). |
| short_description | string | No | Updated brief summary of the incident. |
| urgency | string | No | Urgency level: "1" (High), "2" (Medium), "3" (Low). |
| impact | string | No | Impact level: "1" (High), "2" (Medium), "3" (Low). |
| assignment_group | string | No | Sys ID of the assignment group to reassign the incident to. |
| assigned_to | string | No | Sys ID of the user to assign the incident to. |
| close_code | string | No | Resolution code when resolving or closing (e.g., "Solved (Permanently)", "Solved (Work Around)", "Not Solved"). |
| close_notes | string | No | Resolution notes describing how the incident was resolved. |
