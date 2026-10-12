//! Deterministic salvage digests for children that die without replying: the
//! no-reply terminal notice carries what the child was last doing, extracted
//! from its durable session transcript. Extractive and offline on purpose —
//! the failure paths that kill a child (a dead provider among them) must not
//! depend on another model call, so the digest is computed from the rows the
//! child already persisted.
//!
//! Non-goals: model-based summaries, cancelled-notice salvage, and requeue
//! automation (the parent requeues by re-spawning with the prompt the digest
//! points at).

use std::fs;
use std::io::{Read, Seek, SeekFrom};
use std::path::Path;

use serde_json::Value;

use crate::rlm_child_model::cap_text;
use crate::session_store::parse_session_entries;

/// Transcript tail read for the digest: many turns of material while a huge
/// child transcript never stalls the settle path.
const SALVAGE_TAIL_BYTES: u64 = 256 * 1024;
/// Tool calls kept in the digest, the most recent ones, in order.
const SALVAGE_TOOL_CALLS: usize = 4;
/// One tool-call argument preview's cap.
const SALVAGE_CALL_MAX_CHARS: usize = 80;
/// The last assistant text's cap.
const SALVAGE_TEXT_MAX_CHARS: usize = 240;
/// The whole digest's cap; the text half loses first.
const SALVAGE_DIGEST_MAX_CHARS: usize = 640;

/// Extract the digest from a child's durable session file. `None` when the
/// file is missing, unreadable, or holds nothing digestable — the caller
/// delivers the notice regardless; salvage is strictly best-effort.
pub(super) fn salvage_digest_from_session_file(path: &Path) -> Option<String> {
    let tail = read_tail(path, SALVAGE_TAIL_BYTES)?;
    // A tail cut mid-file starts on a partial row; the parser's lenient
    // skip (TS loader discipline) drops it along with any torn last line.
    let rows = parse_session_entries(&tail);
    salvage_digest(&rows)
}

/// The digest from parsed session rows: the last tool calls and the last
/// assistant text, one bounded line. `None` when the rows carry neither.
pub(super) fn salvage_digest(rows: &[Value]) -> Option<String> {
    let mut tool_calls: Vec<String> = Vec::new();
    let mut last_text: Option<String> = None;
    for row in rows {
        if row.get("type").and_then(Value::as_str) != Some("message") {
            continue;
        }
        let Some(message) = row.get("message") else {
            continue;
        };
        if message.get("role").and_then(Value::as_str) != Some("assistant") {
            continue;
        }
        let Some(blocks) = message.get("content").and_then(Value::as_array) else {
            continue;
        };
        for block in blocks {
            match block.get("type").and_then(Value::as_str) {
                Some("text") => {
                    if let Some(text) = block.get("text").and_then(Value::as_str) {
                        let compact = collapse(text);
                        if !compact.is_empty() {
                            last_text = Some(compact);
                        }
                    }
                }
                // The legacy `tool_call`/`args` spelling appears in
                // corrupted-tail fixtures; both spellings are digested.
                Some("toolCall" | "tool_call") => {
                    if let Some(preview) = tool_call_preview(block) {
                        tool_calls.push(preview);
                    }
                }
                _ => {}
            }
        }
    }
    let first_call = tool_calls.len().saturating_sub(SALVAGE_TOOL_CALLS);
    let calls = &tool_calls[first_call..];
    let mut parts: Vec<String> = Vec::new();
    if !calls.is_empty() {
        parts.push(format!("last tool calls: {}", calls.join(", ")));
    }
    if let Some(text) = last_text {
        parts.push(format!(
            "last partial text: \"{}\"",
            cap_text(&text, SALVAGE_TEXT_MAX_CHARS)
        ));
    }
    if parts.is_empty() {
        return None;
    }
    Some(cap_text(&parts.join("; "), SALVAGE_DIGEST_MAX_CHARS))
}

/// One `name(preview)` entry: the call name plus a collapsed, capped
/// argument preview (the familiar argument first: command, code, path).
fn tool_call_preview(block: &Value) -> Option<String> {
    let name = block
        .get("name")
        .and_then(Value::as_str)
        .filter(|name| !name.is_empty())
        .unwrap_or("tool");
    let args = block
        .get("arguments")
        .or_else(|| block.get("args"))
        .and_then(Value::as_object);
    let preview = args.and_then(|args| {
        ["command", "code", "path", "file_path", "pattern"]
            .iter()
            .find_map(|key| args.get(*key).and_then(Value::as_str).map(collapse))
            .or_else(|| args.values().find_map(|value| value.as_str().map(collapse)))
    });
    let preview = cap_text(preview.as_deref().unwrap_or(""), SALVAGE_CALL_MAX_CHARS);
    Some(format!("{name}({preview})"))
}

/// Whitespace-collapse a text fragment so the digest stays one line.
fn collapse(text: &str) -> String {
    text.split_whitespace().collect::<Vec<_>>().join(" ")
}

/// The last `max_bytes` of the file as lossy UTF-8. `None` when the file
/// cannot be read at all.
fn read_tail(path: &Path, max_bytes: u64) -> Option<String> {
    let mut file = fs::File::open(path).ok()?;
    let len = file.metadata().ok()?.len();
    let start = len.saturating_sub(max_bytes);
    file.seek(SeekFrom::Start(start)).ok()?;
    let mut buffer: Vec<u8> = Vec::new();
    Read::take(&mut file, max_bytes)
        .read_to_end(&mut buffer)
        .ok()?;
    Some(String::from_utf8_lossy(&buffer).into_owned())
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    fn row(content: &Value) -> Value {
        json!({"type": "message", "id": "m", "timestamp": "t", "message": {
            "role": "assistant", "content": content,
        }})
    }

    #[test]
    fn digest_reports_the_last_tool_calls_and_text() {
        let rows = vec![
            row(&json!([
                {"type": "toolCall", "name": "bash", "arguments": {"command": "ls  crates"}}
            ])),
            row(&json!([{"type": "text", "text": "checking the workspace layout"}])),
        ];
        assert_eq!(
            salvage_digest(&rows),
            Some(
                "last tool calls: bash(ls crates); last partial text: \"checking the workspace layout\""
                    .to_string()
            )
        );
    }

    #[test]
    fn digest_keeps_the_last_calls_in_order() {
        let rows: Vec<Value> = (0..6)
            .map(|i| row(&json!([{"type": "toolCall", "name": "bash", "arguments": {"command": format!("cmd-{i}")}}])))
            .collect();
        assert_eq!(
            salvage_digest(&rows),
            Some("last tool calls: bash(cmd-2), bash(cmd-3), bash(cmd-4), bash(cmd-5)".to_string())
        );
    }

    #[test]
    fn digest_prefers_the_last_text_block() {
        let rows = vec![row(&json!([
            {"type": "text", "text": "first thought"},
            {"type": "text", "text": "final words"},
        ]))];
        assert_eq!(
            salvage_digest(&rows),
            Some("last partial text: \"final words\"".to_string())
        );
    }

    #[test]
    fn digest_tolerates_torn_and_foreign_rows() {
        let rows = vec![
            json!({"type": "custom_message", "content": "noise"}),
            row(&json!([{"type": "text", "text": null}])),
            row(&json!([{"type": "text"}])),
            row(&json!([{"type": "tool_call", "name": "edit", "args": {"path": "src/lib.rs"}}])),
        ];
        assert_eq!(
            salvage_digest(&rows),
            Some("last tool calls: edit(src/lib.rs)".to_string())
        );
    }

    #[test]
    fn digest_caps_long_text() {
        let long = "x".repeat(1_000);
        let rows = vec![row(&json!([{"type": "text", "text": long}]))];
        let digest = salvage_digest(&rows).expect("digest");
        assert!(digest.ends_with("...\""));
        assert!(digest.len() < 300);
    }

    #[test]
    fn no_material_yields_none() {
        assert_eq!(salvage_digest(&[]), None);
        assert_eq!(
            salvage_digest(&[row(&json!([{"type": "thinking", "thinking": "x"}]))]),
            None
        );
    }

    #[test]
    fn missing_session_file_yields_none() {
        assert_eq!(
            salvage_digest_from_session_file(Path::new("/nonexistent/child.jsonl")),
            None
        );
    }

    #[test]
    fn session_file_digest_reads_rows_and_skips_a_cut_first_line() {
        let dir = tempfile::tempdir().expect("tempdir");
        let path = dir.path().join("child.jsonl");
        let row_json = |id: &str, text: &str| {
            json!({"type": "message", "id": id, "timestamp": "t", "message": {
                "role": "assistant", "content": [{"type": "text", "text": text}],
            }})
        };
        let first = row_json("a", &"filler ".repeat(80));
        let second = row_json("b", "the part that survives");
        std::fs::write(&path, format!("{first}\n{second}\n")).expect("write rows");
        // Whole-file read: both rows digest, the last text wins.
        assert_eq!(
            salvage_digest_from_session_file(&path),
            Some("last partial text: \"the part that survives\"".to_string())
        );
        // A bounded tail read cuts inside the filler row; the lenient
        // parser drops the cut row and the digest stays the second row.
        let tail = read_tail(&path, 300).expect("tail");
        let rows = parse_session_entries(&tail);
        assert_eq!(
            salvage_digest(&rows),
            Some("last partial text: \"the part that survives\"".to_string())
        );
    }
}
