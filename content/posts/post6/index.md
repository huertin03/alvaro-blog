---
date: '2026-06-03T19:00:00+02:00'
draft: false
title: "Claude, How's My Money?"
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.png"
- name: "featured-image-preview"
  src: "featured-image-preview.png"

tags: ["B.E.L.E.N", "Go", "TUI", "Self-hosting", "Actual Budget", "Claude", "OpenID"]
---


My BELEN cluster already runs [Actual Budget](https://actualbudget.org/) — a slick, local-first, self-hosted budgeting app. It's lovely in the browser. But I live in the terminal, and lately I've been pair-building everything with Claude Code. So I had an itch: I wanted to *talk* to my budget from a TUI and — more interestingly — I wanted **Claude** to be able to read it and actually reason about my money. This is the story of [`actual-tui`](https://github.com/B-E-L-E-N-Cluster/actual-tui), and of one very satisfying pivot.

### The wall: no API, and a stubborn rule

Two problems showed up immediately.

First, **Actual has no REST API.** It ships a Node.js SDK that downloads a local copy of your budget and syncs it — powerful, but not something a Go program can just `curl`.

Second, my own non-negotiable: **I log into BELEN's Actual with Google (OpenID), and I refused to add a password just for tooling.** Every existing community tool authenticates with a server password. On a password-less, OpenID-enforced server like mine, they're dead on arrival.

So the easy path was blocked. Good — those are the fun ones.

### The breakthrough: logging in like the web app, no password

Here's the thing the web client does that the tools didn't: it never asks *me* for a password — it bounces me through Google and gets a **session token** back. Could a CLI do the same?

Turns out, yes. When you start an OpenID login, Actual's server lets you pass a `returnUrl` — and it explicitly allows `localhost`. That's the exact pattern `gh auth login` uses. So `actual-tui login`:

1. spins up a tiny loopback server on `http://localhost:PORT`,
2. asks the server to start the OpenID flow with that return URL,
3. opens the browser → I log in with Google,
4. the server redirects back to `localhost` with the session token in the URL,
5. the token lands safely in my OS keyring.

No password. Works against *any* Actual server, no matter how it's configured. The first time it printed `LoggedIn: true` against the real BELEN server, I may have done a small chair-dance.

### The strategic pivot (a BELEN tradition)

If you've read my earlier posts, you know BELEN runs on the *art of the strategic pivot*. This one was a beauty.

I had started building my own bridge — a little Node service wrapping the SDK — and I was knee-deep in fiddly internals. Then, mid-build, I found it: **`@actual-app/cli`**, an *official* command-line interface for Actual, with full coverage and JSON output. The kicker: it accepts a session token directly via `ACTUAL_SESSION_TOKEN`.

So I threw my custom bridge away. The OpenID token I'd fought so hard to capture? It dropped straight into the official CLI and *just worked* — accounts, transactions, budgets, all as clean JSON. Less code, more robust, officially supported. Killing your own darling code in favour of a better tool is, every single time, the right call.

### The result: [actual-tui](https://github.com/B-E-L-E-N-Cluster/actual-tui)

What I ended up with is small and focused:

- **`actual-tui login` / `whoami` / `logout`** — the OpenID session manager.
- A **full-screen, [k9s](https://k9scli.io/)-style TUI** (built with `tview`) to browse accounts, transactions and budgets — and edit a few things: reconcile, re-categorize, set a budget amount.
- **`actual-tui exec -- …`** — the bridge: it injects my keyring token into the official CLI so anything (a script, or an AI agent) can use it *without ever touching the token*.

```text
$ actual-tui login --server https://actualbudget.mydomain
  → browser → Google → LoggedIn ✓   (no password)
$ actual-tui                      # the k9s-style TUI
$ actual-tui exec accounts list   # official CLI, authenticated, JSON out
```

**It's open-source.** `actual-tui` lives at **[github.com/B-E-L-E-N-Cluster/actual-tui](https://github.com/B-E-L-E-N-Cluster/actual-tui)** — install it with one line:

```sh
curl -fsSL https://raw.githubusercontent.com/B-E-L-E-N-Cluster/actual-tui/main/install.sh | sh
```

(plus `npm i -g @actual-app/cli` for the data layer.)

### The real magic: Claude as a financial advisor

That `exec` bridge is the whole point. I wrote a small **Claude skill** that teaches Claude how to drive the CLI: list accounts, resolve category and payee IDs to names, read a budget month, and the gotchas (amounts are in cents, transactions need a date range, off-budget accounts aren't spending).

The result still surprises me. I can ask, in plain language, *"how am I doing this month?"* or *"where am I overspending?"* — and Claude pulls my **live** numbers and answers with real figures and concrete advice. I'm currently weighing a big purchase with a multi-year payment plan, and Claude read my actual cash position and monthly flow and told me — bluntly, with numbers — exactly how tight it would be and where to cut. That's not a generic chatbot tip. It's advice grounded in my own data, that never leaves my machine.

### Reflection

The whole thing was built with Claude Code as a pair: it dispatched sub-agents, hit real bugs against the live server (a required flag here, an ID-to-name mapping there), and we fixed them together. The pattern that keeps working in BELEN holds again — have a stubborn principle (OpenID, no password), be willing to pivot hard when a better tool appears (the official CLI), and keep the surface area small.

Next up: turning that financial-advisor skill from *"answer my questions"* into *"watch my budget and warn me."* But that's another post.
