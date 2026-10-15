import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../state.dart';
import 'common.dart';

/// Bot Settings side panel (Identity / Model / Permissions / Skills / Memory).
class BotSettingsPanel extends StatefulWidget {
  final AppState state;

  const BotSettingsPanel({super.key, required this.state});

  @override
  State<BotSettingsPanel> createState() => _BotSettingsPanelState();
}

class _BotSettingsPanelState extends State<BotSettingsPanel> {
  bool _keepWarm = true;
  bool _notifications = true;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    return _PanelScaffold(
      title: 'Bot Settings · ${session.name}',
      onClose: () => state.openView(ViewKind.chat),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              BotAvatar(emoji: session.emoji, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maus',
                        style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('Release assistant · team Platform',
                        style: TextStyle(color: kTextDim, fontSize: 12)),
                  ],
                ),
              ),
              const PrimaryButton(label: 'Save'),
            ],
          ),
          const SizedBox(height: 18),
          const SectionHeader('IDENTITY'),
          TitledCard(title: 'Who is the bot?', children: const [
            SettingsRow(title: 'Avatar', subtitle: 'AI generator · mascot · upload'),
            SettingsRow(title: 'Name & job title', subtitle: 'Maus · Release assistant'),
            SettingsRow(title: 'SOUL instructions', subtitle: '1.2 KB · no file drift'),
            SettingsRow(title: 'Visibility', subtitle: 'Everyone in workspace'),
          ]),
          const SectionHeader('BRAIN'),
          TitledCard(title: 'Model', children: const [
            SettingsRow(title: 'Default model', subtitle: 'claude-sonnet · effort high'),
            SettingsRow(title: 'Backup fallback chain', subtitle: '2 of 5 slots used'),
          ]),
          TitledCard(title: 'Behavior', children: [
            SettingsRow(
              title: 'Cache keep-warm',
              trailing: Switch(
                value: _keepWarm,
                activeThumbColor: kAccent,
                onChanged: (v) => setState(() => _keepWarm = v),
              ),
            ),
            SettingsRow(
              title: 'Notifications',
              trailing: Switch(
                value: _notifications,
                activeThumbColor: kAccent,
                onChanged: (v) => setState(() => _notifications = v),
              ),
            ),
          ]),
          const SectionHeader('PERMISSIONS'),
          TitledCard(title: 'What the bot may do', children: [
            SettingsRow(
              title: 'Approval level',
              subtitle: 'Currently: ${state.approvalMode}',
              trailing: Icon(Icons.tune, color: kAccent, size: 18),
            ),
            const SettingsRow(title: 'Chief of Staff', subtitle: 'Off · manages 0 teams'),
            const SettingsRow(title: 'Sending on your behalf', subtitle: 'Ask every time'),
            const SettingsRow(title: 'Works on', subtitle: 'Auto · Local VM · Cloud (Boat)'),
            const SettingsRow(title: 'Working folder', subtitle: '~/projects/release-bot'),
            const SettingsRow(title: 'Connected apps', subtitle: 'GitHub (read&write) · Slack (read)'),
            const SettingsRow(title: 'MCP servers', subtitle: '2 enabled'),
            const SettingsRow(title: 'Tool selection', subtitle: 'native: + 4 mcp: tools'),
            const SettingsRow(title: 'Always allowed', subtitle: '3 standing approvals'),
          ]),
          if (state.advancedMode) ...[
            const SectionHeader('KNOWLEDGE & BEHAVIOR'),
            TitledCard(title: 'Skills / Memory / Routines', children: const [
              SettingsRow(title: 'Learned skills', subtitle: '6 enabled · 1 needs review'),
              SettingsRow(title: 'Memory', subtitle: 'MEMORY.md · capacity 42%'),
              SettingsRow(title: 'Memory upkeep', subtitle: 'Nightly · learn from rooms'),
              SettingsRow(title: 'Routines', subtitle: '2 schedules'),
            ]),
            const SectionHeader('VOICE & AUDIT'),
            TitledCard(title: 'Voice, history, spend', children: const [
              SettingsRow(title: 'Voice engine', subtitle: 'Built-in Mac · preview'),
              SettingsRow(title: 'Change log', subtitle: '12 changes · SOUL rollback'),
              SettingsRow(title: 'Usage', subtitle: '312 turns · \$4.20 this month'),
            ]),
          ] else ...[
            const SectionHeader('SIMPLE MODE'),
            TitledCard(title: 'Quick setup', children: const [
              SettingsRow(title: 'Look', subtitle: 'Mascot · amber'),
              SettingsRow(title: 'Thinking', subtitle: 'Friendly labels'),
              SettingsRow(title: 'Before it acts', subtitle: 'Ask / Decide / Full'),
              SettingsRow(title: 'All settings', subtitle: 'Switch to Advanced'),
            ]),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Computer Panel: destination grid, control lease, browser profiles.
class ComputerPanel extends StatefulWidget {
  final AppState state;

  const ComputerPanel({super.key, required this.state});

  @override
  State<ComputerPanel> createState() => _ComputerPanelState();
}

class _ComputerPanelState extends State<ComputerPanel> {
  String _destination = 'Auto';

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return _PanelScaffold(
      title: 'Computer · ${state.session.name}',
      onClose: () => state.openView(ViewKind.chat),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('WHERE THE BOT WORKS'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              for (final (icon, label) in const [
                (Icons.auto_mode, 'Auto'),
                (Icons.cloud_outlined, 'Cloud'),
                (Icons.computer_outlined, 'Local VM'),
                (Icons.laptop_mac, 'This computer'),
                (Icons.public, 'Browser'),
                (Icons.block, 'Off'),
              ])
                _DestTile(
                  icon: icon,
                  label: label,
                  selected: _destination == label,
                  onTap: () => setState(() => _destination = label),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TitledCard(title: 'Live view', children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3D4450), Color(0xFF25282E)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.desktop_windows_outlined, color: kTextDim, size: 40),
                    SizedBox(height: 6),
                    Text('local-mac · screenshot 4s ago',
                        style: TextStyle(color: kTextDim, fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: state.controlLease ? 'Hand back' : 'Take control',
                    onTap: state.toggleLease,
                    filled: !state.controlLease,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: PrimaryButton(label: 'Open live desktop', filled: false)),
              ],
            ),
            if (state.controlLease)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: StatusChip(label: 'YOU HAVE THE WHEEL', color: kAccent),
              ),
          ]),
          const SizedBox(height: 16),
          TitledCard(title: 'Browser profiles', children: const [
            SettingsRow(title: 'Own profile', subtitle: 'built-in engine · 6 signed-in sites'),
            SettingsRow(title: 'guest', subtitle: 'ephemeral'),
            SettingsRow(title: 'client-x', subtitle: 'my Chrome · 2 signed-in sites'),
            SettingsRow(title: 'Restart browser', subtitle: 'Keeps logins'),
          ]),
          const SizedBox(height: 16),
          TitledCard(title: 'Safety', children: const [
            SettingsRow(
              title: 'Unattended local control',
              subtitle: 'Warning acknowledged for this session',
            ),
            SettingsRow(title: 'macOS permissions', subtitle: 'Accessibility ✓ · Screen Recording ✓'),
            SettingsRow(title: 'Cloud lending', subtitle: '1 folder shared · edit rights'),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DestTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DestTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? kAccent : kTextDim;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? kAccent.withValues(alpha: 0.14) : kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kAccent : const Color(0xFF3E424A),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? kAccent : kText,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity panel: day-grouped tool and approval rows.
class ActivityPanel extends StatelessWidget {
  final AppState state;

  const ActivityPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('09:15', 'bash', 'git log --oneline', 'done', kGreen),
      ('09:13', 'approval', 'curl hooks.slack.com', 'held', kAccent),
      ('09:12', 'edit', 'RELEASE-NOTES.md', 'done', kGreen),
      ('08:42', 'python_repl', 'pytest -x', 'failed', kRed),
      ('08:41', 'system', 'turn started', 'done', kGreen),
    ];
    return _PanelScaffold(
      title: 'Activity · ${state.session.name}',
      onClose: () => state.openView(ViewKind.chat),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('TODAY'),
          for (final (time, tool, detail, status, color) in rows)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(time, style: TextStyle(color: kTextDim, fontSize: 11)),
                  const SizedBox(width: 10),
                  Text(tool,
                      style: TextStyle(
                          color: kText, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(detail,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: kTextDim, fontSize: 11.5)),
                  ),
                  StatusChip(label: status, color: color),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const PrimaryButton(label: 'Open Inspector', filled: false),
        ],
      ),
    );
  }
}

/// Shared chrome for right-side panels on wide screens, full-screen on phones.
class _PanelScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;

  const _PanelScaffold({
    required this.title,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDrawerBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: kText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: kTextDim, size: 20),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
