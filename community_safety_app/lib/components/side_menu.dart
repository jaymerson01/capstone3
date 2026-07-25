import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_color.dart';
import '../pages/dashboard.dart';
import '../pages/report_incident.dart';
import '../pages/my_reports.dart';
import '../pages/maps.dart';
import '../pages/settings.dart';
import '../pages/welcome_page.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with TickerProviderStateMixin {
  String hoveredItem = "";
  late AnimationController _entranceController;

  final List<_MenuItem> _items = [
    _MenuItem(Icons.home_outlined, Icons.home, "User Dashboard"),
    _MenuItem(Icons.warning_amber_outlined, Icons.warning_amber_rounded, "Report Incident"),
    _MenuItem(Icons.list_alt_outlined, Icons.list_alt_rounded, "My Reports"),
    _MenuItem(Icons.map_outlined, Icons.map, "Maps"),
    _MenuItem(Icons.settings_outlined, Icons.settings, "Settings"),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF060D1A), Color(0xFF0A1628)],
          ),
          border: Border(
            right: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary,
                            child: const Icon(Icons.shield,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.cyanGradient.createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: const Text(
                              "RESQ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const Text(
                            "Barangay Citizen Portal",
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // ── Menu Items ────────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isSelected =
                        currentRoute == null && index == 0 || false;
                    return _AnimatedMenuItem(
                      item: item,
                      delay: Duration(milliseconds: 60 * index),
                      entranceController: _entranceController,
                      isSelected: isSelected,
                      onTap: () => _navigate(context, item.label),
                    );
                  },
                ),
              ),

              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 12),

              // ── Logout ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: GestureDetector(
                  onTap: () => _navigate(context, "Logout"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded,
                            color: AppColors.danger, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          "Logout",
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String label) {
    Navigator.pop(context);

    if (label == "User Dashboard") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else if (label == "Report Incident") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReportIncidentPage()),
      );
    } else if (label == "My Reports") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyReportsPage()),
      );
    } else if (label == "Maps") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapsPage()),
      );
    } else if (label == "Settings") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    } else if (label == "Logout") {
      Hive.box('auth').put('isLoggedIn', false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    }
  }
}

class _MenuItem {
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  _MenuItem(this.iconOutlined, this.iconFilled, this.label);
}

class _AnimatedMenuItem extends StatefulWidget {
  final _MenuItem item;
  final Duration delay;
  final AnimationController entranceController;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedMenuItem({
    required this.item,
    required this.delay,
    required this.entranceController,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : _isHovered
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    // Animated indicator bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: widget.isSelected ? 3 : 0,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      widget.isSelected
                          ? widget.item.iconFilled
                          : widget.item.iconOutlined,
                      color: widget.isSelected
                          ? AppColors.primary
                          : _isHovered
                              ? AppColors.textDark
                              : AppColors.textLight,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: widget.isSelected
                            ? AppColors.primary
                            : _isHovered
                                ? AppColors.textDark
                                : AppColors.textLight,
                        fontSize: 14,
                        fontWeight: widget.isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
