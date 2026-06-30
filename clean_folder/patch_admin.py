import os

files_to_patch = [
    'lib/features/admin_dashboard/presentation/pages/admin_audit_logs_page.dart',
    'lib/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart',
    'lib/features/admin_dashboard/presentation/pages/incident_reports_page.dart',
    'lib/features/admin_dashboard/presentation/pages/profile_settings_page.dart',
    'lib/features/admin_dashboard/presentation/pages/user_management_page.dart',
    'lib/features/admin_dashboard/presentation/widgets/admin_header.dart',
    'lib/features/admin_dashboard/presentation/widgets/admin_sidebar.dart'
]

for file_path in files_to_patch:
    full_path = os.path.join('c:/YckoVon/Documents/capstone3/clean_folder', file_path)
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = content.replace("import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_data_service.dart';", "// import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_data_service.dart';")
    content = content.replace("import 'package:community_safety_app/features/admin_dashboard/data/models/incident_report.dart';", "// import 'package:community_safety_app/features/admin_dashboard/data/models/incident_report.dart';")
    
    if "Widget build(BuildContext context) {" in content:
        parts = content.split("Widget build(BuildContext context) {", 1)
        last_brace_idx = parts[1].rfind("}")
        if last_brace_idx != -1:
            new_body = "\n    // TODO: Wire to BLoC\n    return const Center(child: Text('TODO: Wire to BLoC'));\n    /*\n" + parts[1][:last_brace_idx] + "*/\n}" + parts[1][last_brace_idx+1:]
            content = parts[0] + "Widget build(BuildContext context) {" + new_body
            
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)

shell_path = 'c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/admin_panel_shell.dart'
with open(shell_path, 'r', encoding='utf-8') as f:
    shell_content = f.read()

shell_content = shell_content.replace("import 'package:community_safety_app/features/admin_dashboard/presentation/pages/incident_categories_page.dart';", "// TODO: Wire to BLoC\n// import 'package:community_safety_app/features/admin_dashboard/presentation/pages/incident_categories_page.dart';")
shell_content = shell_content.replace("import 'package:community_safety_app/features/admin_dashboard/presentation/pages/area_management_page.dart';", "// TODO: Wire to BLoC\n// import 'package:community_safety_app/features/admin_dashboard/presentation/pages/area_management_page.dart';")

shell_content = shell_content.replace("case 3:\n        return const IncidentCategoriesPage();", "case 3:\n        return const Center(child: Text('TODO: Wire to BLoC')); // const IncidentCategoriesPage();")
shell_content = shell_content.replace("case 4:\n        return const AreaManagementPage();", "case 4:\n        return const Center(child: Text('TODO: Wire to BLoC')); // const AreaManagementPage();")

with open(shell_path, 'w', encoding='utf-8') as f:
    f.write(shell_content)

print('Done')
