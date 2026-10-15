import 'package:flutter/foundation.dart';

import 'mock_data.dart';

enum ViewKind {
  chat,
  botSettings,
  computer,
  routines,
  teamMap,
  activity,
  uiKit,
  newBot,
  voiceCall,
  usage,
  groupRoom,
  calendarGrid,
  inspector,
  appsMarket,
  onboarding,
  setupStates,
  themeStudio,
}

enum MsgKind {
  text,
  tool,
  approval,
  question,
  secret,
  widgetCard,
  verify,
  screenshot,
  error,
  system,
}

enum ToolState { running, done, failed }

class Workspace {
  final String id;
  final String name;
  final String emoji;
  final int unread;

  const Workspace({
    required this.id,
    required this.name,
    required this.emoji,
    this.unread = 0,
  });
}

class Session {
  final String id;
  final String workspaceId;
  final String name;
  final String emoji;
  final bool isRoom;
  final String status;
  final int unread;
  final bool pinned;
  final String section;

  const Session({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.emoji,
    this.isRoom = false,
    this.status = 'idle',
    this.unread = 0,
    this.pinned = false,
    this.section = 'BOTS',
  });
}

class VerifyStep {
  final String label;
  final bool pass;

  const VerifyStep(this.label, this.pass);
}

class ChatMsg {
  final String id;
  final MsgKind kind;
  final String author;
  final bool isUser;
  final String time;
  final String text;
  final String? toolName;
  final ToolState toolState;
  final String? detail;
  final List<String> options;
  final String? command;
  final String? stackLabel;
  final bool undoable;
  final List<VerifyStep> verifySteps;
  final String? code;
  final String? caption;

  const ChatMsg({
    this.id = '',
    this.kind = MsgKind.text,
    this.author = 'Maus',
    this.isUser = false,
    this.time = '',
    this.text = '',
    this.toolName,
    this.toolState = ToolState.done,
    this.detail,
    this.options = const [],
    this.command,
    this.stackLabel,
    this.undoable = false,
    this.verifySteps = const [],
    this.code,
    this.caption,
  });
}

/// The reply a decision card produces when the user acts on it.
enum CardReply { allowed, denied, answered, saved, submitted, undone, error }

/// Single source of truth for the mockup shell. Plain ChangeNotifier state,
/// but the chat is live: you can send/steer messages and resolve decision
/// cards, and the mock threads react.
class AppState extends ChangeNotifier {
  AppState() {
    sessionId = sessions.first.id;
  }

  final List<Workspace> workspaces = mockWorkspaces;
  final List<Session> sessions = mockSessions;
  final Map<String, List<ChatMsg>> threads = {
    for (final entry in mockThreads.entries) entry.key: [...entry.value],
  };

  int workspaceIndex = 0;
  String sessionId = '';
  ViewKind view = ViewKind.chat;
  bool advancedMode = true;
  bool drawerOpen = false;
  bool controlLease = false;
  String approvalMode = 'ask';
  bool running = true;
  final List<String> queue = [];

  /// Edit-branch navigation, per user message id.
  final Map<String, int> branchIndex = {};
  final Map<String, int> branchCount = {'u1': 2};

  Workspace get workspace => workspaces[workspaceIndex];

  Session get session => sessions.firstWhere((s) => s.id == sessionId);

  List<ChatMsg> get thread => threads[sessionId] ?? const [];

  List<Session> get workspaceSessions => sessions
      .where((s) => s.workspaceId == workspace.id)
      .toList(growable: false);

  List<Session> get pinnedSessions =>
      workspaceSessions.where((s) => s.pinned).toList(growable: false);

  List<Session> botSessions(bool room) =>
      workspaceSessions.where((s) => s.isRoom == room).toList(growable: false);

  int unreadFor(String workspaceId) => sessions
      .where((s) => s.workspaceId == workspaceId)
      .fold(0, (sum, s) => sum + s.unread);

  /// Discord behavior: switching workspaces keeps the drawer open so the
  /// user can pick a session next; only selecting a session closes it.
  void selectWorkspace(int index) {
    workspaceIndex = index;
    final first = sessions.firstWhere(
      (s) => s.workspaceId == workspaces[index].id,
      orElse: () => sessions.first,
    );
    sessionId = first.id;
    view = ViewKind.chat;
    notifyListeners();
  }

  void selectSession(String id) {
    sessionId = id;
    view = ViewKind.chat;
    drawerOpen = false;
    notifyListeners();
  }

  void openView(ViewKind kind) {
    view = kind;
    drawerOpen = false;
    notifyListeners();
  }

  void setDrawer(bool open) {
    drawerOpen = open;
    notifyListeners();
  }

  void toggleAdvanced() {
    advancedMode = !advancedMode;
    notifyListeners();
  }

  void toggleLease() {
    controlLease = !controlLease;
    notifyListeners();
  }

  void setApprovalMode(String mode) {
    approvalMode = mode;
    notifyListeners();
  }

  void toggleRunning() {
    running = !running;
    notifyListeners();
  }

  // ── Chat interactivity ──────────────────────────────────────────────

  String _now() {
    final t = DateTime.now();
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  List<ChatMsg> _msgs() => threads.putIfAbsent(sessionId, () => []);

  /// Relabelled send button: queue while a turn is running and messages are
  /// pending, steer while running, plain send when idle.
  String get sendLabel {
    if (!running) return 'send';
    return queue.isEmpty ? 'steer' : 'queue';
  }

  void sendUserMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final msgs = _msgs();
    if (running) {
      queue.add(trimmed);
      notifyListeners();
      return;
    }
    msgs.add(ChatMsg(
      id: 'u${msgs.length}',
      isUser: true,
      author: 'You',
      time: _now(),
      text: trimmed,
    ));
    _botResponds(trimmed);
  }

  void cancelQueued(int index) {
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      notifyListeners();
    }
  }

  /// Double-Enter style instant steer: inject a queued message into the turn.
  void steerNow(int index) {
    if (index < 0 || index >= queue.length) return;
    final text = queue.removeAt(index);
    _msgs().add(ChatMsg(
      id: 'q${_msgs().length}',
      kind: MsgKind.system,
      text: 'Steered mid-turn: "$text"',
      time: _now(),
    ));
    notifyListeners();
  }

  void _botResponds(String prompt) {
    final msgs = _msgs();
    final lower = prompt.toLowerCase();
    if (lower.contains('apolog') || lower.contains('sorry')) {
      msgs.add(const ChatMsg(
        id: 'n0',
        kind: MsgKind.system,
        text: 'Note: the user asked you to apologize. Respond normally in your own words.',
      ));
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      final list = _msgs();
      String reply = 'Got it — working on "$prompt". I will report back with results.';
      MsgKind kind = MsgKind.text;
      if (lower.contains('release')) {
        reply = 'Drafting the release notes now. Two commands need your approval first.';
        kind = MsgKind.approval;
      } else if (lower.contains('test')) {
        reply = 'Running the test suite.';
        kind = MsgKind.tool;
      }
      list.add(switch (kind) {
        MsgKind.approval => ChatMsg(
            id: 'ap${list.length}',
            kind: MsgKind.approval,
            text: 'Maus wants to run a command that needs approval.',
            command: 'git push origin main --dry-run',
            stackLabel: '1 of 1',
            time: _now(),
          ),
        MsgKind.tool => ChatMsg(
            id: 'tt${list.length}',
            kind: MsgKind.tool,
            toolName: 'bash',
            toolState: ToolState.running,
            text: 'cargo test --workspace',
            time: _now(),
          ),
        _ => ChatMsg(id: 'rx${list.length}', text: reply, time: _now()),
      });
      running = true;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Resolve a decision card in place and append the bot's follow-up.
  void resolveCard(String msgId, CardReply reply, {String? answer}) {
    final msgs = _msgs();
    final idx = msgs.indexWhere((m) => m.id == msgId);
    if (idx < 0) return;
    final card = msgs[idx];
    final label = switch (reply) {
      CardReply.allowed => 'Approved ✓ — command running',
      CardReply.denied => 'Denied · turn cancelled',
      CardReply.answered => 'You answered: "${answer ?? card.options.first}"',
      CardReply.saved => 'Saved securely · continuing task',
      CardReply.submitted => 'Submitted · scheduled',
      CardReply.undone => 'Approval undone · command reverted',
      CardReply.error => 'Retry succeeded',
    };
    msgs[idx] = ChatMsg(
      id: card.id,
      kind: card.kind == MsgKind.error ? MsgKind.error : MsgKind.system,
      author: card.author,
      time: card.time,
      text: label,
      undoable: reply == CardReply.allowed,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      _msgs().add(ChatMsg(
        id: 'rx${_msgs().length}',
        time: _now(),
        text: switch (reply) {
          CardReply.allowed => 'Command completed. Moving on with the next step.',
          CardReply.denied => 'Understood — skipping that step. What should I do instead?',
          CardReply.answered => 'Applying that choice now.',
          CardReply.saved => 'The secret is stored in the vault and never echoed back.',
          CardReply.submitted => 'Done — the schedule is set.',
          CardReply.undone => 'Rolled back cleanly.',
          CardReply.error => 'Retry succeeded, continuing the run.',
        },
      ));
      notifyListeners();
    });
    notifyListeners();
  }

  void undoCard(String msgId) {
    final msgs = _msgs();
    final idx = msgs.indexWhere((m) => m.id == msgId);
    if (idx < 0) return;
    msgs[idx] = ChatMsg(
      id: msgId,
      kind: MsgKind.system,
      text: 'Undone · approval withdrawn',
      time: _now(),
    );
    notifyListeners();
  }

  void editLastUserMessage() {
    final msgs = _msgs();
    final idx = msgs.lastIndexWhere((m) => m.isUser);
    if (idx < 0) return;
    final msg = msgs[idx];
    msgs.removeAt(idx);
    msgs.add(ChatMsg(
      id: msg.id,
      kind: MsgKind.system,
      text: 'Editing: "${msg.text}" — press send to replace.',
      time: _now(),
    ));
    notifyListeners();
  }

  void switchBranch(String msgId, int delta) {
    final count = branchCount[msgId] ?? 1;
    final current = branchIndex[msgId] ?? 1;
    branchIndex[msgId] = ((current - 1 + delta) % count) + 1;
    notifyListeners();
  }

  void retryTurn() {
    running = true;
    _msgs().add(const ChatMsg(
      id: 'retry',
      kind: MsgKind.system,
      text: 'Retrying the failed turn…',
    ));
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 900), () {
      _msgs().add(ChatMsg(
        id: 'rx${_msgs().length}',
        time: _now(),
        text: 'Retry succeeded — the turn completed.',
      ));
      notifyListeners();
    });
  }
}
