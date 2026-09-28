import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const NavItem({required this.icon, required this.selectedIcon, required this.label});
}

/// A floating, pill-indicator bottom nav bar — same 5 destinations as a
/// stock Material [NavigationBar], but with a soft shadow and a selected
/// icon that rides a sliding rounded highlight instead of a flat static
/// bar (the single most recognizable "default Flutter" tell).
class AnimatedNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavItem> items;

  const AnimatedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.colors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavButton(
                item: items[i],
                selected: i == selectedIndex,
                onTap: () => onDestinationSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.primary : context.colors.onSurface.withValues(alpha: 0.55);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? context.colors.primary.withValues(alpha: context.isDark ? 0.22 : 0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(selected ? item.selectedIcon : item.icon, color: color, size: 22)
                  .animate(target: selected ? 1 : 0)
                  .scaleXY(begin: 1.0, end: 1.15, curve: Curves.easeOutBack, duration: 260.ms),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(fontSize: 10.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: color),
              // One line always: six tabs on a narrow phone would otherwise
              // wrap the longest label ("Recommend") mid-word.
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(item.label, maxLines: 1, softWrap: false)),
            ),
          ],
        ),
      ),
    );
  }
}
