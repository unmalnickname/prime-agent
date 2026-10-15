import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../state.dart';
import 'common.dart';
import 'room_palette_onboarding.dart';

/// Discord-style server rail: workspaces stack vertically on the left edge.
class WorkspaceRail extends StatelessWidget {
  final AppState state;

  const WorkspaceRail({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      color: kRailBg,
      child: Column(
        children: [
          const SizedBox(height: 12),
          _RailButton(
            selected: false,
            onTap: () {},
            child: Icon(Icons.add_comment_outlined, color: kGreen, size: 24),
          ),
          const SizedBox(height: 8),
          const _RailDivider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.workspaces.length,
              itemBuilder: (context, i) {
                final ws = state.workspaces[i];
                final selected = i == state.workspaceIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: _RailButton(
                    selected: selected,
                    unread: state.unreadFor(ws.id),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      state.selectWorkspace(i);
                    },
                    child: Text(ws.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              },
            ),
          ),
          const _RailDivider(),
          _RailButton(
            selected: state.view == ViewKind.routines,
            onTap: () => state.openView(ViewKind.routines),
            child: Icon(Icons.calendar_month_outlined, color: kTextDim, size: 22),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _RailButton(
              selected: state.view == ViewKind.teamMap,
              onTap: () => state.openView(ViewKind.teamMap),
              child: Icon(Icons.hub_outlined, color: kTextDim, size: 22),
            ),
          ),
          _RailButton(
            selected: false,
            onTap: () => _showAppSettings(context),
            child: Icon(Icons.settings_outlined, color: kTextDim, size: 22),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showAppSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/app-settings');
  }
}

class _RailDivider extends StatelessWidget {
  const _RailDivider();

  @override
  Widget build(BuildContext context) => Container(
        height: 2,
        width: 32,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF33363D),
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

class _RailButton extends StatelessWidget {
  final Widget child;
  final bool selected;
  final int unread;
  final VoidCallback onTap;

  const _RailButton({
    required this.child,
    required this.selected,
    required this.onTap,
    this.unread = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 4,
                height: selected ? 36 : 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? kAccent : kSurfaceAlt,
                  borderRadius: BorderRadius.circular(selected ? 16 : 24),
                ),
                child: child,
              ),
            ],
          ),
          if (unread > 0)
            Positioned(
              right: 0,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: kRed,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: kRailBg, width: 2),
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Session list for the active workspace (bots + rooms), Discord channel style.
class SessionDrawer extends StatelessWidget {
  final AppState state;

  const SessionDrawer({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244,
      color: kDrawerBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 12, 14),
              child: Row(
                children: [
                  Text(state.workspace.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.workspace.name,
                      style: TextStyle(
                        color: kText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.unfold_more, color: kTextDim, size: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                const SectionHeader('PINNED'),
                for (final s in state.pinnedSessions) _SessionTile(session: s, state: state),
                const SectionHeader('BOTS'),
                for (final s in state.botSessions(false)) _SessionTile(session: s, state: state),
                const SectionHeader('ROOMS'),
                for (final s in state.botSessions(true)) _SessionTile(session: s, state: state),
                const SectionHeader('TOOLS'),
                _ToolTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Routines',
                  active: state.view == ViewKind.routines,
                  onTap: () => state.openView(ViewKind.routines),
                ),
                _ToolTile(
                  icon: Icons.bolt_outlined,
                  label: 'Triggers',
                  onTap: () => Navigator.of(context).pushNamed('/app-settings'),
                ),
                _ToolTile(
                  icon: Icons.extension_outlined,
                  label: 'Apps / MCP',
                  onTap: () => Navigator.of(context).pushNamed('/app-settings'),
                ),
                _ToolTile(
                  icon: Icons.hub_outlined,
                  label: 'Team map',
                  active: state.view == ViewKind.teamMap,
                  onTap: () => state.openView(ViewKind.teamMap),
                ),
                _ToolTile(
                  icon: Icons.widgets_outlined,
                  label: 'UI kit',
                  active: state.view == ViewKind.uiKit,
                  onTap: () => state.openView(ViewKind.uiKit),
                ),
                _ToolTile(
                  icon: Icons.add_box_outlined,
                  label: 'New bot',
                  active: state.view == ViewKind.newBot,
                  onTap: () => state.openView(ViewKind.newBot),
                ),
                _ToolTile(
                  icon: Icons.call_outlined,
                  label: 'Voice call',
                  active: state.view == ViewKind.voiceCall,
                  onTap: () => state.openView(ViewKind.voiceCall),
                ),
                _ToolTile(
                  icon: Icons.pie_chart_outline,
                  label: 'Usage & spend',
                  active: state.view == ViewKind.usage,
                  onTap: () => state.openView(ViewKind.usage),
                ),
                _ToolTile(
                  icon: Icons.groups_outlined,
                  label: 'Group room',
                  active: state.view == ViewKind.groupRoom,
                  onTap: () => state.openView(ViewKind.groupRoom),
                ),
                _ToolTile(
                  icon: Icons.calendar_view_month_outlined,
                  label: 'Calendar grid',
                  active: state.view == ViewKind.calendarGrid,
                  onTap: () => state.openView(ViewKind.calendarGrid),
                ),
                _ToolTile(
                  icon: Icons.bug_report_outlined,
                  label: 'Inspector',
                  active: state.view == ViewKind.inspector,
                  onTap: () => state.openView(ViewKind.inspector),
                ),
                _ToolTile(
                  icon: Icons.apps_outlined,
                  label: 'Apps / MCP',
                  active: state.view == ViewKind.appsMarket,
                  onTap: () => state.openView(ViewKind.appsMarket),
                ),
                _ToolTile(
                  icon: Icons.rocket_launch_outlined,
                  label: 'Onboarding',
                  active: state.view == ViewKind.onboarding,
                  onTap: () => state.openView(ViewKind.onboarding),
                ),
                _ToolTile(
                  icon: Icons.wifi_off_outlined,
                  label: 'Setup states',
                  active: state.view == ViewKind.setupStates,
                  onTap: () => state.openView(ViewKind.setupStates),
                ),
                _ToolTile(
                  icon: Icons.search,
                  label: 'Command palette',
                  onTap: () => showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (_) => const CommandPalette(),
                  ),
                ),
                _ToolTile(
                  icon: Icons.palette_outlined,
                  label: 'Theme studio',
                  active: state.view == ViewKind.themeStudio,
                  onTap: () => state.openView(ViewKind.themeStudio),
                ),
                _ToolTile(
                  icon: Icons.keyboard_outlined,
                  label: 'Shortcuts',
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const KeyboardShortcuts(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF191B1F),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const BotAvatar(emoji: '🧑‍🚀', size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('you', style: TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('online', style: TextStyle(color: kGreen, fontSize: 10.5)),
                    ],
                  ),
                ),
                _MiniIcon(Icons.mic_none, onTap: () {}),
                _MiniIcon(Icons.headset_mic_outlined, onTap: () {}),
                _MiniIcon(Icons.settings_outlined,
                    onTap: () => Navigator.of(context).pushNamed('/app-settings')),
              ],
            ),
          ),
          // Simple ↔ Advanced master switch
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: GestureDetector(
              onTap: state.toggleAdvanced,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: kSurfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.advancedMode ? Icons.rocket_launch_outlined : Icons.spa_outlined,
                      size: 13,
                      color: state.advancedMode ? kAccent : kTextDim,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.advancedMode ? 'Advanced mode' : 'Simple mode',
                      style: TextStyle(
                        color: state.advancedMode ? kAccent : kTextDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniIcon(this.icon, {required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: kTextDim, size: 18),
        ),
      );
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final AppState state;

  const _SessionTile({required this.session, required this.state});

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text(session.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(session.name,
                      style: TextStyle(
                          color: kText, fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            ListTile(
              dense: true,
              leading: Icon(session.pinned ? Icons.push_pin : Icons.push_pin_outlined, color: kTextDim),
              title: Text(session.pinned ? 'Unpin' : 'Pin'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.notifications_off_outlined, color: kTextDim),
              title: const Text('Snooze'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.done_all, color: kTextDim),
              title: const Text('Mark read'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.edit_outlined, color: kTextDim),
              title: const Text('Edit profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.archive_outlined, color: kRed),
              title: Text('Archive', style: TextStyle(color: kRed)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.delete_outline, color: kRed),
              title: Text('Delete', style: TextStyle(color: kRed)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = session.id == state.sessionId && state.view == ViewKind.chat;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        state.selectSession(session.id);
        if (session.isRoom) state.openView(ViewKind.groupRoom);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showMenu(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kSurfaceAlt : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(session.emoji, style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                session.name,
                style: TextStyle(
                  color: selected ? kText : kTextDim,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (session.status == 'running')
              StatusChip(label: 'RUNNING', color: kGreen)
            else if (session.status == 'waiting')
              StatusChip(label: 'WAITING', color: kAccent)
            else if (session.unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kRed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${session.unread}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: [
              Icon(icon, color: active ? kAccent : kTextDim, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? kText : kTextDim,
                    fontSize: 13.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
