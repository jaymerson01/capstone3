import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:community_safety_app/core/services/fcm_service.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/utils/critical_alert_tracker.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// Warns a resident when a new critical report appears near them while the
/// app is open: a phone notification plus a banner that opens the report.
/// "Near" is measured from the phone's location when the resident has
/// already allowed it, otherwise from their registered area.
class NearbyIncidentAlerts extends StatefulWidget {
  const NearbyIncidentAlerts({
    super.key,
    required this.user,
    required this.child,
    this.navigatorKey,
  });

  final UserEntity user;
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  /// How close a report must be to count as near.
  static const double radiusMeters = 500;

  /// Of the [fresh] critical reports, those someone else filed within
  /// [radiusMeters] of ([latitude], [longitude]), each with its distance.
  @visibleForTesting
  static List<(IncidentEntity, double)> near(
    List<IncidentEntity> fresh, {
    required String userId,
    required double latitude,
    required double longitude,
  }) {
    return [
      for (final incident in fresh)
        if (incident.reporterId != userId && incident.latitude != 0 && incident.longitude != 0)
          (incident, Geolocator.distanceBetween(latitude, longitude, incident.latitude, incident.longitude)),
    ].where((match) => match.$2 <= radiusMeters).toList();
  }

  @override
  State<NearbyIncidentAlerts> createState() => _NearbyIncidentAlertsState();
}

class _NearbyIncidentAlertsState extends State<NearbyIncidentAlerts> {
  final CriticalAlertTracker _tracker = CriticalAlertTracker();
  StreamSubscription<IncidentState>? _incidents;
  Timer? _refreshPosition;
  (double, double)? _here;

  @override
  void initState() {
    super.initState();
    _here = _registeredArea();
    _updatePosition();
    _refreshPosition = Timer.periodic(const Duration(minutes: 10), (_) => _updatePosition());
    final bloc = context.read<IncidentBloc>();
    _incidents = bloc.stream.listen(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check(bloc.state));
  }

  @override
  void dispose() {
    _incidents?.cancel();
    _refreshPosition?.cancel();
    super.dispose();
  }

  (double, double)? _registeredArea() {
    final area = widget.user.barangayArea;
    final centroid = BarangaySectorHelper.sectorCentroids.where((c) => c['sector'] == area).firstOrNull;
    return centroid == null
        ? null
        : ((centroid['lat'] as num).toDouble(), (centroid['lng'] as num).toDouble());
  }

  /// Uses the phone's location only if the resident already allowed it, so
  /// this never pops up a permission request on its own.
  Future<void> _updatePosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) return;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 15));
      _here = (position.latitude, position.longitude);
    } catch (e) {
      debugPrint('[NearbyAlerts] Location unavailable, using the registered area: $e');
    }
  }

  void _check(IncidentState state) {
    if (state is! IncidentLoaded) return;
    final fresh = _tracker.take(state.incidents);
    final here = _here;
    if (fresh.isEmpty || here == null) return;
    for (final (incident, meters) in NearbyIncidentAlerts.near(
      fresh,
      userId: widget.user.id,
      latitude: here.$1,
      longitude: here.$2,
    )) {
      _alert(incident, meters);
    }
  }

  void _alert(IncidentEntity incident, double meters) {
    final navContext = widget.navigatorKey?.currentContext ?? context;
    final l10n = AppLocalizations.of(navContext);
    final title = l10n.nearbyAlertTitle;
    final body = l10n.nearbyAlertBody(
      LocalizedLabels.category(navContext, incident.category),
      (meters / 10).round() * 10,
      incident.areaSector ?? incident.resolvedAddress ?? 'Barangay Moonwalk',
    );

    try {
      sl<FCMService>().showLocalNotification(title: title, body: body, incidentId: incident.id);
    } catch (e) {
      debugPrint('[NearbyAlerts] No phone notification: $e');
    }

    ScaffoldMessenger.maybeOf(navContext)?.showSnackBar(SnackBar(
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 12),
      content: Text('$title\n$body', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      action: SnackBarAction(
        label: l10n.nearbyAlertView,
        textColor: Colors.white,
        onPressed: () => Navigator.of(navContext).push(
          MaterialPageRoute(builder: (_) => IncidentDetailPage(initialIncident: incident)),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
