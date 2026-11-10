import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/notifications/data/models/notification_model.dart';
import 'package:community_safety_app/features/notifications/presentation/widgets/resident_notifications_sheet.dart';

NotificationModel note({required bool isRead, String? incidentId}) {
  return NotificationModel(
    id: 'n1',
    recipientId: 'resident_1',
    title: 'Report status updated',
    message: 'Your Fire Incident report is now In Progress.',
    type: 'status_change',
    incidentId: incidentId,
    isRead: isRead,
    createdAt: DateTime(2026, 10, 25, 9, 30),
  );
}

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  Future<void> pumpTile(WidgetTester tester, Widget tile) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.resident(),
        home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: tile),
        ),
      ),
    );
  }

  testWidgets('an unread notification opens its report and can be removed',
      (tester) async {
    var opened = 0;
    var removed = 0;
    await pumpTile(
      tester,
      ResidentNotificationTile(
        item: note(isRead: false, incidentId: 'inc1'),
        timeLabel: '5m ago',
        viewReportLabel: 'View report →',
        removeTooltip: 'Remove',
        onTap: () => opened++,
        onRemove: () => removed++,
      ),
    );

    expect(find.text('Report status updated'), findsOneWidget);
    expect(find.text('Your Fire Incident report is now In Progress.'), findsOneWidget);
    expect(find.text('View report →'), findsOneWidget);
    expect(find.text('5m ago'), findsOneWidget);

    await tester.tap(find.text('Report status updated'));
    expect(opened, 1);
    await tester.tap(find.byTooltip('Remove'));
    expect(removed, 1);
    expect(opened, 1);
  });

  testWidgets('a read notification without a report has no link',
      (tester) async {
    AppColors.isDarkMode = true;
    await pumpTile(
      tester,
      ResidentNotificationTile(
        item: note(isRead: true),
        timeLabel: '2d ago',
        viewReportLabel: null,
        removeTooltip: 'Alisin',
        onTap: () {},
        onRemove: () {},
      ),
    );

    expect(find.text('View report →'), findsNothing);
    expect(find.text('2d ago'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
