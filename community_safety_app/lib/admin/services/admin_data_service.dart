import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../models/user_profile.dart';
import '../models/category.dart';
import '../models/area.dart';

class AdminDataService extends ChangeNotifier {
  static final AdminDataService _instance = AdminDataService._internal();

  factory AdminDataService() => _instance;

  AdminDataService._internal() {
    _initData();
  }

  String _adminName = "Super Admin";
  String _adminEmail = "admin@safe.gov";
  String _adminPassword = "admin123";
  String? _adminProfilePic;

  String get adminName => _adminName;
  String get adminEmail => _adminEmail;
  String get adminPassword => _adminPassword;
  String? get adminProfilePic => _adminProfilePic;

  final int _baseIncidents = 1110;
  final int _baseUsers = 195;
  final int _baseAreas = 6;
  final int _baseSolved = 6;

  final List<IncidentReport> _reports = [];
  final List<UserProfile> _users = [];
  final List<IncidentCategory> _categories = [];
  final List<AreaInfo> _areas = [];

  final List<Map<String, String>> _auditLogs = [];
  final Map<String, Map<IncidentStatus, DateTime>> _statusTimestamps = {};

  List<IncidentReport> get reports => _reports;
  List<UserProfile> get users => _users;
  List<IncidentCategory> get categories => _categories;
  List<AreaInfo> get areas => _areas;
  List<Map<String, String>> get auditLogs => _auditLogs;

  int get totalIncidents => _baseIncidents + _reports.length;

  int get solvedCases =>
      _baseSolved +
      _reports.where((r) => r.status == IncidentStatus.solved).length;

  int get registeredUsers => _baseUsers + _users.length;
  int get totalAreas => _baseAreas + _areas.length;

  DateTime? getStatusTimestamp(String reportId, IncidentStatus status) {
    return _statusTimestamps[reportId]?[status];
  }

  void _initData() {
    _reports.addAll([
      IncidentReport(
        id: "REP-001",
        incidentType: "Theft",
        reporterName: "Juan Dela Cruz",
        location: "Barangay Moonwalk",
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: IncidentStatus.pending,
        description:
            "A bicycle was stolen from the garage at around 2 PM. CCTV footage is available.",
      ),
      IncidentReport(
        id: "REP-002",
        incidentType: "Accident",
        reporterName: "Maria Santos",
        location: "Barangay Jacinto",
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: IncidentStatus.inProgress,
        description:
            "Minor collision between a motorcycle and a sedan near the intersection. Traffic is backed up.",
      ),
      IncidentReport(
        id: "REP-003",
        incidentType: "Fire",
        reporterName: "Pedro Penduko",
        location: "Barangay Purok 7",
        date: DateTime.now().subtract(const Duration(days: 4)),
        status: IncidentStatus.solved,
        description:
            "Trash fire reported near the vacant lot. Local fire volunteers successfully extinguished it.",
      ),
      IncidentReport(
        id: "REP-004",
        incidentType: "Violence",
        reporterName: "Ana Go",
        location: "Barangay Doang Batang",
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: IncidentStatus.pending,
        description:
            "Physical altercation between two individuals at the local sports court. Barangay tanods intervened.",
      ),
      IncidentReport(
        id: "REP-005",
        incidentType: "Suspicious Activity",
        reporterName: "John Doe",
        location: "Barangay Pepa Compound",
        date: DateTime.now().subtract(const Duration(days: 6)),
        status: IncidentStatus.solved,
        description:
            "An unfamiliar vehicle has been parked with engine running for over 3 hours. Identified as a local delivery service lost in the area.",
      ),
      IncidentReport(
        id: "REP-006",
        incidentType: "Theft",
        reporterName: "Sarah Connor",
        location: "Barangay Moonwalk",
        date: DateTime.now().subtract(const Duration(days: 8)),
        status: IncidentStatus.solved,
        description:
            "Shoplifting incident at a convenience store. Suspect apprehended by store security.",
      ),
      IncidentReport(
        id: "REP-007",
        incidentType: "Accident",
        reporterName: "Bruce Wayne",
        location: "Barangay Jacinto",
        date: DateTime.now().subtract(const Duration(days: 9)),
        status: IncidentStatus.inProgress,
        description:
            "Car slid on slippery road after heavy rain. Medical team dispatched for minor scrapes.",
      ),
      IncidentReport(
        id: "REP-008",
        incidentType: "Suspicious Activity",
        reporterName: "Clark Kent",
        location: "Barangay Purok 7",
        date: DateTime.now().subtract(const Duration(days: 10)),
        status: IncidentStatus.pending,
        description:
            "Individual taking photos of house gates along the street. Reported to village security.",
      ),
      IncidentReport(
        id: "REP-009",
        incidentType: "Fire",
        reporterName: "Peter Parker",
        location: "Barangay Moonwalk",
        date: DateTime.now().subtract(const Duration(days: 12)),
        status: IncidentStatus.solved,
        description:
            "Electrical spark in a power post. Meralco team came and resolved the wiring issue.",
      ),
      IncidentReport(
        id: "REP-010",
        incidentType: "Violence",
        reporterName: "Diana Prince",
        location: "Barangay Pepa Compound",
        date: DateTime.now().subtract(const Duration(days: 14)),
        status: IncidentStatus.inProgress,
        description:
            "Noisy street fight late at night. Dispersed by local authorities.",
      ),
    ]);

    for (final report in _reports) {
      _statusTimestamps[report.id] = {
        IncidentStatus.pending: report.date,
      };

      if (report.status == IncidentStatus.inProgress ||
          report.status == IncidentStatus.solved) {
        _statusTimestamps[report.id]![IncidentStatus.inProgress] =
            report.date.add(const Duration(minutes: 12));
      }

      if (report.status == IncidentStatus.solved) {
        _statusTimestamps[report.id]![IncidentStatus.solved] =
            report.date.add(const Duration(minutes: 45));
      }
    }

    _users.addAll([
      UserProfile(
        id: "USR-001",
        name: "Juan Dela Cruz",
        email: "juan.dc@email.com",
        role: "Reporter",
        isActive: true,
      ),
      UserProfile(
        id: "USR-002",
        name: "Maria Santos",
        email: "maria.santos@email.com",
        role: "Reporter",
        isActive: true,
      ),
      UserProfile(
        id: "USR-003",
        name: "Pedro Penduko",
        email: "pedro.p@email.com",
        role: "Barangay Official",
        isActive: true,
      ),
      UserProfile(
        id: "USR-004",
        name: "Ana Go",
        email: "ana.go@email.com",
        role: "Reporter",
        isActive: false,
      ),
      UserProfile(
        id: "USR-005",
        name: "John Doe",
        email: "john.doe@email.com",
        role: "Reporter",
        isActive: true,
      ),
    ]);

    _categories.addAll([
      IncidentCategory(
        id: "CAT-001",
        name: "Theft",
        description: "Stealing of personal property, shoplifting, burglary",
      ),
      IncidentCategory(
        id: "CAT-002",
        name: "Accident",
        description:
            "Road vehicular collisions, slips, structural damage accidents",
      ),
      IncidentCategory(
        id: "CAT-003",
        name: "Fire",
        description: "Residential, commercial, forest, or open trash fires",
      ),
      IncidentCategory(
        id: "CAT-004",
        name: "Violence",
        description:
            "Fights, physical assault, domestic disputes, street altercations",
      ),
      IncidentCategory(
        id: "CAT-005",
        name: "Suspicious Activity",
        description:
            "Unidentified loitering, casing properties, unknown parked vehicles",
      ),
    ]);

    _areas.addAll([
      AreaInfo(id: "AREA-001", name: "Moonwalk", incidentsCount: 450),
      AreaInfo(id: "AREA-002", name: "Jacinto", incidentsCount: 220),
      AreaInfo(id: "AREA-003", name: "Purok 7", incidentsCount: 180),
      AreaInfo(id: "AREA-004", name: "Doang Batang", incidentsCount: 120),
      AreaInfo(id: "AREA-005", name: "Pepa Compound", incidentsCount: 150),
      AreaInfo(id: "AREA-006", name: "San Agustin", incidentsCount: 0),
    ]);
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return "${dateTime.month}/${dateTime.day}/${dateTime.year} $hour:$minute";
  }

  void addAuditLog({
    required String action,
    required String details,
  }) {
    _auditLogs.insert(0, {
      "time": _formatDateTime(DateTime.now()),
      "admin": adminName,
      "action": action,
      "details": details,
    });
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

    addAuditLog(
      action: "Profile Updated",
      details: "Updated admin profile information",
    );

    notifyListeners();
  }

  void addReport(IncidentReport report) {
    _reports.insert(0, report);

    _statusTimestamps[report.id] = {
      IncidentStatus.pending: report.date,
    };

    _updateAreaCount(report.location, 1);

    addAuditLog(
      action: "Report Added",
      details: "Added Report ${report.id}",
    );

    notifyListeners();
  }

  void editReport(IncidentReport updatedReport) {
    int index = _reports.indexWhere((r) => r.id == updatedReport.id);

    if (index != -1) {
      String oldLocation = _reports[index].location;
      _reports[index] = updatedReport;

      if (oldLocation != updatedReport.location) {
        _updateAreaCount(oldLocation, -1);
        _updateAreaCount(updatedReport.location, 1);
      }

      addAuditLog(
        action: "Report Edited",
        details: "Edited Report ${updatedReport.id}",
      );

      notifyListeners();
    }
  }

  void deleteReport(String reportId) {
    int index = _reports.indexWhere((r) => r.id == reportId);

    if (index != -1) {
      String location = _reports[index].location;

      _reports.removeAt(index);
      _statusTimestamps.remove(reportId);
      _updateAreaCount(location, -1);

      addAuditLog(
        action: "Report Deleted",
        details: "Deleted Report $reportId",
      );

      notifyListeners();
    }
  }

  void updateReportStatus(String reportId, IncidentStatus newStatus) {
    int index = _reports.indexWhere((r) => r.id == reportId);

    if (index != -1) {
      _reports[index].status = newStatus;

      _statusTimestamps.putIfAbsent(reportId, () => {});
      _statusTimestamps[reportId]!.putIfAbsent(
        newStatus,
        () => DateTime.now(),
      );

      addAuditLog(
        action: "Report Status Updated",
        details: "Updated Report $reportId to ${_statusLabel(newStatus)}",
      );

      notifyListeners();
    }
  }

  void markReportAsSpam(String reportId) {
    updateReportStatus(reportId, IncidentStatus.spam);

    addAuditLog(
      action: "Marked as Spam",
      details: "Marked Report $reportId as Spam",
    );

    notifyListeners();
  }

  String _statusLabel(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return "Pending";
      case IncidentStatus.inProgress:
        return "In Progress";
      case IncidentStatus.solved:
        return "Solved";
      case IncidentStatus.spam:
        return "Spam";
    }
  }

  void _updateAreaCount(String areaName, int change) {
    for (var area in _areas) {
      if (areaName.toLowerCase().contains(area.name.toLowerCase()) ||
          area.name.toLowerCase().contains(areaName.toLowerCase())) {
        area.incidentsCount = (area.incidentsCount + change).clamp(0, 99999);
      }
    }
  }

  void addUser(UserProfile user) {
    _users.insert(0, user);

    addAuditLog(
      action: "User Added",
      details: "Added user ${user.name}",
    );

    notifyListeners();
  }

  void editUser(UserProfile updatedUser) {
    int index = _users.indexWhere((u) => u.id == updatedUser.id);

    if (index != -1) {
      _users[index] = updatedUser;

      addAuditLog(
        action: "User Updated",
        details: "Updated user ${updatedUser.name}",
      );

      notifyListeners();
    }
  }

  void updateUserRole(String userId, String newRole) {
    int index = _users.indexWhere((u) => u.id == userId);

    if (index != -1) {
      final userName = _users[index].name;

      _users[index] = _users[index].copyWith(role: newRole);

      addAuditLog(
        action: "Role Changed",
        details: "Changed $userName role to $newRole",
      );

      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);

    if (index != -1) {
      final userName = _users[index].name;

      _users.removeAt(index);

      addAuditLog(
        action: "User Deleted",
        details: "Deleted user $userName",
      );

      notifyListeners();
    }
  }

  void toggleUserActive(String userId) {
    int index = _users.indexWhere((u) => u.id == userId);

    if (index != -1) {
      _users[index].isActive = !_users[index].isActive;

      addAuditLog(
        action: _users[index].isActive ? "User Enabled" : "User Disabled",
        details:
            "${_users[index].isActive ? "Enabled" : "Disabled"} user ${_users[index].name}",
      );

      notifyListeners();
    }
  }

  void addCategory(IncidentCategory category) {
    _categories.add(category);

    addAuditLog(
      action: "Category Added",
      details: "Added category ${category.name}",
    );

    notifyListeners();
  }

  void editCategory(IncidentCategory updatedCategory) {
    int index = _categories.indexWhere((c) => c.id == updatedCategory.id);

    if (index != -1) {
      _categories[index] = updatedCategory;

      addAuditLog(
        action: "Category Updated",
        details: "Updated category ${updatedCategory.name}",
      );

      notifyListeners();
    }
  }

  void deleteCategory(String categoryId) {
    final index = _categories.indexWhere((c) => c.id == categoryId);

    if (index != -1) {
      final categoryName = _categories[index].name;

      _categories.removeAt(index);

      addAuditLog(
        action: "Category Deleted",
        details: "Deleted category $categoryName",
      );

      notifyListeners();
    }
  }

  void addArea(AreaInfo area) {
    _areas.add(area);

    addAuditLog(
      action: "Area Added",
      details: "Added area ${area.name}",
    );

    notifyListeners();
  }

  void editArea(AreaInfo updatedArea) {
    int index = _areas.indexWhere((a) => a.id == updatedArea.id);

    if (index != -1) {
      _areas[index] = updatedArea;

      addAuditLog(
        action: "Area Updated",
        details: "Updated area ${updatedArea.name}",
      );

      notifyListeners();
    }
  }

  void deleteArea(String areaId) {
    final index = _areas.indexWhere((a) => a.id == areaId);

    if (index != -1) {
      final areaName = _areas[index].name;

      _areas.removeAt(index);

      addAuditLog(
        action: "Area Deleted",
        details: "Deleted area $areaName",
      );

      notifyListeners();
    }
  }
}