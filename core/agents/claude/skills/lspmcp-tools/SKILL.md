---
name: lspmcp-tools
description: >-
  Lspmcp tools: semantic_find_referencing_symbols, semantic_find_symbol,
  semantic_get_symbols_overview, semantic_insert_after_symbol,
  semantic_list_dir, semantic_read_file, semantic_replace_symbol_body,
  semantic_search_for_pattern
allowed-tools: 'Bash(ctx-cli:*)'
---
# Lspmcp Tools

> Auto-generated from 8 exported tool(s) in the Context Engine.

## semantic_find_referencing_symbols

Find symbols that reference a given symbol. Useful for finding all usages of a class, function, method, or variable across the codebase using semantic analysis. Requires a connected git repository data source.

```bash
ctx-cli mcp call semantic_find_referencing_symbols -p project_id=<string> -p name_path_pattern=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID to search in (UUID of the connected git repository) |
| name_path_pattern | string | Yes | Symbol name to find references for (e.g., "UserService", "processData") |
| depth | number | No | Search depth for nested references |
| include_body | boolean | No | Include the body of referencing symbols in results |

## semantic_find_symbol

Global symbol search with filtering by kind, depth, and substring matching. Find classes, functions, methods, variables, and other symbols in a codebase using semantic analysis. Requires a connected git repository data source.

```bash
ctx-cli mcp call semantic_find_symbol -p project_id=<string> -p name_path_pattern=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID to search in (UUID of the connected git repository) |
| name_path_pattern | string | Yes | Symbol name or pattern to search for (e.g., "UserService", "handleRequest") |
| depth | number | No | Search depth (0 for shallow, higher for deeper nested symbols) |
| relative_path | string | No | Restrict search to a specific file path |
| include_body | boolean | No | Include the symbol body/implementation in results |
| substring_matching | boolean | No | Enable substring matching for the symbol name |

## semantic_get_symbols_overview

Get a high-level understanding of code symbols in a file. Returns an overview of classes, functions, methods, and other symbols defined in the file. Requires a connected git repository data source.

```bash
ctx-cli mcp call semantic_get_symbols_overview -p project_id=<string> -p relative_path=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID (UUID of the connected git repository) |
| relative_path | string | Yes | Path to the file relative to project root (e.g., "src/services/user.ts") |

## semantic_insert_after_symbol

Insert content after a symbol definition. Uses semantic analysis to find the exact end of a symbol and insert new code. Useful for adding new methods to a class or functions after existing ones. Requires a connected git repository.

```bash
ctx-cli mcp call semantic_insert_after_symbol -p project_id=<string> -p name_path_pattern=<string> -p content=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID (UUID of the connected git repository) |
| name_path_pattern | string | Yes | Symbol name to insert after (e.g., "UserService.handleRequest") |
| content | string | Yes | Content to insert after the symbol |
| relative_path | string | No | File path if symbol name is ambiguous across files |

## semantic_list_dir

List directory contents in a connected git repository. Use this to explore the file structure of git-connected data sources. Requires a connected git repository data source.

```bash
ctx-cli mcp call semantic_list_dir -p project_id=<string> -p relative_path=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID (UUID of the connected git repository) |
| relative_path | string | Yes | Directory path relative to project root (e.g., "src/services") |
| recursive | boolean | No | List recursively (default false) |
| max_depth | number | No | Maximum recursion depth when recursive is true |

## semantic_read_file

Read file contents from a connected git repository with optional line range. Use this to view source code from git-connected data sources. Requires a connected git repository data source.

```bash
ctx-cli mcp call semantic_read_file -p project_id=<string> -p relative_path=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID (UUID of the connected git repository) |
| relative_path | string | Yes | Path to the file relative to project root (e.g., "src/index.ts") |
| start_line | number | No | Start line number (1-indexed) |
| end_line | number | No | End line number (1-indexed) |

## semantic_replace_symbol_body

Replace the full definition/body of a symbol (class, function, method). Uses semantic analysis to find the exact symbol boundaries and replace the entire implementation. Requires a connected git repository data source.

```bash
ctx-cli mcp call semantic_replace_symbol_body -p project_id=<string> -p name_path_pattern=<string> -p new_body=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID (UUID of the connected git repository) |
| name_path_pattern | string | Yes | Symbol name to replace (e.g., "UserService.handleRequest") |
| new_body | string | Yes | The new body/implementation for the symbol |
| relative_path | string | No | File path if symbol name is ambiguous across files |

## semantic_search_for_pattern

Search files for regex patterns within a connected git repository. Use this to find specific code patterns, TODO comments, or text across the codebase. Requires a connected git repository data source.

```bash
ctx-cli mcp call semantic_search_for_pattern -p project_id=<string> -p pattern=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | string | Yes | The project/data source ID (UUID of the connected git repository) |
| pattern | string | Yes | Regex pattern to search for |
| file_mask | string | No | Glob pattern for files to search (e.g., "*.ts", "**/*.py") |
| relative_path | string | No | Directory to search in (relative to project root) |
| case_sensitive | boolean | No | Case-sensitive search (default true) |
