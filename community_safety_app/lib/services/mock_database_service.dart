import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../admin/models/incident_report.dart';
import '../admin/models/user_profile.dart';
import '../admin/models/category.dart';
import '../admin/models/area.dart';

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
  
  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lockouts = {};
  
  List<IncidentReport> get reports => _reports;
  List<UserProfile> get users => _users;
  List<IncidentCategory> get categories => _categories;
  List<AreaInfo> get areas => _areas;
  UserProfile? get currentUser => _currentUser;

  Future<void> init() async {
    _dataBox = await Hive.openBox('appData');
    _authBox = Hive.box('auth');
    _loadData();
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
    
    final String? attemptsJson = _dataBox.get('failedAttempts');
    if (attemptsJson != null) {
      _failedAttempts.clear();
      _failedAttempts.addAll(Map<String, int>.from(jsonDecode(attemptsJson)));
    }
    
    final String? lockoutsJson = _dataBox.get('lockouts');
    if (lockoutsJson != null) {
      final Map decoded = jsonDecode(lockoutsJson);
      _lockouts.clear();
      decoded.forEach((k, v) {
        _lockouts[k] = DateTime.parse(v);
      });
    }
    
    notifyListeners();
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
  
  void _saveSecurityState() {
    _dataBox.put('failedAttempts', jsonEncode(_failedAttempts));
    final lockoutsMap = {};
    _lockouts.forEach((k, v) => lockoutsMap[k] = v.toIso8601String());
    _dataBox.put('lockouts', jsonEncode(lockoutsMap));
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

  // Auth Methods
  Future<String?> signUp(String name, String email, String password, String role) async {
    // Basic duplicate check (case-insensitive)
    final normalizedEmail = email.toLowerCase().trim();
    if (_users.any((u) => u.email.toLowerCase().trim() == normalizedEmail)) {
      return "Email is already registered.";
    }
    
    final newUser = UserProfile(
      id: "USR-${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      email: normalizedEmail,
      role: role,
      password: password,
      isActive: true,
      isArchived: false,
    );
    _users.add(newUser);
    _saveUsers();
    
    notifyListeners();
    return null; // success
  }

  DateTime? getLockoutExpiration(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    if (_lockouts.containsKey(normalizedEmail)) {
      final lockoutTime = _lockouts[normalizedEmail]!;
      final expiration = lockoutTime.add(const Duration(minutes: 15));
      if (DateTime.now().isBefore(expiration)) {
        return expiration;
      }
    }
    return null;
  }

  Future<String?> login(String email, String password) async {
    final normalizedEmail = email.toLowerCase().trim();
    
    // Check if account is locked
    if (_lockouts.containsKey(normalizedEmail)) {
      final lockoutTime = _lockouts[normalizedEmail]!;
      if (DateTime.now().difference(lockoutTime).inMinutes < 15) {
        return "Your account has been locked due to too many failed login attempts. Please try again in 15 minutes.";
      } else {
        // Lockout expired
        _lockouts.remove(normalizedEmail);
        _failedAttempts[normalizedEmail] = 0;
        _saveSecurityState();
      }
    }

    try {
      final user = _users.firstWhere((u) => u.email.toLowerCase().trim() == normalizedEmail && !u.isArchived);
      
      if (user.password != password) {
        throw Exception("Invalid password");
      }
      
      _currentUser = user;
      _authBox.put('currentUser', jsonEncode(user.toJson()));
      _authBox.put('isLoggedIn', true);
      
      // Reset failed attempts on success
      _failedAttempts.remove(normalizedEmail);
      _lockouts.remove(normalizedEmail);
      _saveSecurityState();
      
      notifyListeners();
      return null; // success
    } catch (e) {
      // User not found or incorrect password simulation
      final attempts = (_failedAttempts[normalizedEmail] ?? 0) + 1;
      _failedAttempts[normalizedEmail] = attempts;
      
      if (attempts >= 5) {
        _lockouts[normalizedEmail] = DateTime.now();
        _saveSecurityState();
        return "Your account has been locked due to too many failed login attempts. Please try again in 15 minutes.";
      }
      
      _saveSecurityState();
      return "Invalid email or password.";
    }
  }

  void logout() {
    _currentUser = null;
    _authBox.delete('currentUser');
    _authBox.put('isLoggedIn', false);
    notifyListeners();
  }
  
  // Data Manipulation
  void addReport(IncidentReport report) {
    _reports.insert(0, report);
    _updateAreaCount(report.location, 1);
    _saveReports();
  }
  
  void updateReportStatus(String reportId, IncidentStatus newStatus) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index].status = newStatus;
      _saveReports();
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
