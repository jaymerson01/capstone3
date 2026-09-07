import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../config/api_config.dart';
import 'api_exception.dart';
import '../admin/models/incident_report.dart';
import '../admin/models/user_profile.dart';
import '../admin/models/app_notification.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _baseUrl => ApiConfig.baseUrl;

  String? get token {
    if (Hive.isBoxOpen('auth')) {
      return Hive.box('auth').get('jwtToken');
    }
    return null;
  }

  Future<void> setToken(String? newToken) async {
    final box = Hive.box('auth');
    if (newToken == null) {
      await box.delete('jwtToken');
    } else {
      await box.put('jwtToken', newToken);
    }
  }

  Map<String, String> _getHeaders({bool requireAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    final errorMessage = jsonBody is Map && jsonBody.containsKey('error')
        ? jsonBody['error']
        : null;

    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonBody;
      case 400:
        throw ApiException(errorMessage ?? 'Bad request payload.', 400);
      case 401:
        setToken(null);
        throw ApiException(errorMessage ?? 'Session expired or invalid credentials.', 401);
      case 403:
        throw ApiException(errorMessage ?? 'Access denied.', 403);
      case 409:
        throw ApiException(errorMessage ?? 'Email is already registered.', 409);
      case 500:
        throw ApiException(errorMessage ?? 'Internal server error. Please try again.', 500);
      default:
        throw ApiException(errorMessage ?? 'Unexpected error occurred (${response.statusCode}).', response.statusCode);
    }
  }

  Future<dynamic> _handleRequest(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn().timeout(ApiConfig.timeoutDuration);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your connection.');
    } on SocketException {
      throw ApiException('Unable to connect to ResQ server at $_baseUrl');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Auth Endpoints
  Future<UserProfile> signUp(String name, String email, String password) async {
    final data = await _handleRequest(() => http.post(
          Uri.parse('$_baseUrl/auth/signup'),
          headers: _getHeaders(),
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'role': 'user',
          }),
        ));

    final String newToken = data['token'];
    await setToken(newToken);
    return UserProfile.fromJson(data['user']);
  }

  Future<UserProfile> login(String email, String password) async {
    final data = await _handleRequest(() => http.post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: _getHeaders(),
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ));

    final String newToken = data['token'];
    await setToken(newToken);
    return UserProfile.fromJson(data['user']);
  }

  Future<UserProfile?> getCurrentUser() async {
    if (token == null) return null;

    try {
      final data = await _handleRequest(() => http.get(
            Uri.parse('$_baseUrl/auth/me'),
            headers: _getHeaders(requireAuth: true),
          ));

      return UserProfile.fromJson(data['user']);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await setToken(null);
      }
      return null;
    }
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? phone,
    String? emergencyContact,
    String? savedAddress,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (emergencyContact != null) body['emergencyContact'] = emergencyContact;
    if (savedAddress != null) body['savedAddress'] = savedAddress;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    final data = await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/auth/profile'),
          headers: _getHeaders(requireAuth: true),
          body: jsonEncode(body),
        ));

    return UserProfile.fromJson(data['user']);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/auth/password'),
          headers: _getHeaders(requireAuth: true),
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        ));
  }

  Future<UserProfile> updateSettings({
    String? language,
    String? theme,
    bool? notificationsEnabled,
  }) async {
    final body = <String, dynamic>{};
    if (language != null) body['language'] = language;
    if (theme != null) body['theme'] = theme;
    if (notificationsEnabled != null) body['notificationsEnabled'] = notificationsEnabled;

    final data = await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/auth/settings'),
          headers: _getHeaders(requireAuth: true),
          body: jsonEncode(body),
        ));

    return UserProfile.fromJson(data['user']);
  }

  // Incident Endpoints
  Future<IncidentReport> createIncident({
    required String incidentType,
    required String reporterName,
    required String location,
    required String description,
    required String urgencyLevel,
    double? latitude,
    double? longitude,
  }) async {
    final payload = {
      'incidentType': incidentType,
      'reporterName': reporterName,
      'location': location,
      'description': description,
      'urgencyLevel': urgencyLevel,
      'latitude': latitude,
      'longitude': longitude,
    };
    debugPrint('[DEBUG GEO] ApiService.createIncident payload: lat=$latitude, lng=$longitude, json=${jsonEncode(payload)}');

    final data = await _handleRequest(() => http.post(
          Uri.parse('$_baseUrl/incidents'),
          headers: _getHeaders(requireAuth: true),
          body: jsonEncode(payload),
        ));

    debugPrint('[DEBUG GEO] ApiService.createIncident response: ${data['incident']}');
    return IncidentReport.fromJson(data['incident']);
  }

  Future<List<IncidentReport>> getMyIncidents() async {
    final data = await _handleRequest(() => http.get(
          Uri.parse('$_baseUrl/incidents/my-reports'),
          headers: _getHeaders(requireAuth: true),
        ));

    final List dynamicList = data['incidents'] ?? [];
    return dynamicList.map((e) => IncidentReport.fromJson(e)).toList();
  }

  Future<List<IncidentReport>> getIncidents({bool showArchived = false}) async {
    final uri = Uri.parse('$_baseUrl/incidents').replace(
      queryParameters: {'showArchived': showArchived.toString()},
    );

    final data = await _handleRequest(() => http.get(
          uri,
          headers: _getHeaders(requireAuth: true),
        ));

    final List dynamicList = data['incidents'] ?? [];
    return dynamicList.map((e) => IncidentReport.fromJson(e)).toList();
  }

  Future<IncidentReport> updateIncidentStatus(String reportId, String status) async {
    final data = await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/incidents/$reportId/status'),
          headers: _getHeaders(requireAuth: true),
          body: jsonEncode({'status': status}),
        ));

    return IncidentReport.fromJson(data['incident']);
  }

  Future<IncidentReport> archiveIncident(String reportId) async {
    final data = await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/incidents/$reportId/archive'),
          headers: _getHeaders(requireAuth: true),
        ));

    return IncidentReport.fromJson(data['incident']);
  }

  // User Management Endpoints
  Future<List<UserProfile>> getUsers() async {
    final data = await _handleRequest(() => http.get(
          Uri.parse('$_baseUrl/auth/users'),
          headers: _getHeaders(requireAuth: true),
        ));

    final List dynamicList = data['users'] ?? [];
    return dynamicList.map((e) => UserProfile.fromJson(e)).toList();
  }

  Future<UserProfile> updateUserStatus(String userId, String status) async {
    final data = await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/auth/users/$userId/status'),
          headers: _getHeaders(requireAuth: true),
          body: jsonEncode({'status': status}),
        ));

    return UserProfile.fromJson(data['user']);
  }

  Future<UserProfile> updateUserRole(String userId, String role) async {
    final data = await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/auth/users/$userId/role'),
          headers: _getHeaders(requireAuth: true),
          body: jsonEncode({'role': role}),
        ));

    return UserProfile.fromJson(data['user']);
  }

  Future<UserProfile> archiveUser(String userId) async {
    final data = await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/auth/users/$userId/archive'),
          headers: _getHeaders(requireAuth: true),
        ));

    return UserProfile.fromJson(data['user']);
  }

  // Notification Endpoints
  Future<List<AppNotification>> getNotifications() async {
    final data = await _handleRequest(() => http.get(
          Uri.parse('$_baseUrl/notifications'),
          headers: _getHeaders(requireAuth: true),
        ));

    final List dynamicList = data['notifications'] ?? [];
    return dynamicList.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/notifications/$id/read'),
          headers: _getHeaders(requireAuth: true),
        ));
  }

  Future<void> markAllNotificationsAsRead() async {
    await _handleRequest(() => http.patch(
          Uri.parse('$_baseUrl/notifications/read-all'),
          headers: _getHeaders(requireAuth: true),
        ));
  }
}


