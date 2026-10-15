import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omb_native/main.dart';
import 'package:omb_native/theme_palette.dart';

void main() {
  /// Tall surface so the whole transcript builds (ListView only builds
  /// what is visible).
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('app shell builds', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const OmbApp());
    expect(find.text('Maus'), findsWidgets);
  });

  testWidgets('approval card resolves and bot follows up', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const OmbApp());
    expect(find.text('Approval needed'), findsOneWidget);

    await tester.tap(find.text('Allow once'));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Approval needed'), findsNothing);
    expect(find.textContaining('Approved'), findsOneWidget);
    expect(find.textContaining('Command completed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('composer queues while a turn is running', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const OmbApp());
    // Running turn, nothing pending yet → the button offers "steer".
    expect(find.text('steer'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'summarize for Slack');
    await tester.tap(find.text('steer'));
    await tester.pump();

    expect(find.textContaining('summarize for Slack'), findsOneWidget);
    // Message now queued → the button relabels to "queue".
    expect(find.text('queue'), findsOneWidget);

    await tester.tap(find.text('steer')); // steer chip: instant injection
    await tester.pump();
    expect(find.textContaining('Steered mid-turn'), findsOneWidget);
  });

  testWidgets('question card answers inline', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const OmbApp());
    await tester.tap(find.text('Hide it from notes'));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Bot needs your input'), findsNothing);
    expect(find.textContaining('You answered'), findsOneWidget);
  });

  test('topic themes generate deterministically and distinctly', () {
    final a = Palette.fromTopic('Weyland-Yutani Corporation');
    final b = Palette.fromTopic('Weyland-Yutani Corporation');
    final c = Palette.fromTopic('Cyberpunk 2077');

    expect(a.accent, b.accent); // same topic → same palette
    expect(a.accent, isNot(c.accent)); // different topics → different hues
    expect(a.name, 'Weyland-Yutani Corporation');
  });

  test('theme controller swaps palettes and notifies', () {
    final c = ThemeController();
    var notified = 0;
    c.addListener(() => notified++);

    c.setCurated(kWeylandYutaniPalette);
    expect(c.palette.name, 'Weyland-Yutani');
    expect(c.topic, isNull);

    c.setTopic('Dune');
    expect(c.topic, 'Dune');
    expect(c.palette.name, 'Dune');
    expect(notified, 2);
  });
}
