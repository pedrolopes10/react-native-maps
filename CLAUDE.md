# CLAUDE.md

## Claude Memory (shared, in-repo)

Persistent project memory for Claude sessions lives in `.claude/memory/` in this repo — shared across machines and teammates via git. This **replaces the per-user memory directory for project knowledge**.

@.claude/memory/MEMORY.md

- At session start, the index above is auto-imported; read any memory file relevant to the current task before relying on it (memories are point-in-time notes, not live state).
- Save durable **project/reference** knowledge as new files in `.claude/memory/` (same one-fact-per-file format with frontmatter) and add a one-line entry to `.claude/memory/MEMORY.md`. Do NOT write project knowledge to the per-user memory directory.
- **Proactively save** to `.claude/memory/` when a session uncovers something durable and expensive to rediscover: a root cause, an invariant, a non-obvious constraint ("X looks unused but isn't"), or a decision and its why. Do this without being asked.
- **Don't save** anything derivable from the code, git history, or CLAUDE.md, or that only matters to the current conversation. Prefer updating an existing memory over creating a near-duplicate; delete memories proven wrong.
- Before the session ends, remind the user if new/changed memory files are uncommitted.
- Personal memories (user preferences, personal feedback) stay in the per-user memory directory as usual — never in the repo.
- Memory files are regular repo files: commit them together with the related source change — no separate `memory:` commit needed.

**One-time migration:** if the auto-loaded _user-directory_ memory index for this project still contains project-type memories not present in `.claude/memory/`, tell the user and offer to migrate them: skip personal (user/feedback) entries and anything already covered here, move the rest into `.claude/memory/`, update its index, then delete the migrated files from the user directory and leave a pointer note in the user-dir MEMORY.md.
