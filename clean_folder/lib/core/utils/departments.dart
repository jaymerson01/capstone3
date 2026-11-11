import 'package:flutter/material.dart';

/// The barangay's responding departments. Reports go to them by incident
/// type ([forCategory]); admins can change that per report.
enum Department {
  tanod('tanod', 'Tanod / BPSO', Icons.shield_outlined),
  bfp('bfp', 'Fire (BFP)', Icons.local_fire_department_outlined),
  pnp('pnp', 'Police (PNP)', Icons.local_police_outlined),
  health('health', 'Health / Rescue', Icons.medical_services_outlined);

  const Department(this.id, this.label, this.icon);

  /// Stored on responder accounts and reports.
  final String id;
  final String label;
  final IconData icon;

  static Department? fromId(String? id) => values.where((d) => d.id == id).firstOrNull;

  /// Where a report of [category] goes by default. Keep in step with
  /// routedDepartments() in firestore.rules.
  static List<Department> forCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('fire')) return const [bfp, tanod];
    if (c.contains('medical')) return const [health];
    if (c.contains('flood') || c.contains('calamity')) return const [health, tanod];
    if (c.contains('road accident')) return const [health, tanod];
    if (c.contains('theft') || c.contains('robbery') || c.contains('violence') || c.contains('fight')) {
      return const [pnp, tanod];
    }
    if (c.contains('suspicious') || c.contains('missing')) return const [pnp, tanod];
    return const [tanod];
  }
}
