import 'package:flutter/material.dart';
import '../theme.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const NavItem({required this.icon, required this.selectedIcon, required this.label});
}

/// Floating pill bottom nav: the selected tab grows into a filled green
/// pill with its label, the others stay as quiet icons — same pattern as
/// the design mockups and the web app.
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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
          border: Border.all(color: context.colors.outline),
          boxShadow: [
            BoxShadow(
              color: context.isDark ? Colors.black.withValues(alpha: 0.45) : const Color(0xFF1F4D37).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _NavButton(
                item: items[i],
                selected: i == selectedIndex,
                onTap: () => onDestinationSelected(i),
              ),
          ],
        ),
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
    final fg = selected ? context.colors.onPrimary : context.palette.muted;
    return Expanded(
      flex: selected ? 5 : 2,
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            height: 48,
            decoration: BoxDecoration(
              color: selected ? context.colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? item.selectedIcon : item.icon, color: fg, size: 22),
                if (selected) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
