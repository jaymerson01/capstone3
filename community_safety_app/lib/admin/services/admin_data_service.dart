import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../models/user_profile.dart';
import '../models/category.dart';
import '../models/area.dart';
import '../../services/mock_database_service.dart';

class AdminDataService extends ChangeNotifier {
  static final AdminDataService _instance = AdminDataService._internal();
  factory AdminDataService() => _instance;

  final MockDatabaseService _db = MockDatabaseService();

  AdminDataService._internal() {
    _db.addListener(_onDbChange);
  }

  void _onDbChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    _db.removeListener(_onDbChange);
    super.dispose();
  }

  String _adminName = "Super Admin";
  final String _adminEmail = "admin@safe.gov";
  String _adminPassword = "admin123";
  String? _adminProfilePic;

  String get adminName => _adminName;
  String get adminEmail => _adminEmail;
  String get adminPassword => _adminPassword;
  String? get adminProfilePic => _adminProfilePic;

  final List<Map<String, String>> _auditLogs = [];
  final Map<String, Map<IncidentStatus, DateTime>> _statusTimestamps = {};

  bool showArchivedReports = false;
  bool showArchivedUsers = false;
  bool showArchivedAreas = false;

  void toggleArchivedReports() {
    showArchivedReports = !showArchivedReports;
    notifyListeners();
  }

  void toggleArchivedUsers() {
    showArchivedUsers = !showArchivedUsers;
    notifyListeners();
  }

  void toggleArchivedAreas() {
    showArchivedAreas = !showArchivedAreas;
    notifyListeners();
  }

  List<IncidentReport> get reports => _db.reports.where((r) => r.isArchived == showArchivedReports).toList();
  List<UserProfile> get users => _db.users.where((u) => u.isArchived == showArchivedUsers).toList();
  List<IncidentCategory> get categories => _db.categories.where((c) => !c.isArchived).toList();
  List<AreaInfo> get areas => _db.areas.where((a) => a.isArchived == showArchivedAreas).toList();
  
  List<Map<String, String>> get auditLogs => _auditLogs;

  int get totalIncidents => _db.reports.length;

  int get solvedCases =>
      _db.reports.where((r) => r.status == IncidentStatus.solved).length;

  int get registeredUsers => _db.users.length;
  int get totalAreas => _db.areas.length;

  DateTime? getStatusTimestamp(String reportId, IncidentStatus status) {
    return _statusTimestamps[reportId]?[status];
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "${dateTime.month}/${dateTime.day}/${dateTime.year} $hour:$minute";
  }

  void addAuditLog({required String action, required String details}) {
    _auditLogs.insert(0, {
      "time": _formatDateTime(DateTime.now()),
      "admin": adminName,
      "action": action,
      "details": details,
    });
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String password,
    String? profilePic,
  }) {
    _adminName = name;
    _adminPassword = password;
    if (profilePic != null) {
      _adminProfilePic = profilePic;
    }
    addAuditLog(action: "Profile Updated", details: "Updated admin profile information");
    notifyListeners();
  }

  void addReport(IncidentReport report) {
    _db.addReport(report);
    _statusTimestamps[report.id] = {IncidentStatus.pending: report.date};
    addAuditLog(action: "Report Added", details: "Added Report ${report.id}");
  }

  void editReport(IncidentReport updatedReport) {
    // In a real app we'd edit in DB, but here we just leave it or implement in mock DB
    // To keep it simple, we don't have editReport in MockDB yet, we can add it later if needed.
    addAuditLog(action: "Report Edited", details: "Edited Report ${updatedReport.id}");
  }

  void archiveReport(String reportId) {
    _db.archiveReport(reportId);
    addAuditLog(action: "Report Archived", details: "Archived Report $reportId");
  }

  void updateReportStatus(String reportId, IncidentStatus newStatus) {
    _db.updateReportStatus(reportId, newStatus);
    _statusTimestamps.putIfAbsent(reportId, () => {});
    _statusTimestamps[reportId]!.putIfAbsent(newStatus, () => DateTime.now());
    addAuditLog(action: "Report Status Updated", details: "Updated Report $reportId to ${_statusLabel(newStatus)}");
  }

  void markReportAsSpam(String reportId) {
    updateReportStatus(reportId, IncidentStatus.spam);
    addAuditLog(action: "Marked as Spam", details: "Marked Report $reportId as Spam");
  }

  String _statusLabel(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending: return "Pending";
      case IncidentStatus.inProgress: return "In Progress";
      case IncidentStatus.solved: return "Solved";
      case IncidentStatus.spam: return "Spam";
    }
  }

  void addUser(UserProfile user) {
    // _db.addUser(user); 
    addAuditLog(action: "User Added", details: "Added user ${user.name}");
  }

  void editUser(UserProfile updatedUser) {
    addAuditLog(action: "User Updated", details: "Updated user ${updatedUser.name}");
  }

  void updateUserRole(String userId, String newRole) {
    addAuditLog(action: "Role Changed", details: "Changed role to $newRole");
  }

  void archiveUser(String userId) {
    _db.archiveUser(userId);
    addAuditLog(action: "User Archived", details: "Archived user $userId");
  }

  void toggleUserActive(String userId) {
    addAuditLog(action: "User Toggled", details: "Toggled user $userId");
  }

  void addCategory(IncidentCategory category) {
    addAuditLog(action: "Category Added", details: "Added category ${category.name}");
  }

  void editCategory(IncidentCategory updatedCategory) {
    addAuditLog(action: "Category Updated", details: "Updated category ${updatedCategory.name}");
  }

  void archiveCategory(String categoryId) {
    _db.archiveCategory(categoryId);
    addAuditLog(action: "Category Archived", details: "Archived category $categoryId");
  }

  void addArea(AreaInfo area) {
    addAuditLog(action: "Area Added", details: "Added area ${area.name}");
  }

  void editArea(AreaInfo updatedArea) {
    addAuditLog(action: "Area Updated", details: "Updated area ${updatedArea.name}");
  }

  void archiveArea(String areaId) {
    _db.archiveArea(areaId);
    addAuditLog(action: "Area Archived", details: "Archived area $areaId");
  }
}
