import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../state.dart';
import 'common.dart';

/// Chat screen: transcript + live decision cards + smart composer.
class ChatScreen extends StatefulWidget {
  final AppState state;

  const ChatScreen({super.key, required this.state});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scroll = ScrollController();

  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    state.addListener(_jumpToLatest);
  }

  @override
  void dispose() {
    state.removeListener(_jumpToLatest);
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients && mounted) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    return Column(
      children: [
        _ChatHeader(state: state, session: session),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('— Today —', style: TextStyle(color: kTextDim, fontSize: 11)),
                ),
              ),
              for (final msg in state.thread) ...[
                _MessageCard(msg: msg, state: state),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        if (state.queue.isNotEmpty) _QueuedStrip(state: state),
        _Composer(state: state),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final AppState state;
  final Session session;

  const _ChatHeader({required this.state, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: const BoxDecoration(
        color: kContentBg,
        border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
      ),
      child: Row(
        children: [
          if (MediaQuery.sizeOf(context).width < 900)
            IconButton(
              icon: const Icon(Icons.menu, color: kTextDim, size: 22),
              onPressed: () {
                HapticFeedback.selectionClick();
                state.setDrawer(!state.drawerOpen);
              },
            ),
          BotAvatar(emoji: session.emoji, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  session.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  session.isRoom
                      ? 'room · ${state.botSessions(true).length + state.botSessions(false).length} bots · lead Maus'
                      : 'claude-sonnet · effort high · ${state.approvalMode} mode',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kTextDim, fontSize: 11),
                ),
              ],
            ),
          ),
          if (state.running && MediaQuery.sizeOf(context).width >= 480)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: OutlinedButton.icon(
                onPressed: state.toggleRunning,
                icon: const Icon(Icons.stop_circle_outlined, size: 16, color: kRed),
                label: const Text('Stop', style: TextStyle(color: kRed, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kRed),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            )
          else if (!state.running && MediaQuery.sizeOf(context).width >= 480)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: OutlinedButton.icon(
                onPressed: state.toggleRunning,
                icon: const Icon(Icons.play_circle_outline, size: 16, color: kGreen),
                label: const Text('Resume', style: TextStyle(color: kGreen, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kGreen),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          _HeaderIcon(
            Icons.desktop_windows_outlined,
            onTap: () => state.openView(ViewKind.computer),
            active: state.view == ViewKind.computer,
          ),
          _HeaderIcon(
            Icons.tune,
            onTap: () => state.openView(ViewKind.botSettings),
            active: state.view == ViewKind.botSettings,
          ),
          _HeaderIcon(Icons.more_vert, onTap: () => _showMore(context)),
        ],
      ),
    );
  }

  void _showMore(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.search, color: kTextDim),
              title: const Text('Find in conversation'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: kTextDim),
              title: const Text('Export Markdown'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.insights_outlined, color: kTextDim),
              title: const Text('Usage'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.timeline, color: kTextDim),
              title: const Text('Activity'),
              onTap: () {
                Navigator.pop(context);
                state.openView(ViewKind.activity);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined, color: kTextDim),
              title: const Text('Inspector'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _HeaderIcon(this.icon, {required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        icon: Icon(icon, color: active ? kAccent : kTextDim, size: 20),
      );
}

class _MessageCard extends StatelessWidget {
  final ChatMsg msg;
  final AppState state;

  const _MessageCard({required this.msg, required this.state});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          BotAvatar(emoji: _authorEmoji(msg.author), size: 30),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (msg.kind != MsgKind.system && msg.kind != MsgKind.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${msg.author} · ${msg.time}',
                    style: const TextStyle(color: kTextDim, fontSize: 10.5),
                  ),
                ),
              _bubble(),
              if (isUser && state.branchCount[msg.id] != null)
                _BranchSwitcher(msg: msg, state: state),
            ],
          ),
        ),
      ],
    );
  }

  String _authorEmoji(String author) => switch (author) {
        'Maus' => '🤖',
        'Pip' => '🐧',
        'Orbit' => '🛰️',
        'You' => '🧑‍🚀',
        _ => '✨',
      };

  Widget _bubble() {
    switch (msg.kind) {
      case MsgKind.system:
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kSurface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    msg.text,
                    style: const TextStyle(color: kTextDim, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (msg.undoable) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => state.undoCard(msg.id),
                    child: const Text(
                      'Undo',
                      style: TextStyle(
                        color: kAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      case MsgKind.error:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kRed.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kRed.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: kRed, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(msg.text, style: const TextStyle(color: kText, fontSize: 13)),
              ),
              GestureDetector(
                onTap: () => state.retryTurn(),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: kRed, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      case MsgKind.tool:
        return _ToolChip(msg: msg);
      case MsgKind.approval:
        return _ApprovalCard(msg: msg, state: state);
      case MsgKind.question:
        return _QuestionCard(msg: msg, state: state);
      case MsgKind.secret:
        return _SecretCard(msg: msg, state: state);
      case MsgKind.widgetCard:
        return _WidgetCard(msg: msg, state: state);
      case MsgKind.verify:
        return _VerifyCard(msg: msg);
      case MsgKind.screenshot:
        return _ScreenshotCard(msg: msg);
      case MsgKind.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: msg.isUser ? kBlue.withValues(alpha: 0.25) : kSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(msg.text, style: const TextStyle(color: kText, fontSize: 13.5, height: 1.4)),
        );
    }
  }
}

class _BranchSwitcher extends StatelessWidget {
  final ChatMsg msg;
  final AppState state;

  const _BranchSwitcher({required this.msg, required this.state});

  @override
  Widget build(BuildContext context) {
    final count = state.branchCount[msg.id] ?? 1;
    final current = state.branchIndex[msg.id] ?? 1;
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => state.switchBranch(msg.id, -1),
            child: const Icon(Icons.chevron_left, color: kTextDim, size: 16),
          ),
          Text(
            '$current/$count',
            style: const TextStyle(color: kTextDim, fontSize: 10.5),
          ),
          GestureDetector(
            onTap: () => state.switchBranch(msg.id, 1),
            child: const Icon(Icons.chevron_right, color: kTextDim, size: 16),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: state.editLastUserMessage,
            child: const Text(
              'Edit',
              style: TextStyle(
                color: kTextDim,
                fontSize: 10.5,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final ChatMsg msg;

  const _ToolChip({required this.msg});

  @override
  Widget build(BuildContext context) {
    final color = switch (msg.toolState) {
      ToolState.running => kAccent,
      ToolState.done => kGreen,
      ToolState.failed => kRed,
    };
    final label = switch (msg.toolState) {
      ToolState.running => 'running',
      ToolState.done => 'completed',
      ToolState.failed => 'failed',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (msg.toolState == ToolState.running)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              else
                Icon(
                  msg.toolState == ToolState.failed ? Icons.error_outline : Icons.check_circle_outline,
                  color: color,
                  size: 15,
                ),
              const SizedBox(width: 8),
              Text(
                msg.toolName ?? 'tool',
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              StatusChip(label: label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF222429),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              msg.text,
              style: const TextStyle(
                color: Color(0xFFC9D1D9),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (msg.detail != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(msg.detail!, style: const TextStyle(color: kTextDim, fontSize: 11.5)),
            ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final ChatMsg msg;
  final AppState state;

  const _ApprovalCard({required this.msg, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gpp_maybe_outlined, color: kAccent, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Approval needed',
                  style: TextStyle(color: kAccent, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              if (msg.stackLabel != null)
                StatusChip(label: msg.stackLabel!, color: kTextDim),
            ],
          ),
          const SizedBox(height: 8),
          Text(msg.text, style: const TextStyle(color: kText, fontSize: 12.5, height: 1.35)),
          if (msg.command != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF222429),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                msg.command!,
                style: const TextStyle(
                  color: Color(0xFFC9D1D9),
                  fontSize: 11.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimaryButton(
                label: 'Allow once',
                onTap: () => state.resolveCard(msg.id, CardReply.allowed),
              ),
              PrimaryButton(
                label: 'Always allow',
                filled: false,
                onTap: () => state.resolveCard(msg.id, CardReply.allowed),
              ),
              PrimaryButton(
                label: 'This session',
                filled: false,
                onTap: () => state.resolveCard(msg.id, CardReply.allowed),
              ),
              PrimaryButton(
                label: 'Deny',
                filled: false,
                onTap: () => state.resolveCard(msg.id, CardReply.denied),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => state.resolveCard(msg.id, CardReply.denied),
            child: const Text(
              'Cancel turn · Show details',
              style: TextStyle(
                color: kTextDim,
                fontSize: 11,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final ChatMsg msg;
  final AppState state;

  const _QuestionCard({required this.msg, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBlue.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_outlined, color: kBlue, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Bot needs your input',
                  style: TextStyle(color: kBlue, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(msg.text, style: const TextStyle(color: kText, fontSize: 13, height: 1.35)),
          const SizedBox(height: 12),
          for (var i = 0; i < msg.options.length; i++)
            GestureDetector(
              onTap: () => state.resolveCard(
                msg.id,
                CardReply.answered,
                answer: msg.options[i],
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: kSurfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kBlue.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        String.fromCharCode(97 + i),
                        style: const TextStyle(color: kBlue, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(msg.options[i], style: const TextStyle(color: kText, fontSize: 13)),
                    ),
                    const Icon(Icons.touch_app_outlined, color: kTextDim, size: 14),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Or type your own answer in the composer…',
                  style: TextStyle(color: kTextDim, fontSize: 11.5),
                ),
              ),
              PrimaryButton(
                label: 'Send',
                onTap: () => state.resolveCard(msg.id, CardReply.answered),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecretCard extends StatelessWidget {
  final ChatMsg msg;
  final AppState state;

  const _SecretCard({required this.msg, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPurple.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: kPurple, size: 18),
              SizedBox(width: 8),
              Text(
                'Secret request',
                style: TextStyle(color: kPurple, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(msg.text, style: const TextStyle(color: kText, fontSize: 13)),
          const SizedBox(height: 12),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(hintText: 'Value is never shown in chat'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimaryButton(
                label: 'Save securely',
                onTap: () => state.resolveCard(msg.id, CardReply.saved),
              ),
              PrimaryButton(
                label: 'Continue task',
                filled: false,
                onTap: () => state.resolveCard(msg.id, CardReply.saved),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  final ChatMsg msg;
  final AppState state;

  const _WidgetCard({required this.msg, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4A4E57)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_customize_outlined, color: kAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  msg.text,
                  style: const TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final option in msg.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.circle_outlined, color: kTextDim, size: 10),
                  const SizedBox(width: 8),
                  Text(option, style: const TextStyle(color: kTextDim, fontSize: 12.5)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimaryButton(
                label: 'Confirm',
                onTap: () => state.resolveCard(msg.id, CardReply.submitted),
              ),
              PrimaryButton(
                label: 'Adjust',
                filled: false,
                onTap: () => state.resolveCard(msg.id, CardReply.answered, answer: 'adjust'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifyCard extends StatelessWidget {
  final ChatMsg msg;

  const _VerifyCard({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: kGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'Verify card',
                style: TextStyle(color: kGreen, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final step in msg.verifySteps)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    step.pass ? Icons.check_circle : Icons.cancel,
                    color: step.pass ? kGreen : kRed,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Text(step.label, style: const TextStyle(color: kText, fontSize: 12.5)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          const Text(
            'Save as skill',
            style: TextStyle(
              color: kAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotCard extends StatelessWidget {
  final ChatMsg msg;

  const _ScreenshotCard({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D4450), Color(0xFF25282E)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.desktop_windows_outlined, color: kTextDim, size: 34),
            ),
          ),
          const SizedBox(height: 6),
          Text(msg.text, style: const TextStyle(color: kTextDim, fontSize: 10.5)),
          if (msg.caption != null)
            Text(
              msg.caption!,
              style: const TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

class _QueuedStrip extends StatelessWidget {
  final AppState state;

  const _QueuedStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          const Icon(Icons.queue, color: kAccent, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.queue.length,
                itemBuilder: (context, i) => _chip(i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(int index) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: kSurfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => state.steerNow(index),
              child: Text(
                state.queue[index],
                style: const TextStyle(color: kText, fontSize: 11),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => state.steerNow(index),
              child: const Text(
                'steer',
                style: TextStyle(color: kAccent, fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => state.cancelQueued(index),
              child: const Icon(Icons.close, color: kTextDim, size: 12),
            ),
          ],
        ),
      );
}

class _Composer extends StatefulWidget {
  final AppState state;

  const _Composer({required this.state});

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    widget.state.sendUserMessage(_controller.text);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Column(
          children: [
            Row(
              children: [
                _ComposerChip(
                  icon: Icons.shield_outlined,
                  label: state.approvalMode,
                  color: kAccent,
                  onTap: () => _pickApprovalMode(context),
                ),
                const SizedBox(width: 6),
                const _ComposerChip(
                  icon: Icons.folder_outlined,
                  label: 'place',
                  color: kTextDim,
                ),
                const Spacer(),
                if (state.running && state.thread.isNotEmpty)
                  const _ComposerChip(
                    icon: Icons.warning_amber_outlined,
                    label: 'compact',
                    color: kAccent,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: kSurfaceAlt,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  if (_controller.text.isEmpty && state.thread.any((m) => m.isUser))
                    IconButton(
                      onPressed: state.editLastUserMessage,
                      tooltip: 'Edit last message (↑)',
                      icon: const Icon(Icons.north, color: kTextDim, size: 18),
                    )
                  else
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline, color: kTextDim, size: 22),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: state.running
                            ? 'Steer @Maus mid-turn · / for commands'
                            : 'Message @Maus · / for commands',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic_none, color: kTextDim, size: 22),
                  ),
                  const SizedBox(width: 2),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.sendLabel,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          state.running ? Icons.double_arrow : Icons.arrow_upward,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickApprovalMode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setModal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text('Approval mode', style: TextStyle(color: kText, fontWeight: FontWeight.w800)),
              for (final mode in ['ask', 'edits', 'auto', 'full', 'custom'])
                ListTile(
                  title: Text(mode),
                  trailing: mode == widget.state.approvalMode
                      ? const Icon(Icons.check, color: kAccent)
                      : null,
                  onTap: () {
                    widget.state.setApprovalMode(mode);
                    setModal(() {});
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ComposerChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kSurfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
}
