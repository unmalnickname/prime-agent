import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../state.dart';
import 'common.dart';

/// Routines calendar: schedule list + run logs + webhooks.
class RoutinesScreen extends StatefulWidget {
  final AppState state;

  const RoutinesScreen({super.key, required this.state});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final Set<String> _paused = {'war-room · Daily standup call'};
  String _view = 'Day';

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScreenHeader(
          title: 'Routines',
          subtitle: '${state.workspace.name} · 4 schedules · ${_paused.length} paused',
          onMenu: () => state.setDrawer(!state.drawerOpen),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  for (final v in ['Day', 'Week', 'List'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PrimaryButton(
                        label: v,
                        filled: _view == v,
                        onTap: () => setState(() => _view = v),
                      ),
                    ),
                  const Spacer(),
                  const PrimaryButton(label: '+ Quick create', filled: false),
                ],
              ),
              const SizedBox(height: 16),
              const SectionHeader('SCHEDULE'),
              _RoutineCard(
                emoji: '🤖',
                name: 'Maus · Release digest',
                schedule: 'Weekdays 09:00 · timezone local',
                status: 'completed',
                color: kGreen,
                detail: 'Stop if still running: 30 min · overlap: queue',
                enabled: !_paused.contains('Maus · Release digest'),
                onToggle: () => _toggle('Maus · Release digest'),
              ),
              _RoutineCard(
                emoji: '🐧',
                name: 'Pip · Integration sweep',
                schedule: 'Every 6 hours · next run 14:00',
                status: 'running',
                color: kAccent,
                detail: "Run on: Bot's setup · results → war-room",
                enabled: !_paused.contains('Pip · Integration sweep'),
                onToggle: () => _toggle('Pip · Integration sweep'),
              ),
              _RoutineCard(
                emoji: '🛰️',
                name: 'Orbit · Dashboard watch',
                schedule: 'Cron 0 */2 * * * · next run 12:00',
                status: 'failed ×2',
                color: kRed,
                detail: 'Failure streak notice · keep-awake on',
                enabled: !_paused.contains('Orbit · Dashboard watch'),
                onToggle: () => _toggle('Orbit · Dashboard watch'),
              ),
              _RoutineCard(
                emoji: '📢',
                name: 'war-room · Daily standup call',
                schedule: 'Daily 10:00 · Call mode',
                status: _paused.contains('war-room · Daily standup call') ? 'paused' : 'missed',
                color: kTextDim,
                detail: _paused.contains('war-room · Daily standup call')
                    ? 'Paused by you'
                    : 'Resumed · next run tomorrow 10:00',
                enabled: !_paused.contains('war-room · Daily standup call'),
                onToggle: () => _toggle('war-room · Daily standup call'),
              ),
              const SizedBox(height: 20),
              const SectionHeader('RUN LOGS'),
              TitledCard(title: 'Recent runs', children: const [
                SettingsRow(title: 'Release digest', subtitle: '09:00 · completed · 2m 14s'),
                SettingsRow(title: 'Integration sweep', subtitle: '08:00 · failed · harness unreachable'),
                SettingsRow(title: 'Dashboard watch', subtitle: '06:00 · completed · 41s'),
                SettingsRow(title: 'Mark all seen', subtitle: 'Unseen failures: 1'),
              ]),
              const SizedBox(height: 20),
              const SectionHeader('WEBHOOKS / TRIGGERS'),
              TitledCard(title: 'Incoming triggers', children: const [
                SettingsRow(
                  title: 'github-push → Maus',
                  subtitle: 'URL private · rotate · 3 recent deliveries',
                ),
                SettingsRow(
                  title: 'When [github release] … Should [draft notes]',
                  subtitle: 'Form builder · max pending 10 → 429',
                ),
                SettingsRow(title: 'Paused', subtitle: 'stripe-events (disabled)'),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  void _toggle(String name) {
    setState(() {
      if (_paused.contains(name)) {
        _paused.remove(name);
      } else {
        _paused.add(name);
      }
    });
  }
}

class _RoutineCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String schedule;
  final String status;
  final Color color;
  final String detail;
  final bool enabled;
  final VoidCallback onToggle;

  const _RoutineCard({
    required this.emoji,
    required this.name,
    required this.schedule,
    required this.status,
    required this.color,
    required this.detail,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3E424A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BotAvatar(emoji: emoji, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: kText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    StatusChip(label: status, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(schedule, style: const TextStyle(color: kTextDim, fontSize: 11.5)),
                Text(detail, style: const TextStyle(color: kTextDim, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            activeThumbColor: kGreen,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

/// Team Map: bot/team nodes, edges, team memory.
class TeamMapScreen extends StatelessWidget {
  final AppState state;

  const TeamMapScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScreenHeader(
          title: 'Team map',
          subtitle: '${state.workspace.name} · 2 teams · 4 bots',
          onMenu: () => state.setDrawer(!state.drawerOpen),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFF222429),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3E424A)),
                ),
                child: const _MapCanvas(),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  PrimaryButton(label: '+ Team'),
                  SizedBox(width: 8),
                  PrimaryButton(label: '+ Cloud computer', filled: false),
                  SizedBox(width: 8),
                  PrimaryButton(label: '+ Local VM', filled: false),
                ],
              ),
              const SizedBox(height: 20),
              const SectionHeader('TEAMS'),
              TitledCard(title: 'Platform · Chief: Maus', children: const [
                SettingsRow(title: 'Shared instructions', subtitle: 'Goals / Decisions / Preferences'),
                SettingsRow(title: 'Team memory', subtitle: 'People · Places · Decisions · Terms'),
                SettingsRow(title: 'Bulk Team Settings', subtitle: 'Preview diff · Apply 4'),
                SettingsRow(title: 'Team computer', subtitle: 'shared-access acknowledged'),
              ]),
              const SizedBox(height: 16),
              const SectionHeader('EDGES'),
              TitledCard(title: 'Bot ↔ bot links', children: const [
                SettingsRow(title: 'Maus → Pip', subtitle: 'running · delegate tasks'),
                SettingsRow(title: 'Maus → Orbit', subtitle: 'queued · watch dashboards'),
                SettingsRow(title: 'Pip ↔ Quill', subtitle: 'connected'),
              ]),
              const SizedBox(height: 16),
              const SectionHeader('TEAM LIBRARY'),
              TitledCard(title: 'Share & import', children: const [
                SettingsRow(title: 'Org packages', subtitle: 'One-click add'),
                SettingsRow(title: 'Explore', subtitle: 'Search · GitHub URL import'),
                SettingsRow(title: 'Share team', subtitle: 'Portable .md · secret redaction'),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 30,
          top: 40,
          child: _MapNode(emoji: '🤖', label: 'Maus', color: kAccent),
        ),
        Positioned(
          left: 150,
          top: 110,
          child: _MapNode(emoji: '🐧', label: 'Pip', color: kGreen),
        ),
        Positioned(
          right: 40,
          top: 46,
          child: _MapNode(emoji: '🛰️', label: 'Orbit', color: kBlue),
        ),
        Positioned(
          right: 56,
          bottom: 26,
          child: _MapNode(emoji: '🖥️', label: 'cloud-1', color: kPurple),
        ),
        CustomPaint(
          size: const Size(double.infinity, 240),
          painter: _EdgePainter(),
        ),
      ],
    );
  }
}

class _MapNode extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _MapNode({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: kSurfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label, style: const TextStyle(color: kText, fontSize: 10.5)),
        ),
      ],
    );
  }
}

class _EdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..color = const Color(0xFF4A4E57);
    void line(Offset a, Offset b, {Color? color}) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 2
          ..color = color ?? const Color(0xFF4A4E57),
      );
    }

    line(const Offset(70, 80), const Offset(180, 140), color: kGreen);
    line(const Offset(70, 80), const Offset(260, 90), color: kAccent);
    line(const Offset(260, 100), const Offset(300, 190));
    canvas.drawCircle(const Offset(70, 80), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// App Settings modal content: You / AI / Computers / Account groups.
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDrawerBg,
      appBar: AppBar(
        backgroundColor: kDrawerBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('App Settings', style: TextStyle(color: kText, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('AI'),
          TitledCard(title: 'Engines & models', children: const [
            SettingsRow(title: 'Provider API keys', subtitle: '9 providers · write-only secrets'),
            SettingsRow(title: 'Custom OpenAI URL', subtitle: 'Configured'),
            SettingsRow(title: 'Subscription accounts', subtitle: 'Claude · Codex · ChatGPT plan'),
            SettingsRow(title: 'Decision model', subtitle: 'Jev · room routing · latency test'),
          ]),
          const SectionHeader('YOU'),
          TitledCard(title: 'Profile & preferences', children: const [
            SettingsRow(title: 'Profile & About me', subtitle: 'Learned facts'),
            SettingsRow(title: 'Send key', subtitle: 'Enter'),
            SettingsRow(title: 'Skin & font', subtitle: 'Maus dark · 13sp'),
            SettingsRow(title: 'Simple ↔ Advanced', subtitle: 'Master switch'),
            SettingsRow(title: 'Automatic recovery', subtitle: 'Backup engine + model'),
            SettingsRow(title: 'Diagnostics export', subtitle: 'Secret-free'),
          ]),
          const SectionHeader('COMPUTERS'),
          TitledCard(title: 'Pairing & access', children: const [
            SettingsRow(title: 'Phone pairing', subtitle: 'Tailscale · QR + app links'),
            SettingsRow(title: 'Custom domain', subtitle: 'DNS verified'),
            SettingsRow(title: 'Computer access sharing', subtitle: 'Folders · terminal · control'),
            SettingsRow(title: 'Logins vault', subtitle: 'Passwords · 2FA · TOTP'),
          ]),
          const SectionHeader('ACCOUNT'),
          TitledCard(title: 'Cloud & organization', children: const [
            SettingsRow(title: 'Cloud account', subtitle: 'Trial · 12 days left'),
            SettingsRow(title: 'Organization', subtitle: 'Managed models · license'),
            SettingsRow(title: 'People', subtitle: 'Invite · roles · domain-wide'),
            SettingsRow(title: 'Usage & budget', subtitle: 'Monthly cap · warn at 80%'),
            SettingsRow(title: 'Backups', subtitle: 'Passworded export · daily snapshots'),
            SettingsRow(title: 'Activity log', subtitle: 'Filters · before/after diffs · CSV'),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onMenu;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: kTextDim, size: 22),
            onPressed: onMenu,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: kTextDim, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
