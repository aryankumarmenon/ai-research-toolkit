# Web Automation Tiers

How to make an agent *do things on the internet* — and which of the three tiers
to reach for. Distilled from Nick Saraev's "Claude Code Advanced Full Course
(3hr)." The whole thing is one trade-off axis:

> **More setup ↔ more generality.** Cheaper/faster the more you've invested in
> reverse-engineering the target; slower/pricier the more you let the agent
> drive a real UI blindly.

| Tier | What it manipulates | Setup | Speed / cost | Generality |
|---|---|---|---|---|
| **1. HTTP requests** | APIs / hidden endpoints (curl-level) | High — must find the schema | Fastest, cheapest | Narrow, fragile |
| **2. Browser automation** | JavaScript, clicks, form fields | Low | Medium (≈1 action/few sec) | Wide |
| **3. Computer use** | The actual mouse + keyboard | None | Slowest, most tokens | Works on *anything* |

---

## Tier 1 — HTTP requests

The agent sends GET/POST directly (Claude Code does this natively via WebFetch).
Great for **scraping** ("retrieve the text of these 400 URLs") and for hitting
a known API. Once you know a service's request format, a booking or lookup is
~0.2s and nearly free.

The catch: you have to *know the format*, it's brittle (one schema change
breaks it), and many sites actively block raw requests. Watching an agent
reverse-engineer an unknown booking API live is slow and error-prone — that's
the signal you've hit this tier's ceiling.

## Tier 2 — Browser automation

The agent drives a real browser — loads the page, clicks, fills fields. Obvious
how to use, works for a wide variety of tasks without bespoke setup. Two tools
worth knowing (as of the video):

- **Chrome DevTools MCP** — the default pick. Opens a real Chrome instance,
  manipulates page JS, screenshots each step. Use this first.
- **browser-use** (paid, bulk + pay-as-you-go) — the escalation when Chrome
  DevTools MCP gets *blocked*. Its whole value is being **undetectable**: it
  fingerprints each AI-driven browser to look like a real person. Reach for it
  for stealth-sensitive targets (social media posting, DMs, scraping sites that
  fight automation).

## Tier 3 — Computer use

Controls the literal mouse and keyboard via the Claude desktop app, taking a
screenshot after each move. Because it does exactly what a human can, it works
on *anything* — but it's very slow and token-hungry (every move = a screenshot
at high fidelity). Put it on a loop with "keep going until solved" and it will
get there; it'll just burn tokens doing it. Good for one-off local-machine
chores (rename that file in Downloads) and for genuinely UI-only tasks with no
API or page-JS path.

---

## The pragmatic play (prototype high, harden low)

The move Saraev uses on real client systems:

1. **Prototype with Tier 2** (Chrome DevTools MCP, → browser-use if blocked).
   It almost always works, so you confirm the task is doable fast.
2. **Capture the network traffic** while it runs — Chrome DevTools MCP exposes
   the real requests being sent/received. That *is* the hidden API.
3. **Harden down to Tier 1.** Have the agent write a custom HTTP utility + docs
   from those captured requests, embed it in the workspace, and run cheap
   high-volume HTTP requests thereafter.

Start at the tier that *always works*, drop to the tier that's *cheapest* once
you've learned the target. Generality first, efficiency once it's proven.

**Caveats worth a standing rule:**
- HTTP volume invites rate-limiting, throttling, and shadow-bans — the very
  thing browser automation sidesteps. The cheap tier carries the most platform
  risk.
- Automating many platforms violates their ToS. Know what you're doing and on
  whose behalf; this guide is about *capability*, not a recommendation to break
  terms.
- If browser/computer-use MCP tools fail twice, stop and ask — don't burn
  tokens retrying a failing browser call (a good CLAUDE.md rule in its own
  right).
