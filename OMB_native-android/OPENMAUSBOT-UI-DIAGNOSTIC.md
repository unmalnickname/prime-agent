# OpenMausBot UI — Diagnostic of user-facing bot controls, by screen and intention

Scope: milind-soni/OpenMausBot at main (cloned to /tmp/openmausbot). The UI is a React + Vite + Tailwind chat shell (src/, 305 .tsx files) talking to a local harness server over HTTP + one SSE stream. Three top-level views (chat, team-map, routines) plus side panels and modal layers, all driven by one reducer store (src/state/store.tsx).

## Screen registry (where things live)

| Layer | Screens |
|---|---|
| Main views (`AppState.activeView`) | Chat (per bot), Group Room, Routines calendar, Team Map canvas, Local VM workspace (full-window) |
| Full-window states | No engines (setup), Cloud engine sign-in, Cloud intent ("what should I do?"), onboarding welcome/tour |
| Side panels | Bot Settings, Computer Panel (or Remote Desktop when paired), Inspector (debug), Activity |
| Modals | App Settings, Apps/MCP (Plugins panel), Triggers/Webhooks, New Bot, Command Palette (⌘K), Keyboard Shortcuts, Team dialogs, voice Call overlay |

A global Simple ↔ Advanced mode switch (`useAdvancedMode`) gates roughly half the controls; noted per screen below.

---

## 1. Chat screen — steer a single bot

### Intention: send and steer work
- Composer with send button that relabels per context: send → steer (mid-turn queue injection) → queue (busy). Configurable send key (Enter / Shift+Enter / ⌘+Enter).
- Stop button (composer + header) interrupts the running turn; header Stop also covers "waiting for teammates".
- Queued-message chips above composer: Steer (inject into running turn, double-Enter = instant steer), Edit (return to draft), Trash (cancel); queue reasons shown (group-turn, capacity).
- @ mention picker (bots, everyone), / slash commands (/goal, /learn, /setup, skill commands), /goal chip toggles room chat↔goal mode.
- ArrowUp on empty composer edits your last message; edit branches switcher (n/m) per user message; Regenerate on last bot reply.

### Intention: respond to what the bot needs (inline decision cards)
- Approval card: Allow once / Always allow / Always allow this session / Always allow this command (→ command allowlist) / Deny / Cancel turn; "N of M" stacking; command detail dump.
- Question card: radio/checkbox options, free text, multi-tab questions, keyboard letters (a/b/c…) + arrow navigation, one-tap auto-submit.
- Secret request card: password input → "Save securely / Continue task"; value never enters chat.
- Sign-in request card: Open sign-in window / Save login / Done / Cancel.
- Widget cards: bot-rendered forms — buttons, fields, selects, date/time pickers, tables, charts, live status; validated submit with idempotent retry.
- Undo: applied approval cards carry Undo (POST /api/threads/:id/undo) with Details/Show.

### Intention: control what the bot may do (per-thread)
- Approval mode selector in the composer (ask / edits / auto / full / custom); auto-on-local requires an explicit warning confirm.
- Manage command allowlist dialog (trusted command + folder rules).
- Place chip pins the bot's working surface; Context warning pill with one-click Compact now; Conversation turn limit (default / 30 / 60 / 120 / custom min).

### Intention: manage message content
- Hover/long-press menu: Reply, Copy, Edit, Regenerate, Read aloud / Stop, Show raw markdown, Pin/Unpin, Copy message id. Pinned banner jumps to pinned message.
- Markdown extras: code block copy/download/wrap, Mermaid source, spoiler reveal, file "Save a copy"; text-selection toolbar creates citations; reply quotes jump to source; attachments gallery with preview, audio/video players, per-file save.

### Intention: monitor progress
- Tool-activity chips (running/failed/completed, expandable input/output), run groupings, turn narration, live presence with mascot animation, data-result chart/table chips, digest/compaction chips, screen-frame screenshots, routine-run and goal-run cards, webhook payload cards, call records.
- Verify card: per-step pass/fail list after a run, Save as skill.

### Intention: navigate and recover
- Find-in-conversation (⌘F, next/prev hits), jump-to-latest pill, new-messages divider, day separators, virtualized scroll with load-earlier.
- Header: bot name (click → Bot Settings, inline rename), model picker (thread or bot scope, effort levels), Computer button, ⋯ menu (Find, Export Markdown/Download, Usage, Activity, Inspector), task/thread picker, compact warning.
- Errors: chat error banner with raw detail, failed-turn rows with Retry (last turn only), cancelled-turn rows with Retry, failed-send banner (Retry/dismiss), safety-block and trial-credit guidance rows.

---

## 2. Bot Settings panel (side dialog, 14 sections) — configure one bot

### Intention: define who the bot is (Identity)
- Avatar: upload image, AI avatar generator, mascot shape/color/body/expression, zoom framing.
- Name (random-name buttons in draft), Title (job), Blurb + full instructions dialog, Team/section, Starting role (presets), SOUL standing-instructions editor with byte counter and file-drift resolution, org-package provenance line, Visibility (everyone/admins/specific people).

### Intention: choose the brain (Model)
- Default model picker (engine rail, effort/reasoning level, model variants, per-thread overrides shown), Backup models fallback chain (≤5), cache keep-warm, ChatGPT-plan status.

### Intention: control what the bot may do (Permissions / Access)
- Approval level selector (+ "apply Full to all threads"), Chief of Staff switch + managed-teams picker, "ask me before contacting other bots", Sending on your behalf (ask-every-time vs daily cap 1–1000).
- Works on destination (Auto / Local / Cloud, cloud backend Boat vs VPS, auto-start VPS), Working folder picker.
- Connected apps per-app scopes (Off / Read / Read&write) and per-tool grants (read/draft/send/modify/delete verbs); MCP servers toggles; Tool selection (allow/exclude lists, native:/mcp: syntax); built-in Browser switch + Record steps; webhooks status list; Always allowed standing approvals list.

### Intention: give the bot knowledge and behavior (Skills / Memory / Routines)
- Learned skills: import from repo/URL/library, review-then-enable (SKILL.md + sha256), toggle, delete; Write a skill authoring card; org skills.
- Memory: enable, MEMORY.md editor with conflict handling, topic files, daily logs, memory upkeep + "learn from rooms", "Tidy up now", capacity gauge, changes journal with per-row Undo.
- Routines: inline routine editor, enable toggles, logs, jump to schedule page.

### Intention: voice & alerts
- Voice engine (built-in Mac / ElevenLabs / Fish / Grok / Chatterbox), voice picker with preview, notifications switch.

### Intention: audit and spend (History / Usage / Overview)
- Change log with actor/via/summary and SOUL rollback; per-bot turns/tokens/cost; prompt preview per section; setup checklist that deep-links sections ("Set up with the bot" launches /setup to the bot itself).

### Simple mode (SimpleBotPanel)
Tabs Details / Memory / Library / Skills / Routines / Vault. Details exposes Look, Name+Job, Instructions, Default model, Thinking (friendly labels), "Before it acts" (Ask/Decide/Full), "Where it works" (Auto/Local/Cloud), Apps chips, routines preview, "All settings" escape hatch. Vault = app toggles + saved logins. Everything else hidden.

### Intention: manage bot lifecycle (sidebar + dialogs)
- New Bot dialog (⌘N): full wizard (identity → soul → skills → memory → routines → access → model → permissions → voice), visibility, local-computer auto warning; also "New bot defaults" and Share as preset.
- Bot right-click menu: New task / task folder / folder, Pin, Make/Remove Chief, Move to section, Mark unread/read, Edit profile, Duplicate, Copy conversation ID, Archive (with chief/last-bot guards), Delete (confirm).
- Archived bots panel: Restore / Delete per bot, Restore all / Delete all.

---

## 3. Computer Panel — give the bot a machine

### Intention: choose where the bot works
- Destination grid: Auto / Cloud / Local VM / This computer / Browser / Off (org-managed policies lock choices; task-pinned surfaces shown).
- Cloud lifecycle: prepare/start, sleep, replace VPS, backend picker (Boat vs self-hosted VPS); cloud plan purchase/trial dialogs; team-computer shelf on the Team Map (create, assign to team with shared-access acknowledge, cost acknowledge).
- Local VM lifecycle: start, create/replace/delete VM (confirm dialogs), "Two desktops" side-by-side workspace.
- Built-in browser: per-bot switch, Record steps, workspace-level opt-in, browser-engine installer (~160 MB, admin).

### Intention: watch the bot work
- Polled screenshot previews (cloud / local VM / native mac frames with permission recovery), Linux user-initiated screen-share preview, live browser frames over SSE, noVNC desktop viewer (fullscreen, keyboard panel incl. Ctrl+Alt+Del, clipboard-to-VM), dual-pane local VM workspace, chat-embedded screen frames.

### Intention: take over control
- Take control / Hand back lease ("You have the wheel") per computer surface and per browser; "Open live desktop" auto-takes the lease; per-pane control in the dual workspace; browser typing/paste input with secret-safe masked dialogs; sign-in help banner routing to the right surface.

### Intention: manage the browser and its logins
- Profiles manager (own / named / guest, ≤20, engine per profile: built-in vs "my Chrome"), tabs strip, address bar + nav, restart browser (keeps logins), Signed-in sites list with per-site / sign-out-all.

### Intention: manage files
- Working folder card (change → opens bot Access settings), recent changed files list with "shared / not shared" chips.

### Intention: stay safe
- Local + Auto-mode warning modal (must acknowledge unattended control), macOS Accessibility/Screen-Recording recovery cards, Linux Xorg opt-in / Wayland fail-closed gate, VM delete confirms, cost and shared-access acknowledgements, Cloud lending (share folders/screen with per-folder edit rights, live refused-action log).

Also on this panel: Routines tab (advanced), Android tab (USB mirroring), Data tab, Files tab (simple).

---

## 4. Routines & Automation screens — make bots run on their own

- Routines calendar page: Day/Week/List views, mini-month sidebar, draggable bot list ("drag a bot onto any time"), drag/resize events, quick-create dialog, full event editor (Routine vs Call; Bot task vs Team goal; start/duration; repeat none/interval/daily/weekdays/monthly/yearly/custom cron with next-run preview and timezone; stop-if-still-running timeout; overlap policy queue/skip; run-on-startup; continuity; results destination; run on Bot's setup vs Cloud; attachments).
- Run logs section: search, status filter (queued/running/waiting/completed/failed/missed/cancelled), unseen-failure badge + "Mark all seen", paused-routines dialog, per-routine cards with enable toggles and failure-streak notices.
- Webhooks / Triggers: create webhook (receiving bot, default instructions, run-on computer, accepted event types, max pending with 429 overflow), private URL generate/rotate/copy command, pause/enable, recent deliveries with "Open chat"; "When [source] … Should [instructions]" trigger form; keep-awake toggle for scheduled runs.

---

## 5. Rooms, Teams & the Team Map — orchestrate many bots

- Group room (GroupView): room transcript with all chat cards plus RoomToolChip, goal-run cards; room setup wizard (working folder, responder mode Auto/Everyone/Mentions, lead picker, shared instructions), editable bulletin, member manager (add/remove bots), per-room turn timeout, group usage chip (tokens/cost), group voice call (push-to-talk, spoken approvals).
- Team Map canvas: draggable bot/team nodes, Add menu (Team / Cloud computer / Local VM), computers toggle, bot↔bot edge list with running/queued/connected state, per-team shared instructions editor (Goals/Decisions/Preferences), team memory dialog (People/Places/Decisions/Terms with proposed/accepted status).
- Team management: create/rename teams, bulk Team Settings (approval mode + model/effort for the whole team with preview diff and Apply N), Chief of Staff role.
- Team library (TeamLibraryPanel): tabs Org packages (one-click add), Explore (search + GitHub URL import), Import (project folder scout), Share (Share team dialog — export bots, skills, routines, rooms, brief as one portable .md file with contents preview, secret redaction, include-pictures/notes toggles).

---

## 6. Activity, Monitoring & Debug

- Activity panel (per-bot, live): day-grouped tool/approval rows with outcome chips, click-to-jump, reload.
- Inspector panel (advanced): run timeline (RunLog, copy-log), raw runtime events stream, native protocol messages.
- Admin activity log (Settings → Account → Activity): who/what/from-to filters, before/after diffs, CSV export.
- Sidebar "Needs you" attention panel (unseen routine problems, held approvals), pinned threads panel, sidebar message search results.

---

## 7. Voice & Calls

- Call button per bot and per room: turns mode (half-duplex, push-to-talk, spoken yes/no approvals) and live mode; mode menu; hang up; call records in transcript.
- Live call bar: elapsed clock, heard-text captions, mute, hang up, settings (voice, read typed messages, idle timeout); cross-thread call pill with keyboard chords.
- Read aloud per message; voice notes with player; voice setup dialog with readiness check and "hear this voice" preview.

---

## 8. App Settings (modal, 4 groups: You / AI / Computers / Account)

- AI: 9 provider API keys + custom OpenAI-compatible URL (write-only secrets, "configured" flags), engine cards with install/sign-in/CLI-path probe, subscription accounts (Claude/Codex/ChatGPT plan), cache keep-warm, Decision model (Jev/OpenRouter room routing with latency test).
- You: profile + "About me" learned facts, language, analytics, send key, skin picker, font, sidebar density, notification sounds, tool-call/run-card toggles, Simple↔Advanced master switch, new-bot default effort, room-turn & MCP-call timeouts, thread concurrency, automatic recovery (backup engine/model), thread retention/cleanup, updates, diagnostics export (secret-free), tour replay, skill-review + experimental flags.
- Computers: companion/phone pairing (Tailscale / Wi-Fi / HTTPS, QR + app links), custom domain + DNS verification, server pairing, desktop workspaces & servers ("copy here", Computer access sharing: folders, unrestricted terminal, computer control), Logins vault (passwords, 2FA badges, TOTP, 1Password), built-in browser opt-in.
- Account: cloud account (trial, plan, move workspace to cloud), organization enrollment (managed models, license), people (invite, roles, domain-wide), workspaces fleet (create/suspend/delete, spend caps), usage (per-bot table, history with CSV export, monthly budget cap + warn %, custom price book), backups (passworded export/import, org daily snapshots), activity log.

---

## 9. Shell, navigation & onboarding

- Sidebar: bot/room list with context menus (pin, snooze, archive, mark unread, delete chat/channel, new channel), sections/collapse, new-chat picker (create bot/group), footer Tools nav (Routines, Triggers, Apps, Team map — advanced-only), profile menu (phone, support, shortcuts, about, settings).
- Power user: ⌘K command palette (bots/rooms/messages), ⌘N new chat, ⌘F find, ⌘1–9 and Shift+[ ] bot cycling, searchable Keyboard Shortcuts modal grouped Navigation / Chat & Composer / Calls / Management & Groups.
- Onboarding: welcome beats (profile → feature reel → engine setup → mic permission → phone pairing → personalize first bot), then a 10-step guided tour (composer, model, computer, browser tabs, tools, apps marketplace, automations, calendar drag-schedule), then first-conversation spotlights (approval card, connector sign-in, ⌘K, model chip). Replayable from Settings.
- Global notices: update banner, cloud trial/intro cards, GitHub-star notice; paired-remote mode swaps in a simplified Remote Desktop panel and Remote Agent Settings (profile only).

---

## Diagnostic observations

1. Controls map cleanly to five user intentions: steer work (chat/computer), authorize work (cards + approval levels), equip the bot (settings: brain, tools, memory, voice), schedule work (routines/webhooks), coordinate many bots (rooms/teams/map). Each intention has at least two surfaces (a quick inline control and a settings destination), with deep links between them (e.g. context warning → compact; computer card → Access settings).
2. Simple vs Advanced gating is the main discoverability axis: in Simple mode the user loses MCP, tool scoping, fallback chains, chief-of-staff, outbound caps, history/usage, routines/team map nav — exactly the controls most tied to "governance". Everything remains reachable via "All settings", but the two-tier split is inconsistently labeled across surfaces (sidebar Tools block hidden entirely in Simple unless icons-only density).
3. Safety posture is consistent and explicit: unattended local control always requires an acknowledged warning; secrets never echo back to the UI or chat; destructive actions (VM delete, archive, team delete) confirm; cost/shared-access changes acknowledge. The strongest pattern is the control-lease model ("Take control / Hand back") applied uniformly to desktops, VMs, and browsers.
4. Coverage gaps worth noting: phone/remote pairs get a reduced feature set (no inspector/activity, profile-only bot settings) with no in-UI capability matrix explaining what's missing; several settings rows are hardcoded English instead of i18n keys (ComputerSharing, ConnectedWorkspaces, Voice settings), so localization will silently skip them; routine/webhook management is split across three entry points (bot settings, calendar page, triggers dialog) with overlapping editors.

All source paths cited above are under /tmp/openmausbot/src/ (components, state, lib) if you want to drill into any specific screen.
