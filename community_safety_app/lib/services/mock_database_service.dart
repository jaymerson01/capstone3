import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../admin/models/incident_report.dart';
import '../admin/models/user_profile.dart';
import '../admin/models/category.dart';
import '../admin/models/area.dart';
import 'api_service.dart';
import 'api_exception.dart';

class MockDatabaseService extends ChangeNotifier {
  static final MockDatabaseService _instance = MockDatabaseService._internal();
  factory MockDatabaseService() => _instance;

  MockDatabaseService._internal() {
    _loadData();
  }

  late Box _dataBox;
  late Box _authBox;

  final List<IncidentReport> _reports = [];
  final List<UserProfile> _users = [];
  final List<IncidentCategory> _categories = [];
  final List<AreaInfo> _areas = [];

  UserProfile? _currentUser;

  List<IncidentReport> get reports => _reports;
  List<UserProfile> get users => _users;
  List<IncidentCategory> get categories => _categories;
  List<AreaInfo> get areas => _areas;
  UserProfile? get currentUser => _currentUser;

  Future<void> init() async {
    _dataBox = await Hive.openBox('appData');
    _authBox = Hive.box('auth');
    _loadData();
    await syncWithBackend();
  }

  void _loadData() {
    if (!Hive.isBoxOpen('appData')) return;

    final String? reportsJson = _dataBox.get('reports');
    if (reportsJson != null) {
      final List dynamicList = jsonDecode(reportsJson);
      _reports.clear();
      _reports.addAll(dynamicList.map((e) => IncidentReport.fromJson(e)).toList());
    }

    final String? usersJson = _dataBox.get('users');
    if (usersJson != null) {
      final List dynamicList = jsonDecode(usersJson);
      _users.clear();
      _users.addAll(dynamicList.map((e) => UserProfile.fromJson(e)).toList());
    }

    final String? categoriesJson = _dataBox.get('categories');
    if (categoriesJson != null) {
      final List dynamicList = jsonDecode(categoriesJson);
      _categories.clear();
      _categories.addAll(dynamicList.map((e) => IncidentCategory.fromJson(e)).toList());
    } else {
      _initDefaultCategories();
    }

    final String? areasJson = _dataBox.get('areas');
    if (areasJson != null) {
      final List dynamicList = jsonDecode(areasJson);
      _areas.clear();
      _areas.addAll(dynamicList.map((e) => AreaInfo.fromJson(e)).toList());
    } else {
      _initDefaultAreas();
    }

    final String? currentUserJson = _authBox.get('currentUser');
    if (currentUserJson != null) {
      _currentUser = UserProfile.fromJson(jsonDecode(currentUserJson));
    }

    notifyListeners();
  }

  /// Syncs cached local state with live server API
  Future<void> syncWithBackend() async {
    try {
      final serverUser = await ApiService().getCurrentUser();
      if (serverUser != null) {
        _currentUser = serverUser;
        _authBox.put('currentUser', jsonEncode(serverUser.toJson()));
        _authBox.put('isLoggedIn', true);

        // Fetch live reports from backend
        final liveReports = _currentUser?.role.toLowerCase() == 'admin'
            ? await ApiService().getIncidents()
            : await ApiService().getMyIncidents();

        if (liveReports.isNotEmpty) {
          _reports.clear();
          _reports.addAll(liveReports);
          _saveReports();
        }
      }
      notifyListeners();
    } catch (_) {
      // If network is offline, retain Hive cached state for viewing
    }
  }

  void _saveReports() {
    final List<Map<String, dynamic>> jsonList = _reports.map((e) => e.toJson()).toList();
    _dataBox.put('reports', jsonEncode(jsonList));
    notifyListeners();
  }

  void _saveUsers() {
    final List<Map<String, dynamic>> jsonList = _users.map((e) => e.toJson()).toList();
    _dataBox.put('users', jsonEncode(jsonList));
    notifyListeners();
  }

  void _saveCategories() {
    final List<Map<String, dynamic>> jsonList = _categories.map((e) => e.toJson()).toList();
    _dataBox.put('categories', jsonEncode(jsonList));
    notifyListeners();
  }

  void _saveAreas() {
    final List<Map<String, dynamic>> jsonList = _areas.map((e) => e.toJson()).toList();
    _dataBox.put('areas', jsonEncode(jsonList));
    notifyListeners();
  }

  DateTime? getLockoutExpiration(String email) {
    return null;
  }

  // Auth Methods - Server Mandated (Zero Local Password Fallbacks)
  Future<String?> signUp(String name, String email, String password, String role) async {
    try {
      final user = await ApiService().signUp(name, email, password);
      _currentUser = user;
      _authBox.put('currentUser', jsonEncode(user.toJson()));
      _authBox.put('isLoggedIn', true);
      notifyListeners();
      return null; // Success
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred during signup: $e";
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final user = await ApiService().login(email, password);
      _currentUser = user;
      _authBox.put('currentUser', jsonEncode(user.toJson()));
      _authBox.put('isLoggedIn', true);

      // Sync backend reports for logged in user
      await syncWithBackend();

      notifyListeners();
      return null; // Success
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred during login: $e";
    }
  }

  void logout() {
    _currentUser = null;
    ApiService().setToken(null);
    _authBox.delete('currentUser');
    _authBox.put('isLoggedIn', false);
    notifyListeners();
  }

  // Data Manipulation
  Future<void> addReport(IncidentReport report) async {
    try {
      final serverReport = await ApiService().createIncident(
        incidentType: report.incidentType,
        reporterName: report.reporterName,
        location: report.location,
        description: report.description,
        urgencyLevel: report.urgencyLevel,
      );

      // Insert canonical server report to prevent duplicates
      _reports.insert(0, serverReport);
      _updateAreaCount(serverReport.location, 1);
      _saveReports();
    } catch (e) {
      // Offline fallback caching
      _reports.insert(0, report);
      _updateAreaCount(report.location, 1);
      _saveReports();
    }
  }

  Future<void> updateReportStatus(String reportId, IncidentStatus newStatus) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index].status = newStatus;
      _saveReports();

      try {
        await ApiService().updateIncidentStatus(reportId, newStatus.name);
      } catch (_) {
        // Retain local status update if backend update encounters issue
      }
    }
  }

  void archiveReport(String reportId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index].isArchived = true;
      _updateAreaCount(_reports[index].location, -1);
      _saveReports();
    }
  }

  void archiveUser(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].isArchived = true;
      _saveUsers();
    }
  }

  void archiveCategory(String categoryId) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _categories[index].isArchived = true;
      _saveCategories();
    }
  }

  void archiveArea(String areaId) {
    final index = _areas.indexWhere((a) => a.id == areaId);
    if (index != -1) {
      _areas[index].isArchived = true;
      _saveAreas();
    }
  }

  void _updateAreaCount(String areaName, int change) {
    for (var area in _areas) {
      if (areaName.toLowerCase().contains(area.name.toLowerCase()) ||
          area.name.toLowerCase().contains(areaName.toLowerCase())) {
        area.incidentsCount = (area.incidentsCount + change).clamp(0, 99999);
      }
    }
    _saveAreas();
  }

  void _initDefaultCategories() {
    _categories.addAll([
      IncidentCategory(id: "CAT-001", name: "Theft", description: "Stealing of personal property"),
      IncidentCategory(id: "CAT-002", name: "Accident", description: "Road vehicular collisions"),
      IncidentCategory(id: "CAT-003", name: "Fire", description: "Fires"),
      IncidentCategory(id: "CAT-004", name: "Violence", description: "Fights, physical assault"),
      IncidentCategory(id: "CAT-005", name: "Suspicious Activity", description: "Unidentified loitering"),
    ]);
    _saveCategories();
  }

  void _initDefaultAreas() {
    _areas.addAll([
      AreaInfo(id: "AREA-001", name: "Area 1", incidentsCount: 0),
      AreaInfo(id: "AREA-002", name: "Area 2", incidentsCount: 0),
      AreaInfo(id: "AREA-003", name: "Area 3", incidentsCount: 0),
      AreaInfo(id: "AREA-004", name: "Area 4", incidentsCount: 0),
      AreaInfo(id: "AREA-005", name: "Area 5", incidentsCount: 0),
    ]);
    _saveAreas();
  }
}
