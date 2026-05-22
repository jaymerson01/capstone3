import 'package:flutter/material.dart';
import '../../../../core/services/shared_incident_database.dart';
import '../../data/models/incident_report.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/category.dart';
import '../../data/models/area.dart';

class AdminDataService extends ChangeNotifier {
  // Singleton pattern for easy global access
  static final AdminDataService _instance = AdminDataService._internal();
  factory AdminDataService() => _instance;
  AdminDataService._internal() {
    _initData();
  }

  // Admin Credentials
  String _adminName = "Super Admin";
  String _adminEmail = "admin@safe.gov";
  String _adminPassword = "admin123";
  String? _adminProfilePic; // Simulated base64 or file path

  String get adminName => _adminName;
  String get adminEmail => _adminEmail;
  String get adminPassword => _adminPassword;
  String? get adminProfilePic => _adminProfilePic;

  // Base counts to match the mock UI screenshot exactly
  final int _baseIncidents = 1110;
  final int _baseUsers = 195;
  final int _baseAreas = 6;
  final int _baseSolved = 6;

  // Lists for active detailed CRUD editing
  final List<IncidentReport> _reports = [];
  final List<UserProfile> _users = [];
  final List<IncidentCategory> _categories = [];
  final List<AreaInfo> _areas = [];

  List<IncidentReport> get reports => _reports;
  List<UserProfile> get users => _users;
  List<IncidentCategory> get categories => _categories;
  List<AreaInfo> get areas => _areas;

  // Live Statistics Getters
  int get totalIncidents => _baseIncidents + _reports.length;
  int get solvedCases => _baseSolved + _reports.where((r) => r.status == IncidentStatus.solved).length;
  int get registeredUsers => _baseUsers + _users.length;
  int get totalAreas => _baseAreas + _areas.length;

  // Initialize detailed dummy data
  void _initData() {
    // Initial sync and start listening
    _syncFromDatabase();
    SharedIncidentDatabase().addListener(_syncFromDatabase);

    // 5 Detailed Users
    _users.addAll([
      UserProfile(id: "USR-001", name: "Juan Dela Cruz", email: "juan.dc@email.com", role: "Reporter", isActive: true),
      UserProfile(id: "USR-002", name: "Maria Santos", email: "maria.santos@email.com", role: "Reporter", isActive: true),
      UserProfile(id: "USR-003", name: "Pedro Penduko", email: "pedro.p@email.com", role: "Barangay Official", isActive: true),
      UserProfile(id: "USR-004", name: "Ana Go", email: "ana.go@email.com", role: "Reporter", isActive: false),
      UserProfile(id: "USR-005", name: "John Doe", email: "john.doe@email.com", role: "Reporter", isActive: true),
    ]);

    // 5 Categories
    _categories.addAll([
      IncidentCategory(id: "CAT-001", name: "Theft", description: "Stealing of personal property, shoplifting, burglary"),
      IncidentCategory(id: "CAT-002", name: "Accident", description: "Road vehicular collisions, slips, structural damage accidents"),
      IncidentCategory(id: "CAT-003", name: "Fire", description: "Residential, commercial, forest, or open trash fires"),
      IncidentCategory(id: "CAT-004", name: "Violence", description: "Fights, physical assault, domestic disputes, street altercations"),
      IncidentCategory(id: "CAT-005", name: "Suspicious Activity", description: "Unidentified loitering, casing properties, unknown parked vehicles"),
    ]);

    // 6 Detailed Areas (out of 12)
    _areas.addAll([
      AreaInfo(id: "AREA-001", name: "Moonwalk", incidentsCount: 450),
      AreaInfo(id: "AREA-002", name: "Jacinto", incidentsCount: 220),
      AreaInfo(id: "AREA-003", name: "Purok 7", incidentsCount: 180),
      AreaInfo(id: "AREA-004", name: "Doang Batang", incidentsCount: 120),
      AreaInfo(id: "AREA-005", name: "Pepa Compound", incidentsCount: 150),
      AreaInfo(id: "AREA-006", name: "San Agustin", incidentsCount: 0),
    ]);
  }

  void _syncFromDatabase() {
    _reports.clear();
    final rawList = SharedIncidentDatabase().getRawIncidents();
    for (var raw in rawList) {
      _reports.add(_mapFromRaw(raw));
    }
    notifyListeners();
  }

  IncidentReport _mapFromRaw(Map<String, dynamic> raw) {
    IncidentStatus status;
    switch (raw['status'] as String? ?? 'pending') {
      case 'inProgress':
      case 'verified':
        status = IncidentStatus.inProgress;
        break;
      case 'solved':
      case 'resolved':
        status = IncidentStatus.solved;
        break;
      case 'pending':
      default:
        status = IncidentStatus.pending;
        break;
    }

    return IncidentReport(
      id: raw['id'] as String? ?? '',
      incidentType: (raw['title'] as String? ?? '').split(' in ').first.split(' on ').first,
      reporterName: raw['reporterName'] as String? ?? 'Anonymous',
      location: raw['location'] as String? ?? 'Unknown',
      date: raw['timestamp'] != null
          ? DateTime.parse(raw['timestamp'] as String)
          : DateTime.now(),
      status: status,
      description: raw['description'] as String? ?? '',
    );
  }

  // --- Profile Operations ---
  void updateProfile({required String name, required String password, String? profilePic}) {
    _adminName = name;
    _adminPassword = password;
    if (profilePic != null) {
      _adminProfilePic = profilePic;
    }
    notifyListeners();
  }

  // --- Incident Reports Operations ---
  void addReport(IncidentReport report) {
    SharedIncidentDatabase().saveIncident({
      'id': report.id,
      'title': report.incidentType,
      'reporterName': report.reporterName,
      'location': report.location,
      'description': report.description,
      'timestamp': report.date.toIso8601String(),
      'status': report.status == IncidentStatus.pending
          ? 'pending'
          : (report.status == IncidentStatus.inProgress ? 'inProgress' : 'solved'),
      'severity': 'Medium',
      'latitude': 14.4796,
      'longitude': 121.0196,
      'imagePath': 'assets/images/logo.png',
    });
  }

  void editReport(IncidentReport updatedReport) {
    SharedIncidentDatabase().saveIncident({
      'id': updatedReport.id,
      'title': updatedReport.incidentType,
      'reporterName': updatedReport.reporterName,
      'location': updatedReport.location,
      'description': updatedReport.description,
      'timestamp': updatedReport.date.toIso8601String(),
      'status': updatedReport.status == IncidentStatus.pending
          ? 'pending'
          : (updatedReport.status == IncidentStatus.inProgress ? 'inProgress' : 'solved'),
      'severity': 'Medium',
      'latitude': 14.4796,
      'longitude': 121.0196,
      'imagePath': 'assets/images/logo.png',
    });
  }

  void deleteReport(String reportId) {
    SharedIncidentDatabase().deleteIncident(reportId);
  }

  void updateReportStatus(String reportId, IncidentStatus newStatus) {
    final rawList = SharedIncidentDatabase().getRawIncidents();
    final index = rawList.indexWhere((r) => r['id'] == reportId);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(rawList[index]);
      updated['status'] = newStatus == IncidentStatus.pending
          ? 'pending'
          : (newStatus == IncidentStatus.inProgress ? 'inProgress' : 'solved');
      SharedIncidentDatabase().saveIncident(updated);
    }
  }

  // Helper to adjust area counts dynamically
  void _updateAreaCount(String areaName, int change) {
    for (var area in _areas) {
      if (areaName.toLowerCase().contains(area.name.toLowerCase()) || 
          area.name.toLowerCase().contains(areaName.toLowerCase())) {
        area.incidentsCount = (area.incidentsCount + change).clamp(0, 99999);
      }
    }
  }

  // --- User Operations ---
  void addUser(UserProfile user) {
    _users.insert(0, user);
    notifyListeners();
  }

  void editUser(UserProfile updatedUser) {
    int index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  void toggleUserActive(String userId) {
    int index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].isActive = !_users[index].isActive;
      notifyListeners();
    }
  }

  // --- Categories Operations ---
  void addCategory(IncidentCategory category) {
    _categories.add(category);
    notifyListeners();
  }

  void editCategory(IncidentCategory updatedCategory) {
    int index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      notifyListeners();
    }
  }

  void deleteCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  // --- Area Operations ---
  void addArea(AreaInfo area) {
    _areas.add(area);
    notifyListeners();
  }

  void editArea(AreaInfo updatedArea) {
    int index = _areas.indexWhere((a) => a.id == updatedArea.id);
    if (index != -1) {
      _areas[index] = updatedArea;
      notifyListeners();
    }
  }

  void deleteArea(String areaId) {
    _areas.removeWhere((a) => a.id == areaId);
    notifyListeners();
  }

  @override
  void dispose() {
    SharedIncidentDatabase().removeListener(_syncFromDatabase);
    super.dispose();
  }
}
