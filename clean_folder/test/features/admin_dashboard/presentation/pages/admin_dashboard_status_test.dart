import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';

void main() {
  test('reports saved as in_progress show as a blue IN PROGRESS pill', () {
    // The admin portal saves "in_progress"; older reports say "In Progress".
    for (final stored in [
      'in_progress',
      'IN_PROGRESS',
      'In Progress',
      'inprogress',
    ]) {
      expect(
        AdminDashboardPage.statusTone(stored),
        AdminTone.blue,
        reason: stored,
      );
    }
    expect(AdminDashboardPage.statusLabel('in_progress'), 'IN PROGRESS');
    expect(AdminDashboardPage.statusLabel('In Progress'), 'IN PROGRESS');
  });

  test('the other statuses keep their colours and labels', () {
    expect(AdminDashboardPage.statusTone('Pending'), AdminTone.yellow);
    expect(AdminDashboardPage.statusTone('Resolved'), AdminTone.green);
    expect(AdminDashboardPage.statusTone('solved'), AdminTone.green);
    expect(AdminDashboardPage.statusTone('Spam'), AdminTone.slate);
    expect(AdminDashboardPage.statusLabel('Pending'), 'PENDING');
    expect(AdminDashboardPage.statusLabel('Resolved'), 'RESOLVED');
  });
}
