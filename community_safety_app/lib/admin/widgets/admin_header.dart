import 'package:flutter/material.dart';
import '../constants/admin_colors.dart';
import '../services/admin_data_service.dart';

class AdminHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final bool isMobile;

  const AdminHeader({
    super.key,
    required this.title,
    required this.onMenuPressed,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final adminService = AdminDataService();

    return ListenableBuilder(
      listenable: adminService,
      builder: (context, _) {
        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: const Border(
              bottom: BorderSide(
                color: AdminColors.border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Title and Toggle Menu Menu Icon
              Row(
                children: [
                  if (isMobile)
                    IconButton(
                      icon: const Icon(Icons.menu, color: AdminColors.primaryGreen, size: 22),
                      onPressed: onMenuPressed,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.menu_open, color: AdminColors.primaryGreen, size: 22),
                      onPressed: onMenuPressed,
                      tooltip: "Toggle Sidebar",
                    ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AdminColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Right: Profile Avatar and Admin Title
              Row(
                children: [
                  // Quick notifications (decorative)
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.notifications_none_outlined, color: Colors.grey.shade700, size: 20),
                          onPressed: () {},
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AdminColors.dangerRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Divider
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 16),
                  
                  // User info
                  if (!isMobile) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          adminService.adminName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "System Admin",
                          style: TextStyle(
                            fontSize: 11,
                            color: AdminColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                  ],
                  
                  // Avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AdminColors.primaryGreen.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        adminService.adminName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

