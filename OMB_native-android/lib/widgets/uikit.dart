import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'common.dart';

/// Interactive component library: every reusable piece the full product
/// needs, grouped by category, so screens can be assembled from one set.
class UiKitScreen extends StatefulWidget {
  const UiKitScreen({super.key});

  @override
  State<UiKitScreen> createState() => _UiKitScreenState();
}

class _UiKitScreenState extends State<UiKitScreen> {
  bool _switchOn = true;
  bool _toggle2 = false;
  double _slider = 0.4;
  int _tab = 0;
  int _nav = 0;
  int _rating = 3;
  String _segment = 'Ask';
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _KitHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _category('Buttons'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  const PrimaryButton(label: 'Primary'),
                  const PrimaryButton(label: 'Secondary', filled: false),
                  FilledButton.tonal(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: kGreen.withValues(alpha: 0.2),
                      foregroundColor: kGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Success'),
                  ),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: kRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Danger'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Text button')),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Icon button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kText,
                      side: const BorderSide(color: Color(0xFF4A4E57)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const _Fab(),
                ],
              ),
              _category('Chips & badges'),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        StatusChip(label: 'running', color: kAccent),
                        StatusChip(label: 'completed', color: kGreen),
                        StatusChip(label: 'failed', color: kRed),
                        StatusChip(label: 'waiting', color: kBlue),
                        StatusChip(label: 'draft', color: kPurple),
                        _GhostChip('Filter'),
                        _GhostChip('Sort'),
                        _GhostChip('Batch'),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _fav = !_fav),
                    icon: Icon(
                      _fav ? Icons.star : Icons.star_border,
                      color: _fav ? kAccent : kTextDim,
                    ),
                  ),
                ],
              ),
              _category('Cards'),
              Row(
                children: [
                  Expanded(
                    child: TitledCard(title: 'Metric card', children: const [
                      Text('\$4.20', style: TextStyle(color: kAccent, fontSize: 26, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('spend this month · +12%', style: TextStyle(color: kTextDim, fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TitledCard(title: 'Status card', children: const [
                      Row(children: [
                        Icon(Icons.circle, color: kGreen, size: 10),
                        SizedBox(width: 8),
                        Text('All systems go', style: TextStyle(color: kText, fontSize: 13)),
                      ]),
                      SizedBox(height: 8),
                      Text('Last checked 2m ago', style: TextStyle(color: kTextDim, fontSize: 11)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TitledCard(title: 'List card', children: const [
                SettingsRow(title: 'First item', subtitle: 'with subtitle'),
                SettingsRow(title: 'Second item', subtitle: 'with trailing'),
                SettingsRow(title: 'Third item', subtitle: 'with icon'),
              ]),
              _category('Form controls'),
              const TextField(decoration: InputDecoration(hintText: 'Text input')),
              const SizedBox(height: 10),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password input'),
              ),
              const SizedBox(height: 10),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(hintText: 'Multiline input'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: _switchOn,
                    activeThumbColor: kGreen,
                    onChanged: (v) => setState(() => _switchOn = v),
                  ),
                  const Text('Enable feature', style: TextStyle(color: kText, fontSize: 13)),
                  const SizedBox(width: 16),
                  Checkbox(
                    value: _toggle2,
                    activeColor: kAccent,
                    onChanged: (v) => setState(() => _toggle2 = v ?? false),
                  ),
                  const Text('Check me', style: TextStyle(color: kText, fontSize: 13)),
                ],
              ),
              Slider(
                value: _slider,
                activeColor: kAccent,
                onChanged: (v) => setState(() => _slider = v),
              ),
              Row(
                children: [
                  for (final label in ['Ask', 'Edits', 'Auto', 'Full'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _segment == label,
                        onSelected: (_) => setState(() => _segment = label),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search…',
                        prefixIcon: Icon(Icons.search, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, color: kTextDim),
                  ),
                ],
              ),
              _category('Progress & feedback'),
              const LinearProgressIndicator(
                value: 0.65,
                color: kAccent,
                backgroundColor: kSurfaceAlt,
                minHeight: 6,
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: kAccent),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text('Loading state', style: TextStyle(color: kTextDim, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 12),
              _banner('Trial ends in 12 days', 'Upgrade to keep cloud runs going', kAccent, Icons.star),
              const SizedBox(height: 8),
              _banner('Update available', 'Restart to apply version 2.4', kBlue, Icons.system_update),
              const SizedBox(height: 8),
              _banner('Wayland not supported', 'Screen control requires Xorg', kRed, Icons.warning),
              const SizedBox(height: 12),
              const _EmptyState(),
              _category('Tabs & navigation'),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _tab == i ? kAccent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          ['Overview', 'Activity', 'Settings'][i],
                          style: TextStyle(
                            color: _tab == i ? kText : kTextDim,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('Tab ${i + 1}'),
                        selected: _tab == i,
                        onSelected: (_) => setState(() => _tab = i),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < 5; i++)
                      GestureDetector(
                        onTap: () => setState(() => _nav = i),
                        child: Column(
                          children: [
                            Icon(
                              [
                                Icons.chat_bubble_outline,
                                Icons.people_outline,
                                Icons.calendar_month_outlined,
                                Icons.hub_outlined,
                                Icons.person_outline,
                              ][i],
                              color: _nav == i ? kAccent : kTextDim,
                              size: 22,
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _nav == i ? kAccent : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              _category('Data display'),
              Row(
                children: [
                  _spark(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        for (final (label, value) in [
                          ('Tokens', '128k'),
                          ('Cost', '\$4.20'),
                          ('Turns', '312'),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(label, style: const TextStyle(color: kTextDim, fontSize: 12)),
                                Text(value, style: const TextStyle(color: kText, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _table(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: kAccent,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _category(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kAccent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider(color: Color(0xFF3A3D44))),
          ],
        ),
      );

  Widget _banner(String title, String sub, Color color, IconData icon) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(color: kTextDim, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.close, color: kTextDim, size: 16),
          ],
        ),
      );

  Widget _spark() => SizedBox(
        width: 120,
        height: 48,
        child: CustomPaint(painter: _SparkPainter()),
      );

  Widget _table() => Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _row('Bot', 'Turns', 'Cost', header: true),
            _row('Maus', '120', '\$2.10'),
            _row('Pip', '88', '\$1.40'),
            _row('Orbit', '104', '\$0.70'),
          ],
        ),
      );

  Widget _row(String a, String b, String c, {bool header = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          border: const Border(bottom: BorderSide(color: Color(0xFF34373D))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(a, style: TextStyle(color: header ? kTextDim : kText, fontSize: 12, fontWeight: header ? FontWeight.w700 : FontWeight.w500)),
            ),
            Expanded(
              child: Text(b, style: TextStyle(color: header ? kTextDim : kText, fontSize: 12)),
            ),
            Expanded(
              child: Text(c, style: TextStyle(color: header ? kTextDim : kText, fontSize: 12)),
            ),
          ],
        ),
      );
}

class _KitHeader extends StatelessWidget {
  const _KitHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Component Library',
            style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Every building block for the full product UI',
            style: TextStyle(color: kTextDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab();

  @override
  Widget build(BuildContext context) => FloatingActionButton.small(
        onPressed: () {},
        backgroundColor: kAccent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      );
}

class _GhostChip extends StatelessWidget {
  final String label;

  const _GhostChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4A4E57)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: const TextStyle(color: kTextDim, fontSize: 12)),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: kSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3E424A)),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, color: kTextDim, size: 38),
            SizedBox(height: 10),
            Text('Nothing here yet', style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('New items will show up here', style: TextStyle(color: kTextDim, fontSize: 12)),
            SizedBox(height: 14),
            PrimaryButton(label: 'Get started'),
          ],
        ),
      );
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    final pts = [0.2, 0.5, 0.35, 0.7, 0.55, 0.9, 0.75, 0.6];
    for (var i = 0; i < pts.length; i++) {
      final x = i * (size.width / (pts.length - 1));
      final y = size.height * (1 - pts[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
