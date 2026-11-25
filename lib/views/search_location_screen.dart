import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/clay_styles.dart';
import '../core/utils/weather_code_helper.dart';
import '../models/location_model.dart';
import '../viewmodels/location_search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/state_feedback_view.dart';

/// Screen pencarian kota melalui Open-Meteo Geocoding API dengan tampilan
/// Atmospheric Frosted-Clay yang senada dengan HomeWeatherScreen.
class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<LocationSearchViewModel>().query;
    _searchController = TextEditingController(text: initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectLocation(
    LocationModel location, {
    bool recordHistory = true,
  }) async {
    final weatherVm = context.read<WeatherViewModel>();
    Navigator.of(context).pop();
    await weatherVm.selectLocation(location, recordHistory: recordHistory);
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<LocationSearchViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();
    final weather = weatherVm.weather;

    final visual = weather != null
        ? WeatherCodeHelper.describe(
            weather.current.weatherCode,
            isDay: weather.current.isDay,
          )
        : WeatherCodeHelper.describe(2);

    return Scaffold(
      body: AtmosphericWeatherBackdrop(
        visual: visual,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        ClayIconButton(
                          tooltip: 'Kembali',
                          icon: Icons.arrow_back_rounded,
                          frosted: true,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cari & Kelola Lokasi',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kota aktif: ${weatherVm.selectedLocation.name}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: FrostedClayCard(
                      tintColor: visual.claySurfaceTint,
                      borderRadius: 24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: Colors.white,
                        onChanged: searchVm.onQueryChanged,
                        onSubmitted: (value) => searchVm.search(value),
                        decoration: InputDecoration(
                          hintText:
                              'Masukkan nama kota (contoh: Yogyakarta, Tokyo)',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  tooltip: 'Hapus kata kunci',
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    searchVm.clearSearch();
                                  },
                                ),
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: ClayIconButton(
                                  tooltip: 'Cari',
                                  size: 38,
                                  icon: Icons.arrow_forward_rounded,
                                  iconColor: visual.skyColors.first,
                                  backgroundColor: visual.medallionColor,
                                  onPressed: () =>
                                      searchVm.search(_searchController.text),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildContent(
                      context,
                      searchVm,
                      weatherVm,
                      visual,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LocationSearchViewModel searchVm,
    WeatherViewModel weatherVm,
    WeatherVisualInfo visual,
  ) {
    if (searchVm.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 14),
            Text(
              'Mencari kota di Open-Meteo Geocoding API...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (searchVm.errorMessage != null) {
      return StateFeedbackView(
        icon: Icons.wifi_off_rounded,
        title: 'Pencarian Gagal',
        message: searchVm.errorMessage!,
        actionLabel: 'Coba Lagi',
        onAction: () => searchVm.search(_searchController.text),
        isError: true,
        frosted: true,
      );
    }

    if (searchVm.hasSearched) {
      if (searchVm.results.isEmpty) {
        return StateFeedbackView(
          icon: Icons.location_searching_rounded,
          title: 'Lokasi Tidak Ditemukan',
          message:
              'Tidak ada hasil untuk "${searchVm.query}". Coba gunakan nama kota lain.',
          frosted: true,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        itemCount: searchVm.results.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                'Hasil Pencarian (${searchVm.results.length})',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            );
          }

          final location = searchVm.results[index - 1];
          return _LocationTile(
            location: location,
            visual: visual,
            isSelected: weatherVm.selectedLocation == location,
            isFavorite: weatherVm.isFavorite(location),
            onTap: () => _selectLocation(location, recordHistory: true),
            onToggleFavorite: () => weatherVm.toggleFavorite(location),
          );
        },
      );
    }

    return _SavedLocationsSection(
      weatherVm: weatherVm,
      visual: visual,
      onSelectLocation: (loc, {required bool recordHistory}) =>
          _selectLocation(loc, recordHistory: recordHistory),
    );
  }
}

class _SavedLocationsSection extends StatelessWidget {
  const _SavedLocationsSection({
    required this.weatherVm,
    required this.visual,
    required this.onSelectLocation,
  });

  final WeatherViewModel weatherVm;
  final WeatherVisualInfo visual;
  final Future<void> Function(LocationModel location, {required bool recordHistory})
      onSelectLocation;

  @override
  Widget build(BuildContext context) {
    final favorites = weatherVm.favorites;
    final history = weatherVm.searchHistory;

    if (favorites.isEmpty && history.isEmpty) {
      return const StateFeedbackView(
        icon: Icons.explore_outlined,
        title: 'Mulai Cari Kota',
        message:
            'Ketik nama kota di kolom pencarian di atas untuk melihat cuaca atau menyimpannya ke daftar favorit.',
        frosted: true,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        if (favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Lokasi Favorit (${favorites.length})',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...favorites.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LocationTile(
                location: loc,
                visual: visual,
                isSelected: weatherVm.selectedLocation == loc,
                isFavorite: true,
                onTap: () => onSelectLocation(loc, recordHistory: false),
                onToggleFavorite: () => weatherVm.toggleFavorite(loc),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Riwayat Pencarian (${history.length})',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: weatherVm.clearHistory,
                style: TextButton.styleFrom(
                  foregroundColor: visual.medallionColor,
                ),
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: const Text('Bersihkan'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...history.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LocationTile(
                location: loc,
                visual: visual,
                isSelected: weatherVm.selectedLocation == loc,
                isFavorite: weatherVm.isFavorite(loc),
                leadingIcon: Icons.history_rounded,
                onTap: () => onSelectLocation(loc, recordHistory: true),
                onToggleFavorite: () => weatherVm.toggleFavorite(loc),
                onRemoveHistory: () => weatherVm.removeHistoryItem(loc),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.visual,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.leadingIcon = Icons.location_on_outlined,
    this.onRemoveHistory,
  });

  final LocationModel location;
  final WeatherVisualInfo visual;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final IconData leadingIcon;
  final VoidCallback? onRemoveHistory;

  @override
  Widget build(BuildContext context) {
    return FrostedClayCard(
      tintColor: isSelected
          ? Color.lerp(visual.claySurfaceTint, Colors.white, 0.25)
          : visual.claySurfaceTint,
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onTap: onTap,
        leading: ClayContainer(
          borderRadius: 16,
          elevation: 0.45,
          color: isSelected
              ? visual.medallionColor
              : Colors.white.withValues(alpha: 0.22),
          shadowColor: Colors.black.withValues(alpha: 0.16),
          padding: const EdgeInsets.all(10),
          child: Icon(
            leadingIcon,
            color: isSelected ? visual.skyColors.first : Colors.white,
            size: 21,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                location.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: visual.medallionColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Aktif',
                  style: TextStyle(
                    color: visual.skyColors.first,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${location.subtitle} • ${location.formattedCoordinates}',
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isFavorite ? 'Hapus favorit' : 'Simpan favorit',
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? const Color(0xFFFF8F73)
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
            if (onRemoveHistory != null)
              IconButton(
                tooltip: 'Hapus dari riwayat',
                onPressed: onRemoveHistory,
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
