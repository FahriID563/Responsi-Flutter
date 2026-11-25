import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/clay_styles.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/location_model.dart';
import '../../models/weather_model.dart';

/// Bagian Hero terbuka di atas langit atmosferik yang menampilkan suhu utama,
/// kondisi cuaca terkini, suhu terasa, dan medali clay 3D.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.location,
    required this.weather,
    this.lastUpdated,
  });

  final LocationModel location;
  final WeatherModel weather;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final visual = WeatherCodeHelper.describe(
      current.weatherCode,
      isDay: current.isDay,
    );

    final maxTemp = weather.todayMaxTemp;
    final minTemp = weather.todayMinTemp;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Medali clay 3D menggelembung untuk ikon cuaca terkini
              ClayContainer(
                borderRadius: 26,
                elevation: 0.75,
                gradientColors: [
                  Color.lerp(visual.medallionColor, Colors.white, 0.35)!,
                  visual.medallionColor,
                ],
                shadowColor: Colors.black.withValues(alpha: 0.25),
                padding: const EdgeInsets.all(14),
                child: Icon(
                  visual.icon,
                  size: 38,
                  color: visual.skyColors.first,
                ),
              ),
              const SizedBox(width: 18),
              Text(
                '${current.temperature2m.round()}°C',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -3.0,
                  height: 1.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 3),
                      blurRadius: 12,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Text(
                visual.label,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (maxTemp != null && minTemp != null)
                Text(
                  '${minTemp.round()}° / ${maxTemp.round()}°',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _HeroTagPill(
                text: 'Terasa ${current.apparentTemperature.round()}°C',
              ),
              _HeroTagPill(
                text: 'WMO ${current.weatherCode}',
              ),
              if (lastUpdated != null)
                _HeroTagPill(
                  text: 'Update ${DateFormat('HH:mm').format(lastUpdated!)}',
                ),
            ],
          ),
          const SizedBox(height: 18),
          // Kartu saran/ringkasan cuaca dinamis berdasarkan data API
          _WeatherAdvisoryCard(weather: weather),
        ],
      ),
    );
  }
}

class _HeroTagPill extends StatelessWidget {
  const _HeroTagPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.94),
        ),
      ),
    );
  }
}

class _WeatherAdvisoryCard extends StatelessWidget {
  const _WeatherAdvisoryCard({required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final advisory = WeatherCodeHelper.buildAdvisory(weather);
    final visual = WeatherCodeHelper.describe(
      weather.current.weatherCode,
      isDay: weather.current.isDay,
    );

    return FrostedClayCard(
      tintColor: visual.claySurfaceTint,
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClayContainer(
            borderRadius: 14,
            elevation: 0.45,
            color: visual.medallionColor,
            padding: const EdgeInsets.all(9),
            child: Icon(
              advisory.icon,
              size: 20,
              color: visual.skyColors.first,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisory.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advisory.message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.38,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
