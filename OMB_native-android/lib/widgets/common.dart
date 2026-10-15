import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Shared atoms for the mockup: avatars, chips, section headers, panels.
class BotAvatar extends StatelessWidget {
  final String emoji;
  final double size;
  final bool ring;
  final Color? ringColor;

  const BotAvatar({
    super.key,
    required this.emoji,
    this.size = 40,
    this.ring = false,
    this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final ringPaint = ringColor ?? kGreen;
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A4238), Color(0xFF2E2B26)],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
    if (!ring) return avatar;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringPaint, width: 2),
      ),
      child: avatar,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String label;

  const SectionHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          label,
          style: TextStyle(
            color: kTextDim,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      );
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class TitledCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const TitledCard({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3E424A)),
        ),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: kText,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const PrimaryButton({super.key, required this.label, this.onTap, this.filled = true});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: filled
            ? FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(label),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kText,
                  side: const BorderSide(color: Color(0xFF4A4E57)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(label),
              ),
      );
}

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: kText, fontSize: 14)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TextStyle(color: kTextDim, fontSize: 11.5),
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
              if (trailing == null)
                Icon(Icons.chevron_right, color: kTextDim, size: 18),
            ],
          ),
        ),
      );
}
