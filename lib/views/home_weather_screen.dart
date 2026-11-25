import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/clay_styles.dart';
import '../core/utils/weather_code_helper.dart';
import '../models/location_model.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_location_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/hourly_forecast_strip.dart';
import 'widgets/state_feedback_view.dart';
import 'widgets/weather_metrics_grid.dart';

/// Screen utama aplikasi yang memadukan latar langit atmosferik hidup
/// dengan kartu Frosted-Claymorphism dan header scroll-aware.
class HomeWeatherScreen extends StatefulWidget {
  const HomeWeatherScreen({super.key});

  @override
  State<HomeWeatherScreen> createState() => _HomeWeatherScreenState();
}

class _HomeWeatherScreenState extends State<HomeWeatherScreen> {
  late final ScrollController _scrollController;
  bool _showCompactTemp = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.hasClients && _scrollController.offset > 150;
    if (shouldShow != _showCompactTemp) {
      setState(() {
        _showCompactTemp = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _openSearchScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SearchLocationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeatherViewModel>();
    final selected = viewModel.selectedLocation;
    final weather = viewModel.weather;
    final isFavorite = viewModel.isSelectedLocationFavorite;

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
          child: Column(
            children: [
              _AtmosphericHeader(
                location: selected,
                compactTemperature: _showCompactTemp && weather != null
                    ? '${weather.current.temperature2m.round()}°'
                    : null,
                isFavorite: isFavorite,
                isLoading: viewModel.isLoading,
                onToggleFavorite: () => viewModel.toggleFavorite(selected),
                onRefresh: viewModel.loadWeather,
                onOpenSearch: () => _openSearchScreen(context),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.loadWeather,
                  child: _buildBody(context, viewModel, visual),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel viewModel,
    WeatherVisualInfo visual,
  ) {
    if (!viewModel.isInitialized ||
        (viewModel.isLoading && viewModel.weather == null)) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Memuat data cuaca dari Open-Meteo...',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null && viewModel.weather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 48),
          StateFeedbackView(
            icon: Icons.cloud_off_rounded,
            title: 'Gagal Memuat Cuaca',
            message: viewModel.errorMessage!,
            actionLabel: 'Coba Lagi',
            onAction: viewModel.loadWeather,
            isError: true,
            frosted: true,
          ),
        ],
      );
    }

    final weather = viewModel.weather;
    if (weather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 48),
          StateFeedbackView(
            icon: Icons.wb_sunny_outlined,
            title: 'Data Cuaca Kosong',
            message: 'Pilih kota terlebih dahulu untuk melihat prakiraan cuaca.',
            actionLabel: 'Cari Kota',
            onAction: () => _openSearchScreen(context),
            frosted: true,
          ),
        ],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
          children: [
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                ),
              ),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InlineErrorBanner(
                  message: viewModel.errorMessage!,
                  onRetry: viewModel.loadWeather,
                ),
              ),
            if (viewModel.favorites.isNotEmpty) ...[
              _FavoriteQuickSwitchBar(
                favorites: viewModel.favorites,
                selected: viewModel.selectedLocation,
                onSelect: (location) =>
                    viewModel.selectLocation(location, recordHistory: false),
              ),
              const SizedBox(height: 8),
            ],
            CurrentWeatherCard(
              location: viewModel.selectedLocation,
              weather: weather,
              lastUpdated: viewModel.lastUpdated,
            ),
            if (weather.hourly.isNotEmpty) ...[
              const SizedBox(height: 14),
              HourlyForecastStrip(weather: weather),
            ],
            const SizedBox(height: 14),
            DailyForecastList(
              forecasts: weather.daily,
              tintColor: visual.claySurfaceTint,
              timezone: weather.timezone,
            ),
            const SizedBox(height: 14),
            WeatherMetricsGrid(weather: weather),
          ],
        ),
      ),
    );
  }
}

class _AtmosphericHeader extends StatelessWidget {
  const _AtmosphericHeader({
    required this.location,
    required this.compactTemperature,
    required this.isFavorite,
    required this.isLoading,
    required this.onToggleFavorite,
    required this.onRefresh,
    required this.onOpenSearch,
  });

  final LocationModel location;
  final String? compactTemperature;
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRefresh;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (compactTemperature != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            compactTemperature!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.subtitle,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Klaster kapsul Frosted-Clay untuk aksi cepat
              FrostedClayCard(
                borderRadius: 999,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ClusterActionButton(
                      tooltip: isFavorite
                          ? 'Hapus dari Favorit'
                          : 'Simpan ke Favorit',
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor:
                          isFavorite ? const Color(0xFFFF8F73) : Colors.white,
                      onPressed: onToggleFavorite,
                    ),
                    _ClusterActionButton(
                      tooltip: 'Muat Ulang Cuaca',
                      icon: Icons.refresh_rounded,
                      onPressed: isLoading ? null : onRefresh,
                    ),
                    _ClusterActionButton(
                      tooltip: 'Cari Lokasi',
                      icon: Icons.search_rounded,
                      onPressed: onOpenSearch,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClusterActionButton extends StatelessWidget {
  const _ClusterActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: Icon(
        icon,
        size: 20,
        color: onPressed != null
            ? iconColor
            : Colors.white.withValues(alpha: 0.4),
      ),
    );
  }
}

class _FavoriteQuickSwitchBar extends StatelessWidget {
  const _FavoriteQuickSwitchBar({
    required this.favorites,
    required this.selected,
    required this.onSelect,
  });

  final List<LocationModel> favorites;
  final LocationModel selected;
  final ValueChanged<LocationModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = favorites[index];
          final isSelected = city == selected;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                if (!isSelected) {
                  onSelect(city);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isSelected ? 0.45 : 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 13,
                      color: isSelected
                          ? const Color(0xFFFFD875)
                          : Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      city.name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FrostedClayCard(
      borderRadius: 20,
      tintColor: const Color(0xFF9E4438),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD875)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFD875)),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
