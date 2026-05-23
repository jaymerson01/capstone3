import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class SharedIncidentDatabase extends ChangeNotifier {
  static final SharedIncidentDatabase _instance = SharedIncidentDatabase._internal();
  factory SharedIncidentDatabase() => _instance;
  SharedIncidentDatabase._internal();

  Box? _box;
  bool _initialized = false;
  
  // In-memory fallback to guarantee 100% safety in widget tests or filesystem locks
  final Map<String, Map<String, dynamic>> _inMemoryDb = {};

  Future<void> init() async {
    if (_initialized) return;
    try {
      // Don't initialize native hive path providers inside running test configurations
      bool isTest = Platform.environment.containsKey('FLUTTER_TEST');
      if (!isTest) {
        await Hive.initFlutter();
        _box = await Hive.openBox('shared_incidents');
      }
    } catch (e) {
      debugPrint("Hive initialization failed, falling back to memory database: $e");
    }
    _initialized = true;
    
    if (isEmpty) {
      await _seedInitialData();
    }
  }

  bool get isEmpty {
    if (_box != null) return _box!.isEmpty;
    return _inMemoryDb.isEmpty;
  }

  // Get all raw JSON incidents
  List<Map<String, dynamic>> getRawIncidents() {
    if (_box != null) {
      return _box!.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return _inMemoryDb.values.toList();
  }

  // Save or update an incident report
  Future<void> saveIncident(Map<String, dynamic> incidentJson) async {
    final String id = incidentJson['id'] as String;
    if (_box != null) {
      await _box!.put(id, incidentJson);
    } else {
      _inMemoryDb[id] = incidentJson;
    }
    notifyListeners();
  }

  // Delete an incident
  Future<void> deleteIncident(String id) async {
    if (_box != null) {
      await _box!.delete(id);
    } else {
      _inMemoryDb.remove(id);
    }
    notifyListeners();
  }

  // Seed default dataset representing combined original pools
  Future<void> _seedInitialData() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> seeds = [
      {
        'id': 'REP-001',
        'title': 'Theft in Barangay Moonwalk',
        'reporterName': 'Juan Dela Cruz',
        'location': 'Barangay Moonwalk',
        'description': 'A bicycle was stolen from the garage at around 2 PM. CCTV footage is available.',
        'latitude': 14.4796,
        'longitude': 121.0196,
        'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
        'imagePath': 'assets/images/logo.png',
        'status': 'pending',
        'severity': 'Medium',
      },
      {
        'id': 'REP-002',
        'title': 'Accident in Barangay Jacinto',
        'reporterName': 'Maria Santos',
        'location': 'Barangay Jacinto',
        'description': 'Minor collision between a motorcycle and a sedan near the intersection. Traffic is backed up.',
        'latitude': 14.4820,
        'longitude': 121.0150,
        'timestamp': now.subtract(const Duration(days: 2)).toIso8601String(),
        'imagePath': 'assets/images/logo.png',
        'status': 'inProgress',
        'severity': 'Medium',
      },
      {
        'id': 'REP-003',
        'title': 'House Fire on St. Francis Compound',
        'reporterName': 'Pedro Penduko',
        'location': 'St. Francis Compound, Moonwalk',
        'description': 'A severe fire broke out on the residential building inside St. Francis Compound. Local fire truck dispatched.',
        'latitude': 14.4796,
        'longitude': 121.0196,
        'timestamp': now.subtract(const Duration(minutes: 5)).toIso8601String(),
        'imagePath': 'assets/images/logo.png',
        'status': 'solved',
        'severity': 'High',
      },
      {
        'id': 'REP-004',
        'title': 'Violence at sports court',
        'reporterName': 'Ana Go',
        'location': 'Barangay Doang Batang',
        'description': 'Physical altercation between two individuals at the local sports court. Barangay tanods intervened.',
        'latitude': 14.4780,
        'longitude': 121.0120,
        'timestamp': now.subtract(const Duration(days: 5)).toIso8601String(),
        'imagePath': 'assets/images/logo.png',
        'status': 'pending',
        'severity': 'High',
      },
      {
        'id': 'REP-005',
        'title': 'Suspicious Vehicle Parked',
        'reporterName': 'John Doe',
        'location': 'Barangay Pepa Compound',
        'description': 'An unfamiliar vehicle has been parked with engine running for over 3 hours.',
        'latitude': 14.4850,
        'longitude': 121.0200,
        'timestamp': now.subtract(const Duration(days: 6)).toIso8601String(),
        'imagePath': 'assets/images/logo.png',
        'status': 'solved',
        'severity': 'Low',
      },
    ];

    for (var seed in seeds) {
      await saveIncident(seed);
    }
  }
}
