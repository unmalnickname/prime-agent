import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../theme_palette.dart';
import 'common.dart';

/// Theme picker: curated skins + topic-generated themes ("Give me a theme
/// based on …"). The whole app re-skins live through [themeController].
class ThemePicker extends StatefulWidget {
  const ThemePicker({super.key});

  @override
  State<ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  final _topicController = TextEditingController();

  static const _topicIdeas = [
    'Weyland-Yutani Corporation',
    'Cyberpunk 2077',
    'Blade Runner',
    'The Expanse',
    'Star Trek LCARS',
    'Stargate SG-1',
    'Dune',
    'Tron',
    'Neon Tokyo',
    'Deep Sea',
    'Synthwave',
    'Oxygen Not Included',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = themeController.palette;
    return Container(
      color: kDrawerBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF3A3D44))),
            ),
            child: Text('Theme studio',
                style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Live preview swatch of the active palette.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kAccent.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              themeController.topic == null
                                  ? active.name
                                  : '${active.name} · generated',
                              style: TextStyle(
                                  color: kText, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ),
                          StatusChip(label: 'live', color: kAccent),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final c in [
                            active.railBg,
                            active.drawerBg,
                            active.contentBg,
                            active.surface,
                            active.surfaceAlt,
                            active.accent,
                            active.text,
                            active.textDim,
                          ])
                            Expanded(
                              child: Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  color: c,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF4A4E57)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SectionHeader('GENERATE FROM A TOPIC'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _topicController,
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            themeController.setTopic(v);
                            setState(() {});
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'e.g. Weyland-Yutani Corporation',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(
                      label: 'Generate',
                      onTap: () {
                        final v = _topicController.text.trim();
                        if (v.isNotEmpty) {
                          themeController.setTopic(v);
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final idea in _topicIdeas)
                      ActionChip(
                        label: Text(idea),
                        onPressed: () {
                          _topicController.text = idea;
                          themeController.setTopic(idea);
                          setState(() {});
                        },
                      ),
                  ],
                ),
                const SectionHeader('CURATED THEMES'),
                for (final p in kCuratedThemes) _curatedTile(p),
                const SectionHeader('SEMANTIC COLORS'),
                _swatchRow('Status', [
                  ('success', kGreen),
                  ('error', kRed),
                  ('info', kBlue),
                  ('magic', kPurple),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _curatedTile(Palette p) {
    final selected = themeController.topic == null && themeController.palette.name == p.name;
    return GestureDetector(
      onTap: () {
        themeController.setCurated(p);
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? kAccent : const Color(0xFF3E424A),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [p.railBg, p.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(p.name,
                  style: TextStyle(
                      color: kText, fontSize: 13.5, fontWeight: FontWeight.w700)),
            ),
            if (selected) Icon(Icons.check_circle, color: kAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _swatchRow(String label, List<(String, Color)> swatches) => Row(
        children: [
          for (final (name, color) in swatches)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(name, style: TextStyle(color: color, fontSize: 10.5)),
                  ],
                ),
              ),
            ),
        ],
      );
}
