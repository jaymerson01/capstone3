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

  // Sidebar navigation options
  final List<SidebarItem> menuItems = [
  SidebarItem(Icons.analytics_outlined, "Overview Dashboard"),
  SidebarItem(Icons.assignment_late_outlined, "Incident Reports"),
  SidebarItem(Icons.manage_accounts_outlined, "User Management"),
  SidebarItem(Icons.dashboard_customize_outlined, "Incident Categories"),
  SidebarItem(Icons.map_outlined, "Area Management"),
  SidebarItem(Icons.history_outlined, "Admin Audit Logs"),
  SidebarItem(Icons.admin_panel_settings_outlined, "Profile Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    final adminService = AdminDataService();
    final double width = widget.isCollapsed ? 80.0 : 270.0;

    return ListenableBuilder(
      listenable: adminService,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          decoration: const BoxDecoration(
            color: AdminColors.primaryGreen,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Header (User profile avatar and ADMIN text)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: widget.isCollapsed 
                        ? MainAxisAlignment.center 
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ADMIN PORTAL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "ResQ",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 15),

                // Sidebar items list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final bool isSelected = widget.selectedIndex == index;
                      final bool isHovered = hoveredIndex == index;

                      return MouseRegion(
                        onEnter: (_) => setState(() => hoveredIndex = index),
                        onExit: (_) => setState(() => hoveredIndex = -1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Tooltip(
                            message: widget.isCollapsed ? item.title : "",
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.white.withOpacity(0.12)
                                    : isHovered 
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  // Left side selection indicator bar
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 4,
                                    height: isSelected ? 24 : 0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      minLeadingWidth: widget.isCollapsed ? 0 : 25,
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: widget.isCollapsed ? 12 : 16,
                                        vertical: 2,
                                      ),
                                      leading: Icon(
                                        item.icon,
                                        color: isSelected ? Colors.white : Colors.white60,
                                        size: 22,
                                      ),
                                      title: widget.isCollapsed 
                                          ? null 
                                          : Text(
                                              item.title,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.white60,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                      onTap: () => widget.onItemSelected(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Logout button (Red matching mock reference)
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => hoveredIndex = 99),
                    onExit: (_) => setState(() => hoveredIndex = -1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: hoveredIndex == 99
                            ? AdminColors.dangerRed
                            : AdminColors.dangerRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hoveredIndex == 99 ? Colors.transparent : AdminColors.dangerRed.withOpacity(0.3),
                        ),
                      ),
                      child: ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: widget.isCollapsed ? 12 : 16,
                          vertical: 2,
                        ),
                        leading: Icon(
                          Icons.logout,
                          color: hoveredIndex == 99 ? Colors.white : AdminColors.dangerRed,
                          size: 20,
                        ),
                        title: widget.isCollapsed 
                            ? null 
                            : Text(
                                "Logout Portal",
                                style: TextStyle(
                                  color: hoveredIndex == 99 ? Colors.white : AdminColors.dangerRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                        onTap: widget.onLogout,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String title;

  SidebarItem(this.icon, this.title);
}

