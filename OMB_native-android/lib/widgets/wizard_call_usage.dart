import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../state.dart';
import 'common.dart';

/// New Bot wizard: identity → soul → skills → memory → routines → access
/// → model → permissions → voice, with a step indicator.
class NewBotWizard extends StatefulWidget {
  const NewBotWizard({super.key});

  @override
  State<NewBotWizard> createState() => _NewBotWizardState();
}

class _NewBotWizardState extends State<NewBotWizard> {
  int _step = 0;
  String _visibility = 'Everyone';
  String _approval = 'Ask';
  String _where = 'Auto';

  static const _steps = [
    'Identity',
    'SOUL',
    'Skills',
    'Memory',
    'Routines',
    'Access',
    'Model',
    'Permissions',
    'Voice',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Bot',
                style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 26,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _steps.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => setState(() => _step = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: i == _step
                            ? kAccent
                            : i < _step
                                ? kGreen.withValues(alpha: 0.2)
                                : kSurfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (i < _step)
                            const Icon(Icons.check, color: kGreen, size: 12),
                          if (i < _step) const SizedBox(width: 4),
                          Text(
                            '${i + 1} ${_steps[i]}',
                            style: TextStyle(
                              color: i == _step ? Colors.black : kTextDim,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _steps[_step],
                style: const TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ..._stepBody(),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF3A3D44))),
          ),
          child: Row(
            children: [
              if (_step > 0)
                PrimaryButton(
                  label: 'Back',
                  filled: false,
                  onTap: () => setState(() => _step--),
                ),
              const Spacer(),
              if (_step < _steps.length - 1)
                PrimaryButton(
                  label: 'Next: ${_steps[_step + 1]}',
                  onTap: () => setState(() => _step++),
                )
              else
                PrimaryButton(
                  label: 'Create bot',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bot created — say hi to your new bot!')),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _stepBody() => switch (_step) {
        0 => [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Bot name',
                prefixIcon: Icon(Icons.smart_toy_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(hintText: 'Job title')),
            const SizedBox(height: 10),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(hintText: 'What should this bot be great at?'),
            ),
            const SizedBox(height: 14),
            _picker('Avatar', '🐭 mascot · amber', Icons.face),
            _picker('Visibility', _visibility, Icons.visibility, onTap: () {
              setState(() {
                _visibility = switch (_visibility) {
                  'Everyone' => 'Admins',
                  'Admins' => 'Specific people',
                  _ => 'Everyone',
                };
              });
            }),
            _picker('Team / section', 'Platform', Icons.folder_outlined),
          ],
        1 => [
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Standing instructions (SOUL)…',
              ),
            ),
            const SizedBox(height: 8),
            const Text('1.2 KB / 4 KB · saved to ~/.prime/soul.md',
                style: TextStyle(color: kTextDim, fontSize: 11)),
          ],
        2 => [
            _picker('Learned skills', '6 enabled · 1 needs review', Icons.school_outlined),
            _picker('Import from', 'repo · URL · library', Icons.download_outlined),
            _picker('Org skills', '2 available', Icons.business_outlined),
            TitledCard(title: 'Review queue', children: const [
              SettingsRow(title: 'release-notes skill', subtitle: 'SKILL.md · sha256 verified'),
            ]),
          ],
        3 => [
            _picker('Memory', 'Enabled · MEMORY.md', Icons.psychology_outlined),
            _picker('Memory upkeep', 'Nightly · learn from rooms', Icons.auto_awesome),
            _picker('Capacity', '42% used', Icons.pie_chart_outline),
          ],
        4 => [
            _picker('Routines', 'None yet — add on the calendar', Icons.calendar_month_outlined),
            _picker('Webhooks', 'Add triggers later', Icons.bolt_outlined),
          ],
        5 => [
            _picker('Working folder', '~/projects/release-bot', Icons.folder_open),
            _picker('Connected apps', 'GitHub · Slack', Icons.extension_outlined),
            _picker('Where it works', _where, Icons.computer_outlined, onTap: () {
              setState(() {
                _where = switch (_where) {
                  'Auto' => 'Local',
                  'Local' => 'Cloud',
                  _ => 'Auto',
                };
              });
            }),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kAccent.withValues(alpha: 0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: kAccent, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Local computer access runs unattended — you will be asked to acknowledge.',
                      style: TextStyle(color: kText, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        6 => [
            _picker('Default model', 'claude-sonnet · effort high', Icons.memory),
            _picker('Backup chain', '2 of 5 slots', Icons.link),
          ],
        7 => [
            _picker('Before it acts', _approval, Icons.gpp_maybe_outlined, onTap: () {
              setState(() {
                _approval = switch (_approval) {
                  'Ask' => 'Decide',
                  'Decide' => 'Full',
                  _ => 'Ask',
                };
              });
            }),
            _picker('Sending on your behalf', 'Ask every time', Icons.send_outlined),
            _picker('Chief of Staff', 'Off', Icons.account_tree_outlined),
          ],
        _ => [
            _picker('Voice engine', 'Built-in Mac', Icons.record_voice_over_outlined),
            _picker('Notifications', 'On', Icons.notifications_outlined),
            TitledCard(title: 'Preview', children: [
              const Text('"Hi! I am ready to help."',
                  style: TextStyle(color: kText, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: const [
                  PrimaryButton(label: 'Hear this voice'),
                  SizedBox(width: 8),
                  PrimaryButton(label: 'Skip', filled: false),
                ],
              ),
            ]),
          ],
      };

  Widget _picker(String title, String value, IconData icon, {VoidCallback? onTap}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: SettingsRow(
          title: title,
          subtitle: value,
          onTap: onTap,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: kTextDim, size: 17),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: kTextDim, size: 18),
            ],
          ),
        ),
      );
}

/// Voice call overlay: elapsed clock, captions, mute/hang-up, call settings.
class VoiceCallOverlay extends StatefulWidget {
  final AppState state;

  const VoiceCallOverlay({super.key, required this.state});

  @override
  State<VoiceCallOverlay> createState() => _VoiceCallOverlayState();
}

class _VoiceCallOverlayState extends State<VoiceCallOverlay> {
  bool _muted = false;
  bool _live = true;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    return Container(
      color: const Color(0xFF1A1C20),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          BotAvatar(emoji: session.emoji, size: 72, ring: true, ringColor: kGreen),
          const SizedBox(height: 12),
          Text(
            session.name,
            style: const TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text('04:32 · connected', style: TextStyle(color: kGreen, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Turns (push-to-talk)'),
                selected: !_live,
                onSelected: (_) => setState(() => _live = false),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Live'),
                selected: _live,
                onSelected: (_) => setState(() => _live = true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LIVE CAPTIONS', style: TextStyle(color: kTextDim, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  const Text('You:', style: TextStyle(color: kBlue, fontSize: 12, fontWeight: FontWeight.w700)),
                  const Text('"What is the status of the release notes?"', style: TextStyle(color: kText, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 12),
                  Text('${session.name}:', style: const TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.w700)),
                  const Text('"Two commands are pending your approval — want me to walk through them?"', style: TextStyle(color: kText, fontSize: 13, height: 1.4)),
                  const Spacer(),
                  Row(
                    children: const [
                      Icon(Icons.graphic_eq, color: kGreen, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Listening… (spoken approvals: yes/no)',
                            style: TextStyle(color: kTextDim, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roundBtn(
                _muted ? Icons.mic_off : Icons.mic,
                _muted ? kRed : kSurfaceAlt,
                () => setState(() => _muted = !_muted),
              ),
              const SizedBox(width: 18),
              _roundBtn(Icons.dialer_sip, kRed, () => state.openView(ViewKind.chat), size: 68),
              const SizedBox(width: 18),
              _roundBtn(Icons.settings_voice, kSurfaceAlt, () {}),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, Color bg, VoidCallback onTap, {double size = 56}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: bg == kRed ? Colors.white : kText, size: 26),
        ),
      );
}

/// Usage & spend screen: summary metrics, sparkline, per-bot table, budget.
class UsageScreen extends StatelessWidget {
  final AppState state;

  const UsageScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text('Usage & spend',
                    style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const PrimaryButton(label: 'Export CSV', filled: false),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _metric('This month', '\$4.20', '+12%', kAccent),
                  const SizedBox(width: 10),
                  _metric('Turns', '312', '+4%', kGreen),
                  const SizedBox(width: 10),
                  _metric('Tokens', '128k', '-2%', kBlue),
                ],
              ),
              const SizedBox(height: 16),
              TitledCard(title: 'Daily spend', children: [
                SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: CustomPaint(painter: _BarPainter()),
                ),
              ]),
              const SizedBox(height: 16),
              TitledCard(title: 'Per-bot', children: [
                _row('Bot', 'Turns', 'Cost', header: true),
                _row('Maus', '120', '\$2.10'),
                _row('Pip', '88', '\$1.40'),
                _row('Orbit', '104', '\$0.70'),
              ]),
              const SizedBox(height: 16),
              TitledCard(title: 'Budget', children: const [
                SettingsRow(title: 'Monthly cap', subtitle: '\$20.00 · warn at 80%'),
                SettingsRow(title: 'Custom price book', subtitle: '2 models overridden'),
                SettingsRow(title: 'History', subtitle: 'Per-bot table · CSV export'),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, String trend, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: kTextDim, fontSize: 10.5)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
              Text(trend, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );

  Widget _row(String a, String b, String c, {bool header = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF34373D))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(a,
                  style: TextStyle(
                      color: header ? kTextDim : kText,
                      fontSize: 12,
                      fontWeight: header ? FontWeight.w700 : FontWeight.w500)),
            ),
            Expanded(child: Text(b, style: TextStyle(color: header ? kTextDim : kText, fontSize: 12))),
            Expanded(child: Text(c, style: TextStyle(color: header ? kTextDim : kText, fontSize: 12))),
          ],
        ),
      );
}

class _BarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.3, 0.55, 0.4, 0.7, 0.5, 0.85, 0.6];
    final barW = size.width / (values.length * 2);
    for (var i = 0; i < values.length; i++) {
      final h = size.height * values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * barW * 2 + barW / 2, size.height - h, barW, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = kAccent.withValues(alpha: 0.75));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
