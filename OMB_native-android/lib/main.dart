import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'state.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/chat_screen.dart';
import 'widgets/inspector_apps.dart';
import 'widgets/panels.dart';
import 'widgets/panels_screen.dart';
import 'widgets/rail.dart';
import 'widgets/room_palette_onboarding.dart';
import 'widgets/uikit.dart';
import 'widgets/wizard_call_usage.dart';

final _appState = AppState();

/// Deep links for the mockup: ?view=computer|botSettings|activity|routines|teamMap
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Native Android chrome: dark system bars matching the rail.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF141518),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF141518),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  final params = Uri.base.queryParameters;
  final viewName = params['view'];
  if (viewName != null) {
    for (final kind in ViewKind.values) {
      if (kind.name == viewName) {
        _appState.openView(kind);
        break;
      }
    }
  }
  runApp(const OmbApp());
}

class OmbApp extends StatelessWidget {
  const OmbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenMausBot Mobile',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routes: {
        '/': (_) => const AppShell(),
        '/app-settings': (_) => const AppSettingsScreen(),
      },
    );
  }
}

/// Responsive shell.
///
/// Phone: Discord's OverlappingPanels model — the workspace rail + session
/// drawer form a stationary back layer, and the content is the TOP layer that
/// slides right (and shrinks slightly) over them, tracking the finger. New
/// sessions therefore always come up on top of the rail/drawer, and the rail
/// is only reachable in the exposed gap. Wide screens keep rail + sessions
/// inline beside the content.
///
/// The listenable sits here (inside the route) so state changes rebuild
/// this subtree; a builder above MaterialApp can't reach cached routes.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  static const _drawerWidth = 340.0;

  late final AnimationController _anim;
  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: _appState.drawerOpen ? 1 : 0,
    );
    _appState.addListener(_syncDrawer);
  }

  @override
  void dispose() {
    _appState.removeListener(_syncDrawer);
    _anim.dispose();
    super.dispose();
  }

  void _syncDrawer() {
    final target = _appState.drawerOpen ? 1.0 : 0.0;
    if ((_anim.value - target).abs() > 0.001 && !_anim.isAnimating) {
      _anim.animateTo(target, curve: Curves.easeOutCubic);
    }
  }

  /// One light tick per open/close threshold crossing, like Discord.
  void _thresholdHaptic(double value) {
    final past = value >= 0.5;
    if (past != _hapticFired) {
      _hapticFired = past;
      HapticFeedback.selectionClick();
    }
  }

  void _dragUpdate(double dx) {
    final next = (_anim.value + dx / _drawerWidth).clamp(0.0, 1.0);
    _anim.value = next;
    _thresholdHaptic(next);
  }

  void _dragEnd(double velocity) {
    final open = velocity > 250
        ? true
        : velocity < -250
            ? false
            : _anim.value >= 0.5;
    _appState.setDrawer(open);
    // _syncDrawer (via listener) animates to the settled position.
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final showDrawerInline = width >= 900;
        final state = _appState;

        final drawerContent = showDrawerInline
            ? SessionDrawer(state: state)
            : Row(
                children: [
                  WorkspaceRail(state: state),
                  Expanded(child: SessionDrawer(state: state)),
                ],
              );
        final content = _mainView(state);

        return PopScope(
          // Android back button: close the drawer first, then leave a panel.
          canPop: !state.drawerOpen && state.view == ViewKind.chat,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (state.drawerOpen) {
              state.setDrawer(false);
            } else {
              state.openView(ViewKind.chat);
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: showDrawerInline
                  ? Row(
                      children: [
                        WorkspaceRail(state: state),
                        drawerContent,
                        Expanded(child: content),
                        // Side panel on very wide screens.
                        if (width >= 1200 && state.view != ViewKind.chat)
                          SizedBox(width: 380, child: _panelView(state)),
                      ],
                    )
                  : _PhonePanels(
                      anim: _anim,
                      drawerWidth: _drawerWidth,
                      backLayer: drawerContent,
                      frontLayer: content,
                      onDragUpdate: _dragUpdate,
                      onDragEnd: _dragEnd,
                      onDismiss: () => state.setDrawer(false),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _mainView(AppState state) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: switch (state.view) {
          ViewKind.chat => ChatScreen(state: state, key: const ValueKey('chat')),
          ViewKind.botSettings =>
            BotSettingsPanel(state: state, key: const ValueKey('settings')),
          ViewKind.computer =>
            ComputerPanel(state: state, key: const ValueKey('computer')),
          ViewKind.activity =>
            ActivityPanel(state: state, key: const ValueKey('activity')),
          ViewKind.routines =>
            RoutinesScreen(state: state, key: const ValueKey('routines')),
          ViewKind.teamMap =>
            TeamMapScreen(state: state, key: const ValueKey('teammap')),
          ViewKind.uiKit =>
            const UiKitScreen(key: ValueKey('uikit')),
          ViewKind.newBot =>
            const NewBotWizard(key: ValueKey('newbot')),
          ViewKind.voiceCall =>
            VoiceCallOverlay(state: state, key: const ValueKey('call')),
          ViewKind.usage =>
            UsageScreen(state: state, key: const ValueKey('usage')),
          ViewKind.groupRoom =>
            GroupRoomScreen(state: state, key: const ValueKey('room')),
          ViewKind.calendarGrid =>
            const CalendarGridScreen(key: ValueKey('cal')),
          ViewKind.inspector =>
            InspectorScreen(state: state, key: const ValueKey('inspector')),
          ViewKind.appsMarket =>
            const AppsMarketScreen(key: ValueKey('apps')),
          ViewKind.onboarding =>
            const OnboardingScreen(key: ValueKey('onboard')),
          ViewKind.setupStates =>
            const SetupStatesScreen(key: ValueKey('setup')),
        },
      );

  Widget _panelView(AppState state) => switch (state.view) {
        ViewKind.botSettings => BotSettingsPanel(state: state),
        ViewKind.computer => ComputerPanel(state: state),
        ViewKind.activity => ActivityPanel(state: state),
        _ => const SizedBox.shrink(),
      };
}

/// Discord's OverlappingPanels on phones: [backLayer] (rail + sessions) is
/// painted first and never moves; [frontLayer] (the content) is painted on
/// top and slides right over it with a slight scale-down, tracking the finger.
/// New sessions/threads therefore always stack above the rail, and the rail
/// sits in the revealed gap behind.
class _PhonePanels extends StatelessWidget {
  final Animation<double> anim;
  final double drawerWidth;
  final Widget backLayer;
  final Widget frontLayer;
  final void Function(double dx) onDragUpdate;
  final void Function(double velocity) onDragEnd;
  final VoidCallback onDismiss;

  const _PhonePanels({
    required this.anim,
    required this.drawerWidth,
    required this.backLayer,
    required this.frontLayer,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) => onDragUpdate(d.delta.dx),
      onHorizontalDragEnd: (d) => onDragEnd(d.primaryVelocity ?? 0),
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, _) {
          final t = anim.value;
          return Stack(
            children: [
              // Back layer: stationary rail + workspace/session list.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: drawerWidth,
                child: backLayer,
              ),
              // Front layer: the content, sliding over the back layer.
              Transform.translate(
                offset: Offset(t * drawerWidth, 0),
                child: Transform.scale(
                  scale: 1 - t * 0.06,
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kContentBg,
                      borderRadius: BorderRadius.circular(t * 18),
                      boxShadow: t > 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45 * t),
                                blurRadius: 24 * t,
                                offset: Offset(-6 * t, 0),
                              ),
                            ]
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: frontLayer,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
