import '../models/incident_model.dart';

abstract class LocalCacheDatasource {
  /// Caches a single newly reported incident locally during network outages.
  Future<void> cacheIncidentOffline(IncidentModel incident);

  /// Caches a bulk list of retrieved active incidents for fast local rendering.
  Future<void> cacheIncidents(List<IncidentModel> incidents);

  /// Retrieves all incidents currently stored in the local cache box.
  Future<List<IncidentModel>> getCachedIncidents();

  /// Removes cached data that has been successfully synchronized to the cloud.
  Future<void> clearSyncedCache(List<String> incidentIds);

  /// Retrieves list of unsynced incident reports queue.
  Future<List<IncidentModel>> getUnsyncedIncidents();
}
