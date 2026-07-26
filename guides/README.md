# guides/

How-to references for the *mechanics*. Where [`workflows/`](../workflows/) give
you the route, guides explain each mechanism in isolation so you can compose your
own.

| Guide | Answers |
|---|---|
| [claude-code-tools.md](claude-code-tools.md) | What every Claude Code tool does, when to reach for it, and worked scenarios |
| [skills-commands-agents-hooks.md](skills-commands-agents-hooks.md) | Which extension mechanism to use — and how each is wired |
| [writing-skills.md](writing-skills.md) | How to author a skill that's predictable (Pocock's `writing-great-skills`, distilled) |
| [context-and-subagents.md](context-and-subagents.md) | Managing the context window; when/how to use subagents; skills-vs-MCP token economics |
| [web-automation-tiers.md](web-automation-tiers.md) | The three tiers of internet automation (HTTP → browser → computer use), which to pick, and the prototype-high/harden-low play |

These distill the vendored reference repos so you don't re-read them each time.
Open the originals ([references/](../references/)) only for a worked sample of a
mechanism a guide points at; the authoritative skill-authoring source is now
Anthropic's own spec (see the pointer at the top of
[writing-skills.md](writing-skills.md)).
