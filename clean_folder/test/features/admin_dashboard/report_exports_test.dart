import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/helpers/report_exports.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

final _theft = IncidentEntity(
  id: 'ab3xk9ZqP0',
  reporterId: 'r1',
  reporterName: 'Juan Dela Cruz',
  description: 'Ninakaw ang bisikleta sa harap ng tindahan.',
  category: 'Theft / Robbery',
  status: 'resolved',
  timestamp: DateTime(2026, 11, 11, 8, 0),
  inProgressAt: DateTime(2026, 11, 11, 8, 12),
  resolvedAt: DateTime(2026, 11, 11, 9, 30),
  latitude: 14.4851,
  longitude: 121.0116,
  areaSector: 'Area 5 - Moonwalk Proper',
  isBlotter: true,
  assignedResponderName: 'Tanod Pedro',
  rating: 4,
);

void main() {
  test('the Excel export has one row per report with the key columns', () {
    final bytes = ReportExports.reportsWorkbook([_theft]);
    final sheet = Excel.decodeBytes(bytes).tables['Reports']!;
    String cell(int row, int col) => sheet.rows[row][col]?.value.toString() ?? '';

    expect(sheet.maxRows, 2);
    expect(cell(0, 0), 'Ticket No.');
    expect(cell(1, 0), _theft.ticketNumber);
    expect(cell(1, 2), 'Theft / Robbery');
    expect(cell(1, 10), 'Tanod Pedro');
    expect(cell(1, 11), '12'); // minutes to respond
    expect(cell(1, 12), '90'); // minutes to resolve
    expect(cell(1, 14), '4');
  });

  test('the blotter entry is a PDF', () async {
    final bytes = await ReportExports.blotterPdf(_theft, printedAt: DateTime(2026, 11, 11, 10));
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1500));
  });
}
