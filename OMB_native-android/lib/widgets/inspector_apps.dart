import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../state.dart';
import 'common.dart';

/// Inspector: run timeline (RunLog), raw runtime events, native protocol messages.
class InspectorScreen extends StatefulWidget {
  final AppState state;

  const InspectorScreen({super.key, required this.state});

  @override
  State<InspectorScreen> createState() => _InspectorScreenState();
}

class _InspectorScreenState extends State<InspectorScreen> {
  int _tab = 0;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text('Inspector',
                    style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const PrimaryButton(label: 'Copy log', filled: false),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(['Timeline', 'Runtime events', 'Protocol'][i]),
                    selected: _tab == i,
                    onSelected: (_) => setState(() => _tab = i),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: switch (_tab) {
              0 => _timeline(),
              1 => _runtimeEvents(),
              _ => _protocolMessages(),
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _timeline() => [
        for (final (time, label, detail, color) in [
          ('09:15', 'verify.step', 'links resolve → fail', kRed),
          ('09:15', 'screenshot', 'chrome · docs preview', kBlue),
          ('09:14', 'widget.submit', 'publish schedule confirmed', kGreen),
          ('09:13', 'question.answer', 'Mark as experimental', kBlue),
          ('09:13', 'approval.held', 'curl hooks.slack.com', kAccent),
          ('09:13', 'tool.edit', 'RELEASE-NOTES.md running', kAccent),
          ('09:12', 'tool.bash', 'git log --oneline → done', kGreen),
          ('09:12', 'turn.start', 'goal run started', kGreen),
        ])
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(width: 3, height: 28, color: color),
                const SizedBox(width: 10),
                Text(time, style: TextStyle(color: kTextDim, fontSize: 11)),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        color: color, fontSize: 11.5, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(detail,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: kTextDim, fontSize: 11.5)),
                ),
              ],
            ),
          ),
      ];

  List<Widget> _runtimeEvents() => [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF222429),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '{\n'
            '  "type": "tool_call",\n'
            '  "name": "bash",\n'
            '  "args": { "cmd": "git log --oneline" },\n'
            '  "state": "completed",\n'
            '  "latency_ms": 214\n'
            '}\n\n'
            '{\n'
            '  "type": "approval_request",\n'
            '  "command": "curl -fsSL …",\n'
            '  "stack": [1, 2]\n'
            '}\n\n'
            '{\n'
            '  "type": "turn_delta",\n'
            '  "tokens": 128,\n'
            '  "stream": "text"\n'
            '}',
            style: TextStyle(
              color: Color(0xFF8BC34A),
              fontSize: 11.5,
              height: 1.55,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ];

  List<Widget> _protocolMessages() => [
        TitledCard(title: 'Native protocol', children: const [
          SettingsRow(title: 'thread.attach', subtitle: '→ daemon · 10:01:02.114'),
          SettingsRow(title: 'event.stream', subtitle: '← SSE · 1,204 events'),
          SettingsRow(title: 'tool.invoke', subtitle: '→ worker · bash'),
          SettingsRow(title: 'approval.ask', subtitle: '← worker · held'),
          SettingsRow(title: 'approval.resolve', subtitle: '→ worker · allowed'),
          SettingsRow(title: 'telemetry.batch', subtitle: '→ bg worker · fire-and-forget'),
        ]),
      ];
}

/// Apps/MCP marketplace: installed plugins, browse, install cards.
class AppsMarketScreen extends StatefulWidget {
  const AppsMarketScreen({super.key});

  @override
  State<AppsMarketScreen> createState() => _AppsMarketScreenState();
}

class _AppsMarketScreenState extends State<AppsMarketScreen> {
  final Set<String> _installed = {'GitHub', 'Slack', 'Notion'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
          ),
          child: Text('Apps / MCP',
              style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Search apps and connectors…',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
              const SectionHeader('INSTALLED'),
              for (final app in ['GitHub', 'Slack', 'Notion'])
                _appCard(app, _iconFor(app), _descFor(app), installed: true),
              const SectionHeader('POPULAR'),
              for (final app in ['Google Drive', 'Linear', 'Figma', 'Jira', '1Password'])
                _appCard(app, _iconFor(app), _descFor(app)),
              const SectionHeader('MCP SERVERS'),
              TitledCard(title: 'Custom servers', children: const [
                SettingsRow(title: 'filesystem-mcp', subtitle: 'Enabled · 4 tools'),
                SettingsRow(title: 'postgres-mcp', subtitle: 'Enabled · 2 tools'),
                SettingsRow(title: '+ Add MCP server', subtitle: 'stdio / SSE'),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _appCard(String name, String emoji, String desc, {bool installed = false}) {
    final isInstalled = installed || _installed.contains(name);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF3E424A)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kSurfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: kText, fontSize: 13.5, fontWeight: FontWeight.w700)),
                Text(desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: kTextDim, fontSize: 11)),
              ],
            ),
          ),
          if (isInstalled)
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: kGreen,
                side: BorderSide(color: kGreen),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Enabled'),
            )
          else
            FilledButton(
              onPressed: () => setState(() => _installed.add(name)),
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Install'),
            ),
        ],
      ),
    );
  }

  String _iconFor(String app) => switch (app) {
        'GitHub' => '🐙',
        'Slack' => '💬',
        'Notion' => '📓',
        'Google Drive' => '📁',
        'Linear' => '📐',
        'Figma' => '🎨',
        'Jira' => '🗺️',
        '1Password' => '🔑',
        _ => '✨',
      };

  String _descFor(String app) => switch (app) {
        'GitHub' => 'Repos, PRs, issues · read & write scopes',
        'Slack' => 'Channels, DMs, threads · send on your behalf',
        'Notion' => 'Pages and databases',
        'Google Drive' => 'Files and folders',
        'Linear' => 'Issues and projects',
        'Figma' => 'Design files and comments',
        'Jira' => 'Tickets and sprints',
        '1Password' => 'Logins vault integration',
        _ => 'Connector',
      };
}
