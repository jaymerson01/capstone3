import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

class AdminSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onLogout,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  int hoveredIndex = -1;

  final List<SidebarItem> menuItems = [
    SidebarItem(Icons.dashboard_outlined, "Overview Dashboard"),
    SidebarItem(Icons.map_outlined, "Tactical Dispatch Map"),
    SidebarItem(Icons.description_outlined, "Incident Reports"),
    SidebarItem(Icons.bar_chart_rounded, "Reports & Analytics"),
    SidebarItem(Icons.people_alt_outlined, "Citizen Directory"),
    SidebarItem(Icons.shield_outlined, "Admin Audit Logs"),
    SidebarItem(Icons.person_outline_rounded, "Profile Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    final double width = widget.isCollapsed ? 80.0 : 270.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
          // Labels show only when there is room, so nothing overflows while
          // the sidebar animates between its two widths.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 180;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SidebarBrand(compact: compact),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: menuItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return _SidebarTile(
                          icon: item.icon,
                          label: item.title,
                          compact: compact,
                          selected: widget.selectedIndex == index,
                          hovered: hoveredIndex == index,
                          onHover: (on) =>
                              setState(() => hoveredIndex = on ? index : -1),
                          onTap: () => widget.onItemSelected(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SidebarTile(
                    icon: Icons.logout_rounded,
                    label: "Logout Portal",
                    compact: compact,
                    selected: false,
                    danger: true,
                    hovered: hoveredIndex == 99,
                    onHover: (on) =>
                        setState(() => hoveredIndex = on ? 99 : -1),
                    onTap: widget.onLogout,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Logo, app name and the cyan "ADMIN PORTAL" label.
class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    // The logo is a full-bleed square; the tile rounds its corners.
    final logo = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AdminColors.primary,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.security, color: Colors.white, size: 22);
          },
        ),
      ),
    );

    if (compact) return Center(child: logo);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          logo,
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "RESQ",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AdminColors.textStrong,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    height: 1.2,
                  ),
                ),
                Text(
                  "ADMIN PORTAL",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AdminColors.cyanSoft,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One sidebar row. The selected row gets a blue wash and a cyan edge;
/// [danger] is the red-outlined logout row.
class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.compact,
    required this.selected,
    required this.hovered,
    required this.onHover,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool selected;
  final bool hovered;
  final bool danger;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = danger
        ? (hovered ? AdminColors.dangerPale : AdminColors.dangerText)
        : (selected || hovered)
        ? AdminColors.textStrong
        : AdminColors.textSoft;

    final Color? fill = selected || !hovered
        ? null
        : danger
        ? AdminColors.danger.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.06);

    final content = Row(
      mainAxisAlignment: compact
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Icon(icon, color: foreground, size: 20),
        if (!compact) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 14,
                fontWeight: selected
                    ? FontWeight.w800
                    : danger
                    ? FontWeight.w700
                    : FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 46,
      decoration: BoxDecoration(
        color: fill,
        gradient: selected ? AdminColors.navActiveGradient : null,
        borderRadius: BorderRadius.circular(14),
        border: danger
            ? Border.all(
                color: AdminColors.dangerSoft.withValues(
                  alpha: hovered ? 0.55 : 0.3,
                ),
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            onHover: onHover,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14),
                    child: content,
                  ),
                ),
                if (selected)
                  const Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 3,
                      child: ColoredBox(color: AdminColors.cyan),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (compact) tile = Tooltip(message: label, child: tile);

    return Semantics(button: true, selected: selected, child: tile);
  }
}

class SidebarItem {
  final IconData icon;
  final String title;

  SidebarItem(this.icon, this.title);
}
