import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  Widget appLogo() {
    return Container(
      height: 36,
      width: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            appLogo(),
            const SizedBox(width: 10),
            const Text(
              "Safety Map",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Active Moonwalk Perimeters",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              "View geolocated hazard reports and emergency check zones in your area.",
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            
            // Map Frame Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Vector Grid Pattern simulating a map
                      CustomPaint(
                        size: Size.infinite,
                        painter: MapPainter(),
                      ),
                      
                      // Floating Search Overlay Bar
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search, color: AppColors.textLight, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Search locations or coordinates...",
                                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                                ),
                              ),
                              Icon(Icons.filter_list, color: AppColors.darkGreen, size: 20),
                            ],
                          ),
                        ),
                      ),
                      
                      // Floating Controls Overlay (Zoom buttons)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Column(
                          children: [
                            _mapActionButton(Icons.add),
                            const SizedBox(height: 8),
                            _mapActionButton(Icons.remove),
                            const SizedBox(height: 8),
                            _mapActionButton(Icons.my_location),
                          ],
                        ),
                      ),

                      // Floating Incident Pin Tooltip Callout (Simulated)
                      Positioned(
                        top: 130,
                        left: 80,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Fire Incident (Active)",
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.location_pin,
                              color: AppColors.danger,
                              size: 32,
                            ),
                          ],
                        ),
                      ),

                      // Second Pin (Simulated resolved or other type)
                      Positioned(
                        bottom: 120,
                        right: 120,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.progress,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Google Maps Redirect Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textDark,
                  elevation: 2,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.map, color: AppColors.darkGreen),
                label: const Text(
                  "Continue with Google Maps",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapActionButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textDark, size: 20),
        onPressed: () {},
      ),
    );
  }
}

// Custom Painter to draw grid lines representing street paths
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint greenSpace = Paint()
      ..color = AppColors.accentGreenBg.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw some parks/regions
    canvas.drawRect(Rect.fromLTWH(20, 100, 120, 80), greenSpace);
    canvas.drawRect(Rect.fromLTWH(size.width - 150, size.height - 180, 130, 90), greenSpace);

    // Draw grid paths
    canvas.drawLine(const Offset(0, 150), Offset(size.width, 150), linePaint);
    canvas.drawLine(const Offset(0, 240), Offset(size.width, 280), linePaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), linePaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.7, size.height), linePaint);
    canvas.drawLine(const Offset(30, 0), Offset(size.width * 0.3, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}