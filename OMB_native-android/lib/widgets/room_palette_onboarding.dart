import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../state.dart';
import 'common.dart';

/// Group Room: room transcript shell + bulletin, members, responder mode,
/// room setup wizard, group usage, group voice call.
class GroupRoomScreen extends StatefulWidget {
  final AppState state;

  const GroupRoomScreen({super.key, required this.state});

  @override
  State<GroupRoomScreen> createState() => _GroupRoomScreenState();
}

class _GroupRoomScreenState extends State<GroupRoomScreen> {
  String _responder = 'Mentions';
  final String _lead = 'Maus';

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
          ),
          child: Row(
            children: [
              const BotAvatar(emoji: '📢', size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('war-room',
                        style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('3 bots · goal: unblock staging deploy',
                        style: TextStyle(color: kTextDim, fontSize: 11)),
                  ],
                ),
              ),
              StatusChip(label: 'group usage \$0.42', color: kAccent),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => state.openView(ViewKind.voiceCall),
                icon: Icon(Icons.call_outlined, color: kGreen, size: 20),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _bulletin(),
              const SizedBox(height: 16),
              const SectionHeader('MEMBER MANAGER'),
              _members(),
              const SizedBox(height: 16),
              const SectionHeader('RESPONDER MODE'),
              _responderPicker(),
              const SizedBox(height: 16),
              const SectionHeader('ROOM SETUP'),
              TitledCard(title: 'Room settings', children: [
                const SettingsRow(title: 'Working folder', subtitle: '~/projects/staging'),
                SettingsRow(title: 'Lead bot', subtitle: '$_lead · Chief of Staff'),
                const SettingsRow(title: 'Shared instructions', subtitle: '3 lines'),
                const SettingsRow(title: 'Per-room turn timeout', subtitle: '120s'),
                const SettingsRow(title: 'Room setup wizard', subtitle: 'Re-run guided setup'),
              ]),
              const SizedBox(height: 16),
              const SectionHeader('GOAL RUNS'),
              TitledCard(title: 'Active goals', children: [
                const SettingsRow(
                  title: 'Unblock staging deploy',
                  subtitle: 'lead Maus · 3 bots · running',
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.6,
                  color: kGreen,
                  backgroundColor: kSurfaceAlt,
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    PrimaryButton(label: 'Join goal'),
                    SizedBox(width: 8),
                    PrimaryButton(label: 'Stop', filled: false),
                  ],
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bulletin() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_outlined, color: kAccent, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Room bulletin',
                      style: TextStyle(color: kAccent, fontSize: 13, fontWeight: FontWeight.w800)),
                ),
                Icon(Icons.edit_outlined, color: kTextDim, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Deploy gate is at migration step. Pip is fixing it. Orbit watches dashboards. '
              'Maus coordinates. Post blockers here, keep chatter to threads.',
              style: TextStyle(color: kText, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
      );

  Widget _members() => TitledCard(title: '4 members', children: [
        _memberRow('🤖', 'Maus', 'Chief · lead', kAccent),
        _memberRow('🐧', 'Pip', 'fixing migration', kGreen),
        _memberRow('🛰️', 'Orbit', 'watching dashboards', kBlue),
        _memberRow('✒️', 'Quill', 'idle', kTextDim),
        const SizedBox(height: 8),
        const PrimaryButton(label: '+ Add bot', filled: false),
      ]);

  Widget _memberRow(String emoji, String name, String role, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(role, style: TextStyle(color: color, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.more_vert, color: kTextDim, size: 16),
          ],
        ),
      );

  Widget _responderPicker() => Row(
        children: [
          for (final mode in ['Auto', 'Everyone', 'Mentions'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(mode),
                selected: _responder == mode,
                onSelected: (_) => setState(() => _responder = mode),
              ),
            ),
        ],
      );
}

/// Command palette (⌘K): search bots, rooms, messages, with categories.
class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  String _query = '';

  static const _items = [
    ('🤖', 'Maus', 'bot'),
    ('🐧', 'Pip', 'bot'),
    ('🛰️', 'Orbit', 'bot'),
    ('📢', 'war-room', 'room'),
    ('🕘', 'daily-standup', 'room'),
    ('💬', 'Pull the changes from the last sprint…', 'message'),
    ('💬', 'Clean up the failing integration tests', 'message'),
    ('⚙️', 'Open Bot Settings', 'command'),
    ('⌨️', 'Keyboard Shortcuts', 'command'),
    ('📊', 'Usage & spend', 'command'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _items
        .where((i) => i.$2.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Container(
      color: Colors.black54,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 80),
      child: Container(
        width: 520,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: kDrawerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4A4E57)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search bots, rooms, messages, commands…',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final (icon, label, kind) = results[i];
                  return ListTile(
                    dense: true,
                    leading: Text(icon, style: const TextStyle(fontSize: 18)),
                    title: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: kText, fontSize: 13)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kSurfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(kind,
                          style: TextStyle(color: kTextDim, fontSize: 10)),
                    ),
                    onTap: () => Navigator.pop(context),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('↑↓ navigate', style: TextStyle(color: kTextDim, fontSize: 10)),
                  SizedBox(width: 12),
                  Text('↵ select', style: TextStyle(color: kTextDim, fontSize: 10)),
                  SizedBox(width: 12),
                  Text('esc close', style: TextStyle(color: kTextDim, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keyboard shortcuts modal, grouped by category.
class KeyboardShortcuts extends StatelessWidget {
  const KeyboardShortcuts({super.key});

  static const _groups = [
    ('Navigation', [
      ('⌘K', 'Command palette'),
      ('⌘N', 'New chat'),
      ('⌘F', 'Find in conversation'),
      ('⌘1–9', 'Switch to bot N'),
      ('Shift+[ ]', 'Cycle bots'),
    ]),
    ('Chat & Composer', [
      ('↑', 'Edit last message'),
      ('Enter', 'Send'),
      ('Shift+Enter', 'New line'),
      ('⌘↵', 'Instant steer'),
    ]),
    ('Calls', [
      ('Space', 'Push to talk'),
      ('⌘⇧C', 'Start call'),
      ('Esc', 'End call'),
    ]),
    ('Management & Groups', [
      ('⌘⇧A', 'Activity'),
      ('⌘⇧R', 'Routines'),
      ('⌘⇧T', 'Team map'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: kDrawerBg,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Keyboard Shortcuts',
                      style: TextStyle(color: kText, fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: kTextDim, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (group, shortcuts) in _groups) ...[
                    SectionHeader(group),
                    for (final (key, desc) in shortcuts)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kSurfaceAlt,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(key,
                                  style: TextStyle(
                                      color: kText,
                                      fontSize: 11,
                                      fontFamily: 'monospace')),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(desc,
                                  style: TextStyle(color: kTextDim, fontSize: 12.5)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onboarding: welcome beats + guided tour steps + first-conversation spotlights.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _beat = 0;

  static const _beats = [
    ('👋', 'Welcome to Prime Agent', 'Set up your profile to personalize the bots.'),
    ('🎬', 'Feature reel', 'Chat, computers, routines, teams — see what bots can do.'),
    ('⚙️', 'Engine setup', 'Install an engine or sign in to a cloud provider.'),
    ('🎤', 'Microphone', 'Allow mic access for voice calls and read-aloud.'),
    ('📱', 'Phone pairing', 'Pair your phone to run bots on the go.'),
    ('✨', 'Personalize your first bot', 'Give it a name, job, and voice.'),
  ];

  static const _tour = [
    ('Composer', 'Type here to steer your bot'),
    ('Model picker', 'Choose model and effort level'),
    ('Computer', 'Give the bot a machine'),
    ('Browser tabs', 'Watch and take over browsing'),
    ('Tools', 'Routines, triggers, apps'),
    ('Apps marketplace', 'Install connectors'),
    ('Automations', 'Schedule recurring work'),
    ('Calendar', 'Drag a bot onto any time slot'),
  ];

  @override
  Widget build(BuildContext context) {
    final (emoji, title, sub) = _beats[_beat];
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 18),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kText, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(sub,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kTextDim, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _beats.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _beat == i ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _beat == i ? kAccent : kSurfaceAlt,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Guided tour checklist (the 10-step tour from the diagnostic).
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var i = 0; i < _tour.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i <= _beat ? kAccent.withValues(alpha: 0.15) : kSurfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${i + 1}. ${_tour[i].$1}',
                        style: TextStyle(
                          color: i <= _beat ? kAccent : kTextDim,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_beat > 0)
                PrimaryButton(
                  label: 'Back',
                  filled: false,
                  onTap: () => setState(() => _beat--),
                ),
              const Spacer(),
              if (_beat < _beats.length - 1)
                PrimaryButton(
                  label: 'Next',
                  onTap: () => setState(() => _beat++),
                )
              else
                PrimaryButton(label: 'Start tour', onTap: () => setState(() => _beat = 0)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-window setup states: no engines, cloud sign-in, cloud intent.
class SetupStatesScreen extends StatefulWidget {
  const SetupStatesScreen({super.key});

  @override
  State<SetupStatesScreen> createState() => _SetupStatesScreenState();
}

class _SetupStatesScreenState extends State<SetupStatesScreen> {
  int _state = 0;

  static const _states = [
    ('🔧', 'No engines installed', 'Install a local engine or sign in to a cloud provider to get started.'),
    ('☁️', 'Sign in to cloud', 'Connect your cloud account to run bots on managed machines.'),
    ('💭', 'What should I do?', 'Tell the bot your goal and it will plan the steps.'),
  ];

  @override
  Widget build(BuildContext context) {
    final (emoji, title, sub) = _states[_state];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              for (var i = 0; i < _states.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(['No engines', 'Cloud sign-in', 'Cloud intent'][i]),
                    selected: _state == i,
                    onSelected: (_) => setState(() => _state = i),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 18),
                  Text(title,
                      style: TextStyle(
                          color: kText, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Text(sub,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextDim, fontSize: 14, height: 1.5)),
                  ),
                  const SizedBox(height: 24),
                  if (_state == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        PrimaryButton(label: 'Install engine'),
                        SizedBox(width: 10),
                        PrimaryButton(label: 'Sign in to cloud', filled: false),
                      ],
                    )
                  else if (_state == 1)
                    const SizedBox(
                      width: 280,
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Email address'),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 320,
                      child: TextField(
                        maxLines: 3,
                        decoration: InputDecoration(hintText: 'Describe what you want done…'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
