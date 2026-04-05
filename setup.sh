#!/usr/bin/env bash
set -euo pipefail

# OpenWiki — One-command setup
# Usage: openwiki-setup [target-directory]
#   target-directory: where to create the wiki (default: ./wiki)

WIKI_ROOT="${1:-./wiki}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🦞 OpenWiki Setup"
echo "=================="
echo ""

# --- Create directory structure ---
echo "Creating wiki structure at: $WIKI_ROOT"
mkdir -p "$WIKI_ROOT"/{raw/articles,raw/agent-sync/conversations,raw/assets,entities,concepts,sources,comparisons,synthesis}

# --- Write SCHEMA.md ---
if [[ ! -f "$WIKI_ROOT/SCHEMA.md" ]]; then
cat > "$WIKI_ROOT/SCHEMA.md" << 'SCHEMA'
# Wiki Schema

> Maintenance rules for this LLM Wiki. All agents must read this before operating on wiki/.

## Architecture

- **Raw** (`wiki/raw/`) — Source materials, read-only
- **Wiki** (subdirectories) — LLM-compiled pages, LLM owns write access
- **Schema** (this file) — Rules, co-evolved by human and LLM

## Page Template

```yaml
---
title: Page Title
tags: [entity]
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - "[[sources/source-name]]"
related:
  - "[[related-page]]"
---
```

## Operations

### Ingest
1. Read raw source → 2. Write source summary → 3. Update entity/concept pages → 4. Update index.md → 5. Append log.md

### Query
1. Read index.md → 2. Find relevant pages → 3. Synthesize answer → 4. File good answers to synthesis/

### Lint
Check: orphan pages, stale info, contradictions, missing links, concept candidates.
Output: wiki/lint-report.md

## Naming

| Directory | Format | Example |
|-----------|--------|---------|
| entities/ | `{name}.md` | `project-alpha.md` |
| concepts/ | `{kebab-case}.md` | `memory-system.md` |
| sources/ | `source-{slug}.md` | `source-karpathy-llm-wiki.md` |
| comparisons/ | `compare-{a}-vs-{b}.md` | `compare-rag-vs-wiki.md` |
| synthesis/ | `{date}-{slug}.md` | `2026-04-05-api-comparison.md` |

## Wikilinks

Use Obsidian format: `[[page-name]]` or `[[page-name|display text]]`
SCHEMA
echo "  ✓ SCHEMA.md"
fi

# --- Write index.md ---
if [[ ! -f "$WIKI_ROOT/index.md" ]]; then
cat > "$WIKI_ROOT/index.md" << 'INDEX'
---
title: Wiki Index
tags: [index]
created: $(date +%Y-%m-%d)
updated: $(date +%Y-%m-%d)
---

# Wiki Index

> Master directory. Updated by LLM after each ingest.
> Read this first to find relevant pages, then drill into them.
> Rules: [[SCHEMA]]

## Entities

_No entities yet. Run your first ingest to populate._

## Concepts

_No concepts yet._

## Sources

_No sources yet. Drop files into `wiki/raw/articles/` and run ingest._

## Comparisons

_No comparisons yet._

## Synthesis

_No synthesis yet. Ask questions to populate._
INDEX
echo "  ✓ index.md"
fi

# --- Write log.md ---
if [[ ! -f "$WIKI_ROOT/log.md" ]]; then
cat > "$WIKI_ROOT/log.md" << LOG
---
title: Wiki Log
tags: [log]
created: $(date +%Y-%m-%d)
updated: $(date +%Y-%m-%d)
---

# Wiki Operation Log

> Append-only. Format: \`## [YYYY-MM-DD] type | title\`

## [$(date +%Y-%m-%d)] init | Wiki initialized
- Created directory structure
- Ready for first ingest
LOG
echo "  ✓ log.md"
fi

# --- Install qmd ---
echo ""
echo "Checking qmd search engine..."
if command -v qmd &> /dev/null; then
  echo "  ✓ qmd $(qmd --version 2>/dev/null || echo '') already installed"
else
  echo "  Installing qmd..."
  npm install -g @tobilu/qmd
  echo "  ✓ qmd installed"
fi

# --- Configure qmd collection ---
echo ""
echo "Configuring search index..."
WIKI_ABS=$(cd "$WIKI_ROOT" && pwd)
if qmd collection list 2>/dev/null | grep -q "wiki"; then
  echo "  ✓ qmd collection 'wiki' already exists"
else
  qmd collection add "$WIKI_ABS" --name wiki 2>/dev/null || true
  qmd context add qmd://wiki "LLM-compiled knowledge base with entities, concepts, source summaries, and Q&A synthesis" 2>/dev/null || true
  echo "  ✓ qmd collection 'wiki' configured"
fi

# --- .gitignore ---
PARENT_DIR=$(dirname "$WIKI_ABS")
GITIGNORE="$PARENT_DIR/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
  grep -q ".obsidian" "$GITIGNORE" || echo -e "\n.obsidian/" >> "$GITIGNORE"
else
  echo -e ".obsidian/\n.DS_Store\nwiki/raw/agent-sync/" > "$GITIGNORE"
fi
echo "  ✓ .gitignore updated"

# --- Done ---
echo ""
echo "=================="
echo "✓ OpenWiki ready!"
echo ""
echo "Next steps:"
echo "  1. Open the parent directory in Obsidian as a vault"
echo "  2. Drop source files into: $WIKI_ROOT/raw/articles/"
echo "  3. Tell your LLM agent: \"ingest the new articles into the wiki\""
echo ""
echo "Search:  qmd search \"keyword\""
echo "Wiki:    $WIKI_ABS"
