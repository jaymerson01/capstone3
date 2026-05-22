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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
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
                      icon: const Icon(Icons.menu, color: AdminColors.primaryGreen),
                      onPressed: onMenuPressed,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.menu_open, color: AdminColors.primaryGreen),
                      onPressed: onMenuPressed,
                      tooltip: "Toggle Sidebar",
                    ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textDark,
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
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
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
                  const SizedBox(width: 15),
                  // Divider
                  Container(
                    height: 25,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 15),
                  // User info
                  if (!isMobile)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          adminService.adminName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textDark,
                          ),
                        ),
                        const Text(
                          "System Administrator",
                          style: TextStyle(
                            fontSize: 11,
                            color: AdminColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: 10),
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AdminColors.primaryGreen,
                    child: const Text(
                      "A",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
