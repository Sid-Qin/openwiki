# OpenWiki

A personal knowledge base where the LLM does all the work.

Inspired by [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), adapted for [OpenClaw](https://openclaw.ai) agents.

## What is this?

Most people's experience with LLMs and documents is RAG: upload files, retrieve chunks at query time, generate answers. Nothing accumulates. Ask a subtle question tomorrow and the LLM starts from scratch.

This is different. Instead of retrieving from raw documents on every query, **your LLM agents incrementally build and maintain a persistent wiki** — a structured, interlinked collection of Markdown files. When you add a new source, the LLM reads it, extracts key information, and integrates it into existing pages. The knowledge compounds.

You never write the wiki yourself. The LLM writes and maintains all of it. You browse the results in Obsidian.

## Architecture

```
┌─────────────────────────────────────┐
│  Raw Sources (read-only)            │
│  articles, notes, agent data, etc.  │
├─────────────────────────────────────┤
│  Wiki (LLM-compiled)               │
│  entities, concepts, summaries,     │
│  comparisons, Q&A synthesis         │
├─────────────────────────────────────┤
│  Schema (co-evolved)                │
│  SCHEMA.md — rules for maintenance  │
└─────────────────────────────────────┘
         ↕ Obsidian (frontend)
```

**Two-agent model** (recommended for OpenClaw users):

| Agent | Role | What they do |
|-------|------|--------------|
| **Primary agent** | Data source | Has conversations with you, writes diaries/memories. Does NOT touch the wiki. |
| **Ops agent** | Wiki maintainer | Syncs data daily, ingests into wiki, runs weekly health checks. |

You only talk to your primary agent. Everything flows into the wiki automatically.

## Quick Start

### Install

```bash
# OpenClaw
openclaw skills install openwiki

# Or manually
git clone https://github.com/Sid-Qin/openwiki
cd openwiki && bash setup.sh ~/my-project/wiki
```

### Setup

```bash
# Initialize wiki in your project
bash setup.sh ./wiki

# Or let your agent do it
# Just say: "set up an OpenWiki for this project"
```

### Daily Workflow

**You do nothing.** The wiki maintains itself:

```
You talk to your agent (Discord, terminal, wherever)
    ↓ automatic
Agent writes diaries, memories, conversation logs
    ↓ daily cron
Ops agent syncs data → ingests into wiki → updates pages
    ↓ weekly cron
Ops agent runs health check → fixes issues → reports
    ↓ whenever you want
Browse in Obsidian or search with: qmd search "keyword"
```

**Adding external knowledge:**

```
You: "save this article to the wiki" + [link]
Agent: fetches content → saves to wiki/raw/articles/ → notifies ops agent
Ops agent: ingests → new wiki pages appear
```

## Directory Structure

```
wiki/
├── SCHEMA.md           — Rules (agents read this first)
├── index.md            — Master directory
├── log.md              — Operation log (append-only)
├── raw/                — Source materials (read-only)
│   ├── articles/       — Web clippings, papers
│   ├── agent-sync/     — Synced agent workspace data
│   └── assets/         — Images
├── entities/           — People, projects, services
├── concepts/           — Patterns, architectures, techniques
├── sources/            — One summary per raw source
├── comparisons/        — Side-by-side analyses
└── synthesis/          — Q&A outputs filed back
```

## Operations

### Ingest

New file in `raw/` → LLM reads it → creates source summary → updates entity/concept pages → refreshes index.

A single source might touch 10-15 wiki pages.

### Query

Ask your agent a question → it searches the wiki → synthesizes an answer → good answers get filed back to `synthesis/`, enriching the wiki for future queries.

### Lint

Weekly health check: find contradictions, orphan pages, stale data, missing cross-references. The LLM fixes simple issues automatically and reports complex ones.

## Search

[qmd](https://github.com/tobi/qmd) provides local search over the wiki:

```bash
qmd search "deployment pipeline" -n 5    # Keyword search
qmd get "wiki/concepts/caching.md"       # Full document
qmd update                                # Refresh index
```

Agents use `exec qmd search "query"` to search during conversations.

## OpenClaw Agent Sync

For OpenClaw users, a sync script pulls agent data into the wiki:

- **Workspace files**: MEMORY.md, status files, config
- **Diaries**: Recent daily journal entries
- **LCM conversations**: Compressed dialogue summaries from the Lossless Claw engine

The ops agent runs this daily, then auto-ingests any changes.

## Obsidian Setup

1. Open the parent directory as a vault
2. Settings → Files & Links → Attachment folder → `wiki/raw/assets`
3. Install plugins: **Dataview** (dynamic queries), **Marp** (slides)
4. Press ⌘G for the knowledge graph

## Why This Works

The tedious part of a knowledge base is bookkeeping — updating cross-references, keeping summaries current, noting contradictions. Humans abandon wikis because maintenance grows faster than value. LLMs don't get bored, don't forget to update a cross-reference, and can touch 15 files in one pass.

Human's job: curate sources, ask good questions, think about what it means.
LLM's job: everything else.

## License

MIT
