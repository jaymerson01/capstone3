import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

/// Files the admin desk hands to the barangay: the reports as an Excel
/// workbook, and a printable blotter entry for one report.
class ReportExports {
  const ReportExports._();

  static final DateFormat _when = DateFormat('yyyy-MM-dd HH:mm');

  static const List<(String, double)> _columns = [
    ('Ticket No.', 18),
    ('Date Filed', 17),
    ('Category', 24),
    ('Priority', 10),
    ('Status', 12),
    ('Area', 24),
    ('Address', 40),
    ('Complainant', 22),
    ('Anonymous to Public', 12),
    ('Blotter Entry', 10),
    ('Responder', 22),
    ('Minutes to Respond', 12),
    ('Minutes to Resolve', 12),
    ('Date Resolved', 17),
    ('Rating (1-5)', 10),
    ('Rating Comment', 30),
    ('Barangay Comment', 40),
    ('Me Too Count', 10),
    ('Latitude', 11),
    ('Longitude', 11),
  ];

  /// The reports as an .xlsx workbook: one row each, newest first.
  static Uint8List reportsWorkbook(List<IncidentEntity> incidents) {
    final excel = Excel.createExcel();
    const sheetName = 'Reports';
    excel.rename(excel.getDefaultSheet() ?? 'Sheet1', sheetName);
    final sheet = excel[sheetName];

    sheet.appendRow([for (final (title, _) in _columns) TextCellValue(title)]);
    final header = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E40AF'),
      textWrapping: TextWrapping.WrapText,
    );
    for (var i = 0; i < _columns.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = header;
      sheet.setColumnWidth(i, _columns[i].$2);
    }

    final sorted = [...incidents]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    CellValue text(String? value) => TextCellValue(value ?? '');
    CellValue minutes(Duration? d) => d == null ? TextCellValue('') : IntCellValue(d.inMinutes);
    for (final i in sorted) {
      sheet.appendRow([
        text(i.ticketNumber),
        text(_when.format(i.timestamp)),
        text(i.category),
        text(i.urgencyStatus),
        text(i.status),
        text(BarangaySectorHelper.normalizeSector(i.areaSector, i.resolvedAddress)),
        text(i.resolvedAddress),
        text(i.reporterName),
        text(i.isAnonymous ? 'Yes' : 'No'),
        text(i.isBlotter ? 'Yes' : 'No'),
        text(i.assignedResponderName),
        minutes(i.timeToRespond),
        minutes(i.timeToResolve),
        text(i.resolvedAt == null ? null : _when.format(i.resolvedAt!)),
        i.rating == null ? TextCellValue('') : IntCellValue(i.rating!),
        text(i.ratingComment),
        text(i.dispatcherNotes),
        IntCellValue(i.upvoteCount),
        DoubleCellValue(i.latitude),
        DoubleCellValue(i.longitude),
      ]);
    }
    return Uint8List.fromList(excel.encode()!);
  }

  /// One report as a barangay blotter entry, ready to print and sign.
  static Future<Uint8List> blotterPdf(IncidentEntity report, {DateTime? printedAt}) {
    final pdf = pw.Document(title: 'Blotter ${report.ticketNumber}');
    final printed = printedAt ?? DateTime.now();
    final address = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: report.resolvedAddress,
      areaSector: report.areaSector,
      latitude: report.latitude,
      longitude: report.longitude,
    );

    pw.Widget heading(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
          child: pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        );
    pw.Widget row(String label, String? value) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.SizedBox(width: 130, child: pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
            pw.Expanded(child: pw.Text((value == null || value.isEmpty) ? '—' : value, style: const pw.TextStyle(fontSize: 10.5))),
          ]),
        );
    pw.Widget box(String? text) => pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500, width: 0.6)),
          child: pw.Text((text == null || text.isEmpty) ? '—' : text, style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 2)),
        );
    pw.Widget signature(String role) => pw.Expanded(
          child: pw.Column(children: [
            pw.SizedBox(height: 36),
            pw.Container(height: 0.8, color: PdfColors.grey800),
            pw.SizedBox(height: 3),
            pw.Text(role, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ]),
        );

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(42, 36, 42, 36),
      footer: (context) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Generated by ResQ · ${_when.format(printed)}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      ]),
      build: (context) => [
        pw.Center(
          child: pw.Column(children: [
            pw.Text('REPUBLIC OF THE PHILIPPINES', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.Text('CITY OF PARAÑAQUE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
            pw.Text('BARANGAY MOONWALK', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 6),
            pw.Container(height: 1.5, color: PdfColors.blue900),
            pw.SizedBox(height: 10),
            pw.Text('BARANGAY BLOTTER ENTRY', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
          ]),
        ),
        pw.SizedBox(height: 12),
        row('Ticket No.', report.ticketNumber),
        row('Date and time filed', _when.format(report.timestamp)),
        row('Nature of incident', report.category),
        row('Recorded as blotter', report.isBlotter ? 'Yes' : 'No'),
        row('Place of incident', address),
        heading('COMPLAINANT'),
        row('Name', report.reporterName),
        row('Email', report.reporterEmail),
        if (report.isReportingOnBehalf) ...[
          row('Victim / person involved', report.victimName),
          row('Victim contact no.', report.victimPhone),
        ],
        heading('NARRATIVE OF THE INCIDENT'),
        box(report.description),
        heading('ACTION TAKEN BY THE BARANGAY'),
        row('Status', report.status.replaceAll('_', ' ').toUpperCase()),
        row('Responder', report.assignedResponderName),
        row('Time to respond', report.timeToRespond == null ? null : IncidentEntity.formatDuration(report.timeToRespond!)),
        row('Date resolved', report.resolvedAt == null ? null : _when.format(report.resolvedAt!)),
        pw.SizedBox(height: 4),
        box(report.dispatcherNotes),
        pw.SizedBox(height: 28),
        pw.Row(children: [
          signature('Complainant'),
          pw.SizedBox(width: 24),
          signature('Recorded by (Desk Officer)'),
          pw.SizedBox(width: 24),
          signature('Punong Barangay'),
        ]),
      ],
    ));
    return pdf.save();
  }
}
