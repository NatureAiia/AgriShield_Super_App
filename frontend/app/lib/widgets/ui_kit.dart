import 'package:flutter/material.dart';
import '../theme.dart';

/// Round, bordered icon button used in headers (back, theme toggle, bell).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool onImage; // translucent style for use over illustrations

  const CircleIconButton({super.key, required this.icon, this.onPressed, this.tooltip, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    final bg = onImage ? Colors.white.withValues(alpha: 0.22) : context.colors.surface;
    final fg = onImage ? Colors.white : context.colors.onSurface;
    final btn = Material(
      color: bg,
      shape: CircleBorder(
        side: BorderSide(color: onImage ? Colors.white.withValues(alpha: 0.3) : context.colors.outline),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
            child: Icon(icon, key: ValueKey(icon), size: 20, color: fg),
          ),
        ),
      ),
    );
    final wrapped = DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: onImage ? null : context.softShadow),
      child: btn,
    );
    return tooltip == null ? wrapped : Tooltip(message: tooltip!, child: wrapped);
  }
}

/// Light ⇄ dark toggle — sun in dark mode, moon in light mode.
class ThemeToggleButton extends StatelessWidget {
  final VoidCallback onToggle;
  final bool onImage;
  const ThemeToggleButton({super.key, required this.onToggle, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      icon: context.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      tooltip: context.isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: onToggle,
      onImage: onImage,
    );
  }
}

enum ChipTone { leaf, sun, sky }

extension ChipToneColors on ChipTone {
  Color bg(BuildContext c) => switch (this) {
        ChipTone.leaf => c.palette.leafBg,
        ChipTone.sun => c.palette.sunBg,
        ChipTone.sky => c.palette.skyBg,
      };
  Color ink(BuildContext c) => switch (this) {
        ChipTone.leaf => c.palette.leafInk,
        ChipTone.sun => c.palette.sunInk,
        ChipTone.sky => c.palette.skyInk,
      };
}

/// Tinted glass stat card that sits on top of a hero illustration
/// (Soil Condition / Weather / Air Quality in the design).
class HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ChipTone tone;

  const HeroStat({super.key, required this.label, required this.value, required this.icon, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: tone.bg(context).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: context.palette.muted)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: context.colors.onSurface)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 18, color: tone.ink(context)),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your services" / "Instant actions" style section heading.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailing;
  const SectionTitle(this.title, {super.key, this.trailing, this.onTrailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailing,
              child: Text(trailing!, style: TextStyle(fontSize: 12, color: context.palette.muted)),
            ),
        ],
      ),
    );
  }
}

/// Image card with a badge — the "Choose Your Farm" cards in the design.
class ServiceCard extends StatelessWidget {
  final Widget art;
  final String badge;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.art,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.colors.outline),
        boxShadow: context.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 92,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        art,
                        Positioned(top: 8, left: 8, child: GlassBadge(badge)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: context.palette.muted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBadge extends StatelessWidget {
  final String text;
  const GlassBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: context.colors.onSurface)),
    );
  }
}

/// One row of the "Instant Actions" list: tinted icon tile, title,
/// subtitle and a chevron.
class ActionRow extends StatelessWidget {
  final IconData icon;
  final ChipTone tone;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tone = ChipTone.leaf,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: tone.bg(context), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 20, color: tone.ink(context)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: context.palette.muted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.palette.muted),
          ],
        ),
      ),
    );
  }
}

/// Rounded white group that holds [ActionRow]s with dividers between.
class ActionList extends StatelessWidget {
  final List<Widget> children;
  const ActionList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(Divider(height: 1, color: context.colors.outline));
      rows.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        border: Border.all(color: context.colors.outline),
        boxShadow: context.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(color: Colors.transparent, child: Column(children: rows)),
    );
  }
}
