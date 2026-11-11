import 'package:flutter/material.dart';
import 'package:community_safety_app/core/services/app_coordinate.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// A search box for the maps, like Google Maps': Barangay Moonwalk's areas
/// appear as you type, and Search looks up streets and places inside
/// Moonwalk. Choosing a result calls [onSelected].
class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    required this.onSelected,
    this.autofocus = false,
    this.search,
  });

  final ValueChanged<AppCoordinate> onSelected;
  final bool autofocus;

  /// Looks up addresses; defaults to [LocationService.searchPlaces].
  final Future<List<AppCoordinate>> Function(String query)? search;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _focus = FocusNode();

  List<AppCoordinate> _online = const [];
  String? _searchedFor;
  bool _searching = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Moonwalk's own areas, matched as you type (no internet needed).
  List<AppCoordinate> get _areaMatches {
    final q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return [
      for (final area in BarangaySectorHelper.sectorCentroids)
        if ((area['sector'] as String).toLowerCase().contains(q) ||
            (area['address'] as String).toLowerCase().contains(q))
          AppCoordinate(
            latitude: (area['lat'] as num).toDouble(),
            longitude: (area['lng'] as num).toDouble(),
            address: area['address'] as String,
            sector: area['sector'] as String,
          ),
    ].take(4).toList();
  }

  Future<void> _searchOnline() async {
    final q = _query.text.trim();
    if (q.length < 3 || _searching) return;
    setState(() {
      _searching = true;
      _failed = false;
    });
    try {
      final results = await (widget.search ?? sl<LocationService>().searchPlaces)(q);
      if (!mounted) return;
      setState(() {
        _online = results;
        _searchedFor = q;
      });
    } catch (e) {
      debugPrint('[MapSearchBar] $e');
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _choose(AppCoordinate place) {
    _focus.unfocus();
    setState(() {
      _query.text = place.address ?? place.sector ?? '';
      _online = const [];
      _searchedFor = null;
    });
    widget.onSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = _query.text.trim();
    final areas = _areaMatches;
    final searchedThis = _searchedFor == q;
    // Results stay up after Search closes the keyboard, until one is chosen.
    final showList = q.isNotEmpty && (_focus.hasFocus || searchedThis || _failed);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.surface,
          elevation: 4,
          shadowColor: Colors.black38,
          borderRadius: BorderRadius.circular(16),
          child: TextField(
            key: const Key('map-search'),
            controller: _query,
            focusNode: _focus,
            autofocus: widget.autofocus,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: AppColors.textDark, fontSize: 14.5, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: l10n.mapSearchHint,
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : (q.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.mapSearchClear,
                          icon: Icon(Icons.close_rounded, color: AppColors.textLight),
                          onPressed: () => setState(() {
                            _query.clear();
                            _online = const [];
                            _searchedFor = null;
                          }),
                        )),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (_) => setState(() => _failed = false),
            onSubmitted: (_) => _searchOnline(),
          ),
        ),
        if (showList) ...[
          const SizedBox(height: 6),
          Material(
            color: AppColors.surface,
            elevation: 6,
            shadowColor: Colors.black38,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final place in areas)
                    _ResultTile(icon: Icons.holiday_village_outlined, place: place, onTap: () => _choose(place)),
                  for (final place in _online)
                    _ResultTile(icon: Icons.place_outlined, place: place, onTap: () => _choose(place)),
                  if (!searchedThis && q.length >= 3)
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.travel_explore_rounded, color: AppColors.primary),
                      title: Text(
                        l10n.mapSearchOnline(q),
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                      onTap: _searchOnline,
                    ),
                  if (_failed)
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.wifi_off_rounded, color: AppColors.danger),
                      title: Text(l10n.mapSearchFailed, style: TextStyle(color: AppColors.textDark)),
                    )
                  else if (searchedThis && _online.isEmpty && areas.isEmpty)
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.search_off_rounded, color: AppColors.textLight),
                      title: Text(l10n.mapSearchNoResults, style: TextStyle(color: AppColors.textDark)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.icon, required this.place, required this.onTap});

  final IconData icon;
  final AppCoordinate place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.textLight),
      title: Text(
        place.address ?? place.sector ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
      ),
      subtitle: place.sector == null
          ? null
          : Text(place.sector!, style: TextStyle(color: AppColors.textLight, fontSize: 12)),
      onTap: onTap,
    );
  }
}
