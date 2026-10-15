import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'common.dart';

/// Calendar grid with draggable bot chips and draggable/resizable events,
/// plus the full event editor dialog (repeat rules, cron, overlap policy).
class CalendarGridScreen extends StatefulWidget {
  const CalendarGridScreen({super.key});

  @override
  State<CalendarGridScreen> createState() => _CalendarGridScreenState();
}

class _CalendarGridScreenState extends State<CalendarGridScreen> {
  static const _hours = ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  /// Events keyed by (dayIndex, hourIndex).
  final Map<(int, int), _Event> _events = {
    (0, 1): _Event('Release digest', '🤖', kGreen),
    (0, 3): _Event('Standup call', '📢', kAccent),
    (2, 2): _Event('Integration sweep', '🐧', kBlue),
    (2, 6): _Event('Dashboard watch', '🛰️', kPurple),
    (4, 5): _Event('Deploy gate', '🤖', kRed),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text('Calendar',
                    style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              PrimaryButton(
                label: '+ Event',
                onTap: () => _showEditor(context, null),
              ),
            ],
          ),
        ),
        // Draggable bot list.
        SizedBox(
          height: 62,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final (emoji, name) in [
                ('🤖', 'Maus'),
                ('🐧', 'Pip'),
                ('🛰️', 'Orbit'),
                ('✒️', 'Quill'),
                ('📢', 'war-room'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Draggable<String>(
                    data: name,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _botChip(emoji, name, dragging: true),
                    ),
                    childWhenDragging: Opacity(opacity: 0.4, child: _botChip(emoji, name)),
                    child: _botChip(emoji, name),
                  ),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Drag a bot onto any time slot · tap an event to edit',
              style: TextStyle(color: kTextDim, fontSize: 11)),
        ),
        // Grid.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 52),
                    for (final day in _days)
                      Expanded(
                        child: Center(
                          child: Text(day,
                              style: const TextStyle(
                                  color: kTextDim,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var h = 0; h < _hours.length; h++)
                  Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(_hours[h],
                            style: const TextStyle(color: kTextDim, fontSize: 10.5)),
                      ),
                      for (var d = 0; d < _days.length; d++)
                        Expanded(
                          child: DragTarget<String>(
                            onAcceptWithDetails: (details) {
                              setState(() {
                                _events[(d, h)] = _Event(details.data, '🤖', kAccent);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${details.data} scheduled for ${_days[d]} ${_hours[h]}'),
                                ),
                              );
                            },
                            builder: (context, candidate, rejected) {
                              final ev = _events[(d, h)];
                              final hovered = candidate.isNotEmpty;
                              return GestureDetector(
                                onTap: () => _showEditor(context, ev),
                                child: Container(
                                  height: 58,
                                  margin: const EdgeInsets.all(1.5),
                                  decoration: BoxDecoration(
                                    color: hovered
                                        ? kAccent.withValues(alpha: 0.18)
                                        : ev != null
                                            ? ev.color.withValues(alpha: 0.18)
                                            : kSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: hovered
                                          ? kAccent
                                          : ev != null
                                              ? ev.color.withValues(alpha: 0.5)
                                              : const Color(0xFF3E424A),
                                    ),
                                  ),
                                  child: ev != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(ev.emoji,
                                                  style: const TextStyle(fontSize: 13)),
                                              Text(ev.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: ev.color,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _botChip(String emoji, String name, {bool dragging = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: dragging ? kAccent : kSurfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(name,
                style: TextStyle(
                    color: dragging ? Colors.black : kText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  void _showEditor(BuildContext context, _Event? ev) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _EventEditor(event: ev),
    );
  }
}

class _Event {
  final String name;
  final String emoji;
  final Color color;

  _Event(this.name, this.emoji, this.color);
}

/// Full event editor: Routine vs Call, Bot task vs Team goal, repeat rules
/// with cron preview, stop-if-still-running, overlap policy, attachments.
class _EventEditor extends StatefulWidget {
  final _Event? event;

  const _EventEditor({this.event});

  @override
  State<_EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<_EventEditor> {
  String _type = 'Routine';
  String _scope = 'Bot task';
  String _repeat = 'Weekdays';
  String _overlap = 'Queue';
  bool _runOnStartup = true;
  bool _continuity = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: kDrawerBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.event == null ? 'New event' : 'Edit event',
                      style: const TextStyle(
                          color: kText, fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: kTextDim, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (final t in ['Routine', 'Call'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(t),
                              selected: _type == t,
                              onSelected: (_) => setState(() => _type = t),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final s in ['Bot task', 'Team goal'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(s),
                              selected: _scope == s,
                              onSelected: (_) => setState(() => _scope = s),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const TextField(decoration: InputDecoration(hintText: 'Task description')),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          child: TextField(decoration: InputDecoration(hintText: 'Start 09:00')),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(decoration: InputDecoration(hintText: 'Duration 30 min')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const SectionHeader('REPEAT'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in ['None', 'Interval', 'Daily', 'Weekdays', 'Monthly', 'Yearly', 'Cron'])
                          ChoiceChip(
                            label: Text(r),
                            selected: _repeat == r,
                            onSelected: (_) => setState(() => _repeat = r),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cron: 0 9 * * 1-5 · timezone local',
                              style: TextStyle(
                                  color: kText, fontSize: 12, fontFamily: 'monospace')),
                          SizedBox(height: 4),
                          Text('Next run: Mon 09:00',
                              style: TextStyle(color: kGreen, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SectionHeader('POLICIES'),
                    _setting('Stop if still running', '30 min timeout'),
                    _setting('Overlap policy', _overlap,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final o in ['Queue', 'Skip'])
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ChoiceChip(
                                  label: Text(o),
                                  selected: _overlap == o,
                                  onSelected: (_) => setState(() => _overlap = o),
                                ),
                              ),
                          ],
                        )),
                    _setting('Run on startup', _runOnStartup ? 'On' : 'Off',
                        trailing: Switch(
                          value: _runOnStartup,
                          activeThumbColor: kGreen,
                          onChanged: (v) => setState(() => _runOnStartup = v),
                        )),
                    _setting('Continuity', _continuity ? 'Keep context' : 'Fresh thread',
                        trailing: Switch(
                          value: _continuity,
                          activeThumbColor: kGreen,
                          onChanged: (v) => setState(() => _continuity = v),
                        )),
                    _setting('Results destination', 'war-room'),
                    _setting('Run on', "Bot's setup · Cloud"),
                    _setting('Attachments', '2 files'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.event != null)
                  PrimaryButton(
                    label: 'Delete',
                    filled: false,
                    onTap: () => Navigator.pop(context),
                  ),
                const Spacer(),
                PrimaryButton(
                  label: 'Save event',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _setting(String title, String value, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: kText, fontSize: 13)),
                  if (trailing == null)
                    Text(value, style: const TextStyle(color: kTextDim, fontSize: 11)),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      );
}
