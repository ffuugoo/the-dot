---
name: github
description: >-
  Use for official GitHub documentation and basic gh CLI operations
---

# GitHub 🐙

## Documentation

For official GitHub documentation use [`Docs`](../docs/SKILL.md) skill.

## GitHub CLI

<!-- TODO: Manage GitHub issues, PRs and CI with `gh` CLI -->

## Agent Skills

`gh skill` finds, installs, and updates agent skills from GitHub repositories.

Discover skills with:

```zsh
gh skill search <query>
gh skill preview <owner>/<repo> <skill>
```

Manage skills with:

```zsh
gh skill install --dir ~/.agents/skills <owner>/<repo> <skill>
gh skill update --dir ~/.agents/skills --all
gh skill list --dir ~/.agents/skills
```

Skills live in the shared `~/.agents/skills` directory, which every agent reads.
Always pass `--dir ~/.agents/skills`, otherwise `gh skill` installs a separate copy per agent.

To uninstall a skill, remove its directory:

```zsh
rm -r ~/.agents/skills/<skill>
```
