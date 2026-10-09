import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../admin/models/incident_report.dart';
import '../admin/models/user_profile.dart';
import '../admin/models/app_notification.dart';
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
  final List<AppNotification> _notifications = [];

  UserProfile? _currentUser;

  List<IncidentReport> get reports => _reports;
  List<UserProfile> get users => _users;
  List<IncidentCategory> get categories => _categories;
  List<AreaInfo> get areas => _areas;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;
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
      }

      if (ApiService().token != null && _currentUser != null) {
        final previousIds = _reports.map((r) => r.id).toSet();
        final List<IncidentReport> liveReports = await ApiService().getIncidents();

        debugPrint('[DEBUG GEO MAP] Number of incidents fetched: ${liveReports.length}');

        for (var report in liveReports) {
          if (!previousIds.contains(report.id)) {
            debugPrint('[DEBUG GEO MAP] New incident received: ID ${report.id}, Type: ${report.incidentType}, Lat: ${report.latitude}, Lng: ${report.longitude}');
          }
        }

        _reports.clear();
        _reports.addAll(liveReports);
        _saveReports();

        // Sync Users for Admin Panel
        try {
          final List<UserProfile> liveUsers = await ApiService().getUsers();
          _users.clear();
          _users.addAll(liveUsers);
          _saveUsers();
        } catch (e) {
          debugPrint('[DEBUG GEO ADMIN] Failed to fetch users: $e');
        }

        // Sync Notifications
        try {
          final List<AppNotification> liveNotifications = await ApiService().getNotifications();
          _notifications.clear();
          _notifications.addAll(liveNotifications);
          notifyListeners();
        } catch (e) {
          debugPrint('[DEBUG GEO ADMIN] Failed to fetch notifications: $e');
        }
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DEBUG GEO ADMIN] syncWithBackend exception: $e');
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

  Future<String?> updateUserProfile({
    String? name,
    String? phone,
    String? emergencyContact,
    String? savedAddress,
    String? avatarUrl,
  }) async {
    try {
      final updatedUser = await ApiService().updateProfile(
        name: name,
        phone: phone,
        emergencyContact: emergencyContact,
        savedAddress: savedAddress,
        avatarUrl: avatarUrl,
      );
      _currentUser = updatedUser;
      _authBox.put('currentUser', jsonEncode(updatedUser.toJson()));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to update profile: $e";
    }
  }

  Future<String?> updateUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiService().updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to update password: $e";
    }
  }

  Future<String?> updateUserSettings({
    String? language,
    String? theme,
    bool? notificationsEnabled,
  }) async {
    try {
      final updatedUser = await ApiService().updateSettings(
        language: language,
        theme: theme,
        notificationsEnabled: notificationsEnabled,
      );
      _currentUser = updatedUser;
      _authBox.put('currentUser', jsonEncode(updatedUser.toJson()));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to update settings: $e";
    }
  }

  // Data Manipulation
  Future<void> addReport(IncidentReport report) async {
    debugPrint('[DEBUG GEO] MockDatabaseService.addReport called with lat=${report.latitude}, lng=${report.longitude}');
    try {
      final serverReport = await ApiService().createIncident(
        incidentType: report.incidentType,
        reporterName: report.reporterName,
        location: report.location,
        description: report.description,
        urgencyLevel: report.urgencyLevel,
        latitude: report.latitude,
        longitude: report.longitude,
      );
      debugPrint('[DEBUG GEO] Server returned IncidentReport with lat=${serverReport.latitude}, lng=${serverReport.longitude}');

      // Insert canonical server report to prevent duplicates
      _reports.insert(0, serverReport);
      _updateAreaCount(serverReport.location, 1);
      _saveReports();
    } catch (e) {
      debugPrint('[DEBUG GEO] MockDatabaseService.addReport exception: $e');
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

  Future<void> archiveReport(String reportId) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index].isArchived = true;
      _updateAreaCount(_reports[index].location, -1);
      _saveReports();

      try {
        await ApiService().archiveIncident(reportId);
      } catch (e) {
        debugPrint('[DEBUG GEO] Failed to archive incident on backend: $e');
      }
    }
  }


  Future<void> archiveUser(String userId) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].isArchived = true;
      _saveUsers();
      try {
        await ApiService().archiveUser(userId);
      } catch (e) {
        debugPrint('[DEBUG GEO ADMIN] Failed to archive user on backend: $e');
      }
    }
  }

  Future<void> toggleUserActive(String userId) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final newStatus = !_users[index].isActive;
      _users[index].isActive = newStatus;
      _saveUsers();
      try {
        await ApiService().updateUserStatus(userId, newStatus ? 'active' : 'inactive');
      } catch (e) {
        debugPrint('[DEBUG GEO ADMIN] Failed to toggle user status on backend: $e');
      }
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(role: newRole);
      _saveUsers();
      try {
        await ApiService().updateUserRole(userId, newRole);
      } catch (e) {
        debugPrint('[DEBUG GEO ADMIN] Failed to update user role on backend: $e');
      }
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
      try {
        await ApiService().markNotificationAsRead(notificationId);
      } catch (e) {
        debugPrint('[DEBUG GEO ADMIN] Failed to mark notification read: $e');
      }
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
    try {
      await ApiService().markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('[DEBUG GEO ADMIN] Failed to mark all notifications read: $e');
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
