import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../models/user_profile.dart';
import '../models/category.dart';
import '../models/area.dart';

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
  // (1,120 incident reports, 12 areas, 10 solved, 200 registered users)
  final int _baseIncidents = 1110;
  final int _baseUsers = 195;
  final int _baseAreas = 6;
  final int _baseSolved = 6; // 6 base solved + 4 solved in our detailed reports list = 10 solved

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
    // 10 Detailed Reports
    _reports.addAll([
      IncidentReport(
        id: "REP-001",
        incidentType: "Theft",
        reporterName: "Juan Dela Cruz",
        location: "Barangay Moonwalk",
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: IncidentStatus.pending,
        description: "A bicycle was stolen from the garage at around 2 PM. CCTV footage is available.",
      ),
      IncidentReport(
        id: "REP-002",
        incidentType: "Accident",
        reporterName: "Maria Santos",
        location: "Barangay Jacinto",
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: IncidentStatus.inProgress,
        description: "Minor collision between a motorcycle and a sedan near the intersection. Traffic is backed up.",
      ),
      IncidentReport(
        id: "REP-003",
        incidentType: "Fire",
        reporterName: "Pedro Penduko",
        location: "Barangay Purok 7",
        date: DateTime.now().subtract(const Duration(days: 4)),
        status: IncidentStatus.solved,
        description: "Trash fire reported near the vacant lot. Local fire volunteers successfully extinguished it.",
      ),
      IncidentReport(
        id: "REP-004",
        incidentType: "Violence",
        reporterName: "Ana Go",
        location: "Barangay Doang Batang",
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: IncidentStatus.pending,
        description: "Physical altercation between two individuals at the local sports court. Barangay tanods intervened.",
      ),
      IncidentReport(
        id: "REP-005",
        incidentType: "Suspicious Activity",
        reporterName: "John Doe",
        location: "Barangay Pepa Compound",
        date: DateTime.now().subtract(const Duration(days: 6)),
        status: IncidentStatus.solved,
        description: "An unfamiliar vehicle has been parked with engine running for over 3 hours. Identified as a local delivery service lost in the area.",
      ),
      IncidentReport(
        id: "REP-006",
        incidentType: "Theft",
        reporterName: "Sarah Connor",
        location: "Barangay Moonwalk",
        date: DateTime.now().subtract(const Duration(days: 8)),
        status: IncidentStatus.solved,
        description: "Shoplifting incident at a convenience store. Suspect apprehended by store security.",
      ),
      IncidentReport(
        id: "REP-007",
        incidentType: "Accident",
        reporterName: "Bruce Wayne",
        location: "Barangay Jacinto",
        date: DateTime.now().subtract(const Duration(days: 9)),
        status: IncidentStatus.inProgress,
        description: "Car slid on slippery road after heavy rain. Medical team dispatched for minor scrapes.",
      ),
      IncidentReport(
        id: "REP-008",
        incidentType: "Suspicious Activity",
        reporterName: "Clark Kent",
        location: "Barangay Purok 7",
        date: DateTime.now().subtract(const Duration(days: 10)),
        status: IncidentStatus.pending,
        description: "Individual taking photos of house gates along the street. Reported to village security.",
      ),
      IncidentReport(
        id: "REP-009",
        incidentType: "Fire",
        reporterName: "Peter Parker",
        location: "Barangay Moonwalk",
        date: DateTime.now().subtract(const Duration(days: 12)),
        status: IncidentStatus.solved,
        description: "Electrical spark in a power post. Meralco team came and resolved the wiring issue.",
      ),
      IncidentReport(
        id: "REP-010",
        incidentType: "Violence",
        reporterName: "Diana Prince",
        location: "Barangay Pepa Compound",
        date: DateTime.now().subtract(const Duration(days: 14)),
        status: IncidentStatus.inProgress,
        description: "Noisy street fight late at night. Dispersed by local authorities.",
      ),
    ]);

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
    _reports.insert(0, report);
    _updateAreaCount(report.location, 1);
    notifyListeners();
  }

  void editReport(IncidentReport updatedReport) {
    int index = _reports.indexWhere((r) => r.id == updatedReport.id);
    if (index != -1) {
      String oldLocation = _reports[index].location;
      _reports[index] = updatedReport;
      
      // If location changed, adjust stats
      if (oldLocation != updatedReport.location) {
        _updateAreaCount(oldLocation, -1);
        _updateAreaCount(updatedReport.location, 1);
      }
      notifyListeners();
    }
  }

  void deleteReport(String reportId) {
    int index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      String location = _reports[index].location;
      _reports.removeAt(index);
      _updateAreaCount(location, -1);
      notifyListeners();
    }
  }

  void updateReportStatus(String reportId, IncidentStatus newStatus) {
    int index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index].status = newStatus;
      notifyListeners();
    }
  }

  // Helper to adjust area counts dynamically
  void _updateAreaCount(String areaName, int change) {
    // Standardize naming checks
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
}
