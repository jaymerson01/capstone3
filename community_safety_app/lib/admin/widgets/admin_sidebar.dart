import 'package:flutter/material.dart';
import '../constants/admin_colors.dart';
import '../services/admin_data_service.dart';

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
    SidebarItem(Icons.analytics_outlined, Icons.analytics, "Overview Dashboard"),
    SidebarItem(Icons.assignment_late_outlined, Icons.assignment_late, "Incident Reports"),
    SidebarItem(Icons.manage_accounts_outlined, Icons.manage_accounts, "User Management"),
    SidebarItem(Icons.dashboard_customize_outlined, Icons.dashboard_customize, "Categories"),
    SidebarItem(Icons.map_outlined, Icons.map, "Area Management"),
    SidebarItem(Icons.history_outlined, Icons.history, "Audit Logs"),
    SidebarItem(Icons.admin_panel_settings_outlined, Icons.admin_panel_settings, "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    final adminService = AdminDataService();
    final double width = widget.isCollapsed ? 72.0 : 260.0;

    return ListenableBuilder(
      listenable: adminService,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF060D1A), Color(0xFF0A1628)],
            ),
            border: const Border(
              right: BorderSide(color: Color(0xFF1E2D4A), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: widget.isCollapsed ? 12 : 20,
                  ),
                  child: Row(
                    mainAxisAlignment: widget.isCollapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A84FF).withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF0A84FF),
                                child: const Icon(Icons.security,
                                    color: Colors.white, size: 22),
                              );
                            },
                          ),
                        ),
                      ),
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [Color(0xFF00D4FF), Color(0xFF0A84FF)],
                                ).createShader(bounds),
                                blendMode: BlendMode.srcIn,
                                child: const Text(
                                  "RESQ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const Text(
                                "COMMAND CENTER",
                                style: TextStyle(
                                  color: Color(0xFF7B8DB0),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Container(
                  height: 1,
                  color: const Color(0xFF1E2D4A),
                ),
                const SizedBox(height: 12),

                // ── Menu Items ───────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final bool isSelected = widget.selectedIndex == index;
                      final bool isHov = hoveredIndex == index;

                      return MouseRegion(
                        onEnter: (_) => setState(() => hoveredIndex = index),
                        onExit: (_) => setState(() => hoveredIndex = -1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.isCollapsed ? 10 : 12,
                            vertical: 3,
                          ),
                          child: Tooltip(
                            message: widget.isCollapsed ? item.title : "",
                            child: GestureDetector(
                              onTap: () => widget.onItemSelected(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: EdgeInsets.symmetric(
                                  horizontal: widget.isCollapsed ? 4 : 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0A84FF).withValues(alpha: 0.15)
                                      : isHov
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0A84FF).withValues(alpha: 0.35)
                                        : Colors.transparent,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0A84FF)
                                                .withValues(alpha: 0.2),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    // Selection indicator
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: isSelected ? 3 : 0,
                                      height: 20,
                                      margin: EdgeInsets.only(
                                          right: isSelected ? 10 : 0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A84FF),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0A84FF)
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isSelected ? item.iconFilled : item.iconOutlined,
                                      color: isSelected
                                          ? const Color(0xFF0A84FF)
                                          : isHov
                                              ? const Color(0xFFE8F0FE)
                                              : const Color(0xFF7B8DB0),
                                      size: 20,
                                    ),
                                    if (!widget.isCollapsed) ...[
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF0A84FF)
                                                : isHov
                                                    ? const Color(0xFFE8F0FE)
                                                    : const Color(0xFF7B8DB0),
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF0A84FF),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(height: 1, color: const Color(0xFF1E2D4A)),
                const SizedBox(height: 10),

                // ── Logout Button ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => hoveredIndex = 99),
                    onExit: (_) => setState(() => hoveredIndex = -1),
                    child: GestureDetector(
                      onTap: widget.onLogout,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isCollapsed ? 12 : 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: hoveredIndex == 99
                              ? const Color(0xFFFF3B30).withValues(alpha: 0.2)
                              : const Color(0xFFFF3B30).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: widget.isCollapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.logout_rounded,
                                color: Color(0xFFFF3B30), size: 18),
                            if (!widget.isCollapsed) ...[
                              const SizedBox(width: 12),
                              const Text(
                                "Logout Portal",
                                style: TextStyle(
                                  color: Color(0xFFFF3B30),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SidebarItem {
  final IconData iconOutlined;
  final IconData iconFilled;
  final String title;
  SidebarItem(this.iconOutlined, this.iconFilled, this.title);
}