import 'dart:io';

void main() async {
  final filesToPatch = [
    'lib/features/admin_dashboard/presentation/pages/admin_audit_logs_page.dart',
    'lib/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart',
    'lib/features/admin_dashboard/presentation/pages/incident_reports_page.dart',
    'lib/features/admin_dashboard/presentation/pages/profile_settings_page.dart',
    'lib/features/admin_dashboard/presentation/pages/user_management_page.dart',
    'lib/features/admin_dashboard/presentation/widgets/admin_header.dart',
    'lib/features/admin_dashboard/presentation/widgets/admin_sidebar.dart'
  ];

  for (final filePath in filesToPatch) {
    final file = File('c:/YckoVon/Documents/capstone3/clean_folder/$filePath');
    if (!await file.exists()) continue;
    
    var content = await file.readAsString();
    
    content = content.replaceAll(
      "import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_data_service.dart';",
      "// import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_data_service.dart';"
    );
    content = content.replaceAll(
      "import 'package:community_safety_app/features/admin_dashboard/data/models/incident_report.dart';",
      "// import 'package:community_safety_app/features/admin_dashboard/data/models/incident_report.dart';"
    );
    
    if (content.contains("Widget build(BuildContext context) {")) {
      final parts = content.split("Widget build(BuildContext context) {");
      final lastBraceIdx = parts[1].lastIndexOf("}");
      if (lastBraceIdx != -1) {
        final newBody = "\n    // TODO: Wire to BLoC\n    return const Center(child: Text('TODO: Wire to BLoC'));\n    /*\n" + 
                        parts[1].substring(0, lastBraceIdx) + "*/\n}" + parts[1].substring(lastBraceIdx + 1);
        content = parts[0] + "Widget build(BuildContext context) {" + newBody;
      }
    }
    
    await file.writeAsString(content);
  }

  final shellFile = File('c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/admin_panel_shell.dart');
  var shellContent = await shellFile.readAsString();

  shellContent = shellContent.replaceAll(
    "import 'package:community_safety_app/features/admin_dashboard/presentation/pages/incident_categories_page.dart';",
    "// TODO: Wire to BLoC\n// import 'package:community_safety_app/features/admin_dashboard/presentation/pages/incident_categories_page.dart';"
  );
  shellContent = shellContent.replaceAll(
    "import 'package:community_safety_app/features/admin_dashboard/presentation/pages/area_management_page.dart';",
    "// TODO: Wire to BLoC\n// import 'package:community_safety_app/features/admin_dashboard/presentation/pages/area_management_page.dart';"
  );
  shellContent = shellContent.replaceAll(
    "case 3:\n        return const IncidentCategoriesPage();",
    "case 3:\n        return const Center(child: Text('TODO: Wire to BLoC')); // const IncidentCategoriesPage();"
  );
  shellContent = shellContent.replaceAll(
    "case 4:\n        return const AreaManagementPage();",
    "case 4:\n        return const Center(child: Text('TODO: Wire to BLoC')); // const AreaManagementPage();"
  );

  await shellFile.writeAsString(shellContent);
  print('Done');
}
