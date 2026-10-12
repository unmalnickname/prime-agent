# Child salvage: the no-reply terminal notice carries what the child was doing

Status: proposed for upstream (feature branch `feat/rlm-child-salvage`).
Scope: `pa-daemon` (rlm_children), `pa-core` (rlm_notices). No wire-command,
kernel-API, or surface-contract change.

## Problem

An RLM child that dies without sending an agent message delivers one row to
its parent:

    [child-exited: no-reply child:<name>]

The parent learns the child is gone and nothing else. The child's work is not
lost — its durable session transcript is on disk — but recovering it means
manually digging through `~/.prime/agent/sessions/*.jsonl`. In the incident
that motivated this change (2026-10-12), a research subagent died mid-task to
a provider 402 with 135 KB of useful transcript and zero delivered output;
the salvage was done by hand.

For a product built for long-running, fan-out work this is the worst failure
mode: the compute is spent, the findings exist, and the parent sees a one-line
obituary.

## Design

When the settle watcher delivers the `CompletedWithoutReply` notice, it now
extracts a **deterministic salvage digest** from the child's session
transcript and appends it to the notice body:

    [child-exited: no-reply child:f20-worker]

    Salvage: last tool calls: bash(ls crates); last partial text: "checking the workspace layout"

The digest also lands in the notice `details` under `salvageSummary`
(additive; the TS-shaped keys are unchanged).

Extraction rules (`crates/pa-daemon/src/rlm_children/salvage.rs`):

- reads the transcript tail (`SALVAGE_TAIL_BYTES`, 256 KiB) of the child's
  `sessionFile`; the lenient JSONL parser skips a cut first line and any torn
  trailing row (TS loader discipline);
- keeps the last `SALVAGE_TOOL_CALLS` (4) assistant tool calls in order,
  rendered `name(preview)` with a collapsed, `SALVAGE_CALL_MAX_CHARS` (80)
  capped argument preview (familiar argument first: `command`, `code`, `path`,
  `file_path`, `pattern`); both the `toolCall`/`arguments` and the legacy
  `tool_call`/`args` spellings are recognized;
- keeps the last non-empty assistant text block, collapsed and
  `SALVAGE_TEXT_MAX_CHARS` (240) capped;
- caps the whole digest at `SALVAGE_DIGEST_MAX_CHARS` (640);
- `None` when the file is missing/unreadable or holds nothing digestable: the
  notice is delivered unchanged. Salvage is strictly best-effort; it can never
  swallow or delay a notice.

Why extractive (no model call): the failure paths that kill a child include
dead providers. A summarizer call on that path would die with them. The
digest is computed offline from rows the child already persisted, on the
blocking pool (the usage walk's file-read discipline), outside the record
lock; the exactly-once notice claim is taken before extraction, so the race
semantics (`replied_since_task`, `notice_delivered`) are untouched.

## Requeue (the second half of the feature)

Automation is deliberately absent: a re-run repeats side effects (commands,
edits), so the parent decides. The digest plus the stored prompt make manual
requeue one call, and `agent_observe.recent_messages` / the child's
`session_dir` give access to the full transcript:

    handle = await rlm.spawn(original_prompt, name="...")   # requeue

A kernel-side `handle.requeue()` sugar would be a surface-contract addition;
it is listed under Follow-ups for the owners to rule on.

## Parity

TS-identical (unchanged):

- notice custom type `rlm_child_terminal_notice`, row shape, `details.kind`
  (`completed_without_reply`), `childId`, `sessionName`,
  `lastAssistantTextPreview` rendering;
- the `[child-exited: no-reply child:<name>]` header line;
- withholding semantics (a child that replied since its task never gets the
  notice), the exactly-once claim, cancel/failure notice behavior.

Intentional divergence (needs a sanctioned-divergence ruling before merge,
per AGENTS.md parity-diff policy):

- the notice body gains a `Salvage: ...` segment when a digest exists;
- `details` gains the additive `salvageSummary` key.

If the ruling is denied, the same digest can ride a sibling custom row with a
new custom type instead of the notice body (plumbing already delivers
terminal notices; a second row is a small change). The TS port of the feature
is the alternative to a ruling.

## Tests

- `pa-daemon::rlm_children::salvage::tests::*` (8): digest extraction,
  ordering, legacy block spellings, torn/foreign rows, caps, missing file,
  bounded tail read dropping a cut row.
- `pa-daemon::rlm_children::watch_tests::
  a_settled_child_without_a_reply_delivers_the_terminal_notice`: end-to-end
  regression through the fake supervisor; the child's session file is seeded
  with digestable rows at `create` and the delivered notice must carry the
  exact digest in `content` and `details.salvageSummary`. Fails without the
  feature.
- `pa-core::session_engine::rlm_notices::tests::*`: TS-shape tests unchanged;
  new test pins the salvage body segment and details key.

The `pa-daemon` lib suite shows 33 pre-existing failures in this macOS
sandbox (identical set on a clean checkout; supervisor/herdr/roster tests
that expect a Linux-ish environment); everything in the touched modules
passes.

## Adoption telemetry (required companion, not in this change)

The repo rule ships a feature's adoption event in the same PR; this change
intentionally leaves the shared telemetry schema to the owners (schema joins
are architectural). Proposed companion:

- vocabulary: add `"child_salvage"` to `FEATURE_NAMES`
  (`crates/pa-telemetry/src/catalog.rs`) so `feature_outcome_key` accepts it;
- emit: `note_feature_outcome("child_salvage", "completed", Some("salvaged"))`
  when a digest lands, `("child_salvage", "unavailable", ...)` when the
  extraction yields `None` — on the parent worker's notice-injection seam
  (`SessionCounters` is reachable from the session engine there), or
  `ModelRefusalTelemetry`-style fire-and-forget from the supervisor if the
  owners prefer a daemon-side event;
- primitives only (counts); never transcript content.

## Follow-ups (owners' call)

1. The telemetry companion above (required by policy once ruled).
2. Sanctioned-divergence ruling (or TS-side port) for the notice body.
3. Model-based summaries via `auxiliary_model` as an *enrichment* pass on the
   digest — never on the delivery path.
4. Salvage for `Cancelled` notices (deleted children may also carry work).
5. Kernel `handle.requeue()` sugar (surface-contract addition).
