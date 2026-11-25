import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/clay_styles.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/weather_model.dart';

/// Strip perkiraan cuaca 24 jam berikutnya yang dapat di-scroll horizontal.
class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({
    super.key,
    required this.weather,
  });

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final hourly = weather.hourly;
    if (hourly.isEmpty) return const SizedBox.shrink();

    final visual = WeatherCodeHelper.describe(
      weather.current.weatherCode,
      isDay: weather.current.isDay,
    );

    return FrostedClayCard(
      tintColor: visual.claySurfaceTint,
      borderRadius: 26,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.78),
              ),
              const SizedBox(width: 7),
              Text(
                '24 Jam Berikutnya',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = hourly[index];
                final isNow = index == 0;
                final hourVisual = WeatherCodeHelper.describe(item.weatherCode);
                final timeLabel =
                    isNow ? 'Sekarang' : DateFormat('HH:mm').format(item.time);

                return Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isNow
                        ? Colors.white.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: isNow ? 0.38 : 0.14,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hourVisual.icon,
                            size: 22,
                            color: hourVisual.medallionColor,
                          ),
                          if (item.precipitationProbability > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${item.precipitationProbability}%',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9BE4FF),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${item.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
