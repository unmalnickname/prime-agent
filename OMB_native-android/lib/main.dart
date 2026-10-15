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

/// Responsive shell: Discord-style rail (always) + session drawer
/// (side-by-side on wide, overlay on phone) + main view.
///
/// The listenable sits here (inside the route) so state changes rebuild
/// this subtree; a builder above MaterialApp can't reach cached routes.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final showDrawerInline = width >= 900;
        final state = _appState;

        // Discord-style phone layout: the workspace rail lives inside the
        // slide-over drawer next to the session list, not beside the content.
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
              child: Stack(
                children: [
                  // Swipe right to reveal the drawer, swipe left to dismiss —
                  // same gestures as the Discord mobile app.
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      final v = details.primaryVelocity ?? 0;
                      if (v > 250 && !showDrawerInline) {
                        state.setDrawer(true);
                      } else if (v < -250 && !showDrawerInline) {
                        state.setDrawer(false);
                      }
                    },
                    child: Row(
                      children: [
                        if (showDrawerInline) ...[
                          WorkspaceRail(state: state),
                          drawerContent,
                        ],
                        Expanded(child: content),
                        // Side panel on very wide screens, otherwise the panel is the main view.
                        if (width >= 1200 && state.view != ViewKind.chat)
                          SizedBox(width: 380, child: _panelView(state)),
                      ],
                    ),
                  ),
                  // Phone: combined rail + sessions as a slide-over drawer.
                  if (!showDrawerInline && state.drawerOpen) ...[
                    GestureDetector(
                      onTap: () => state.setDrawer(false),
                      onHorizontalDragEnd: (details) {
                        if ((details.primaryVelocity ?? 0) < -250) {
                          state.setDrawer(false);
                        }
                      },
                      child: Container(color: Colors.black54),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        offset: state.drawerOpen ? Offset.zero : const Offset(-1, 0),
                        child: SizedBox(width: 340, child: drawerContent),
                      ),
                    ),
                  ],
                ],
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
