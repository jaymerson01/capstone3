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
    SidebarItem(Icons.dashboard_outlined, "Overview Dashboard"),
    SidebarItem(Icons.warning_amber_outlined, "Incident Reports"),
    SidebarItem(Icons.people_outline, "User Management"),
    SidebarItem(Icons.category_outlined, "Incident Categories"),
    SidebarItem(Icons.map_outlined, "Area Management"),
    SidebarItem(Icons.settings_outlined, "Profile Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    final adminService = AdminDataService();
    final double width = widget.isCollapsed ? 80.0 : 260.0;

    return ListenableBuilder(
      listenable: adminService,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          color: AdminColors.primaryGreen,
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
                      CircleAvatar(
                        radius: widget.isCollapsed ? 18 : 22,
                        backgroundColor: Colors.white24,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ADMIN PORTAL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                "Safe Moonwalk",
                                style: TextStyle(
                                  color: Colors.white60,
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

                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 15),

                // Sidebar items list
                Expanded(
                  child: ListView.builder(
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
                                    ? Colors.white.withOpacity(0.15)
                                    : isHovered 
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                minLeadingWidth: widget.isCollapsed ? 0 : 25,
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: widget.isCollapsed ? 12 : 16,
                                  vertical: 4,
                                ),
                                leading: Icon(
                                  item.icon,
                                  color: isSelected ? Colors.white : Colors.white70,
                                  size: 22,
                                ),
                                title: widget.isCollapsed 
                                    ? null 
                                    : Text(
                                        item.title,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white70,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                onTap: () => widget.onItemSelected(index),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Logout button (Red matching mock reference)
                const Divider(color: Colors.white24, height: 1),
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
                            : AdminColors.dangerRed.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: widget.isCollapsed ? 12 : 16,
                          vertical: 4,
                        ),
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 20,
                        ),
                        title: widget.isCollapsed 
                            ? null 
                            : const Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
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
