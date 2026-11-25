import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/clay_styles.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/weather_model.dart';

/// Daftar perkiraan cuaca 7 hari ke depan bergaya Frosted-Clay dengan
/// peluang hujan, kondisi cuaca, dan bar rentang suhu visual.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.forecasts,
    this.tintColor,
    this.timezone,
  });

  final List<DailyForecast> forecasts;
  final Color? tintColor;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return FrostedClayCard(
        tintColor: tintColor,
        borderRadius: 26,
        padding: const EdgeInsets.all(20),
        child: const Text(
          'Data perkiraan harian belum tersedia.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final globalMin = forecasts
        .map((f) => f.temperatureMin)
        .reduce((a, b) => a < b ? a : b);
    final globalMax = forecasts
        .map((f) => f.temperatureMax)
        .reduce((a, b) => a > b ? a : b);

    return FrostedClayCard(
      tintColor: tintColor,
      borderRadius: 26,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.78),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Perkiraan 7 Hari ke Depan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              if (timezone != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    timezone!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(forecasts.length, (index) {
            final item = forecasts[index];
            final visual = WeatherCodeHelper.describe(item.weatherCode);
            final dayLabel = _formatDayLabel(item.date, index);

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < forecasts.length - 1 ? 8 : 0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: index == 0 ? 0.28 : 0.10,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        dayLabel,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            visual.icon,
                            size: 20,
                            color: visual.medallionColor,
                          ),
                          if (item.precipitationProbabilityMax > 0)
                            Text(
                              '${item.precipitationProbabilityMax}%',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9BE4FF),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: Text(
                        visual.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _TemperatureRangeBar(
                        minTemp: item.temperatureMin,
                        maxTemp: item.temperatureMax,
                        globalMin: globalMin,
                        globalMax: globalMax,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${item.temperatureMin.round()}° / ${item.temperatureMax.round()}°',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDayLabel(DateTime date, int index) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';
    return DateFormat('d MMM').format(date);
  }
}

class _TemperatureRangeBar extends StatelessWidget {
  const _TemperatureRangeBar({
    required this.minTemp,
    required this.maxTemp,
    required this.globalMin,
    required this.globalMax,
  });

  final double minTemp;
  final double maxTemp;
  final double globalMin;
  final double globalMax;

  @override
  Widget build(BuildContext context) {
    final span =
        (globalMax - globalMin).abs() < 0.5 ? 1.0 : globalMax - globalMin;
    final startFrac = ((minTemp - globalMin) / span).clamp(0.0, 0.85);
    final endFrac =
        ((maxTemp - globalMin) / span).clamp(startFrac + 0.15, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        if (trackWidth < 20) return const SizedBox.shrink();

        final leftOffset = trackWidth * startFrac;
        final barWidth =
            (trackWidth * (endFrac - startFrac)).clamp(8.0, trackWidth);

        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              Positioned(
                left: leftOffset,
                width: barWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD875),
                        Color(0xFFFF8F73),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
