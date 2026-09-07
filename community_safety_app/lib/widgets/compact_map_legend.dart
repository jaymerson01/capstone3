import 'package:flutter/material.dart';
import '../admin/models/incident_report.dart';
import '../utils/marker_generator.dart';

class CompactMapLegend extends StatefulWidget {
  final bool showUserLocation;

  const CompactMapLegend({
    super.key,
    this.showUserLocation = true,
  });

  @override
  State<CompactMapLegend> createState() => _CompactMapLegendState();
}

class _CompactMapLegendState extends State<CompactMapLegend> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEC0A1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2D4A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend Header Toggle
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0088FF).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 16,
                      color: Color(0xFF0088FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Map Legend",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: const Color(0xFF8E9BAE),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content Body
          if (_isExpanded) ...[
            const Divider(color: Color(0xFF1E2D4A), height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Colors Section
                  const Text(
                    "STATUS COLORS",
                    style: TextStyle(
                      color: Color(0xFF8E9BAE),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip("Pending", IncidentStatus.pending),
                      _buildStatusChip("In Progress", IncidentStatus.inProgress),
                      _buildStatusChip("Solved", IncidentStatus.solved),
                      _buildStatusChip("Spam", IncidentStatus.spam),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF1E2D4A), height: 1),
                  const SizedBox(height: 10),

                  // Category Icons Section
                  const Text(
                    "INCIDENT ICONS",
                    style: TextStyle(
                      color: Color(0xFF8E9BAE),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildCategoryItem("Fire", Icons.local_fire_department, const Color(0xFFFF9800)),
                      _buildCategoryItem("Theft", Icons.local_police, const Color(0xFF0088FF)),
                      _buildCategoryItem("Medical", Icons.medical_services, const Color(0xFF00E676)),
                      _buildCategoryItem("Violence", Icons.warning_amber_rounded, const Color(0xFFFF334B)),
                      _buildCategoryItem("Accident", Icons.car_crash, const Color(0xFFFF9800)),
                      _buildCategoryItem("Flood", Icons.flood, const Color(0xFF0088FF)),
                      _buildCategoryItem("Noise", Icons.campaign, const Color(0xFF8E9BAE)),
                    ],
                  ),

                  if (widget.showUserLocation) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF1E2D4A), height: 1),
                    const SizedBox(height: 10),

                    // User Location Marker Section
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Your Current Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, IncidentStatus status) {
    final color = MarkerGenerator.getColorForStatus(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color accentColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1),
          ),
          child: Icon(icon, size: 13, color: Colors.white),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD0D7DE),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
