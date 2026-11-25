import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/clay_styles.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/weather_model.dart';

/// Grid detail metrik cuaca bergaya Frosted-Clay 2 kolom (Curah Hujan, Angin,
/// Kelembapan, Suhu Terasa, Indeks UV, dan Busur Matahari Terbit/Terbenam).
class WeatherMetricsGrid extends StatelessWidget {
  const WeatherMetricsGrid({
    super.key,
    required this.weather,
  });

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final visual = WeatherCodeHelper.describe(
      current.weatherCode,
      isDay: current.isDay,
    );
    final windDir = WeatherCodeHelper.windDirectionLabel(
      current.windDirection10m,
    );
    final uvInfo = WeatherCodeHelper.uvSummary(weather.todayUvIndexMax);
    final uvValueText = weather.todayUvIndexMax != null
        ? weather.todayUvIndexMax!.round().toString()
        : '-';

    final cards = <Widget>[
      _DetailClayTile(
        tintColor: visual.claySurfaceTint,
        medallionColor: const Color(0xFFCDE9F6),
        iconColor: const Color(0xFF2B6EA8),
        icon: Icons.grain_rounded,
        title: 'Curah Hujan',
        primaryValue: '${current.precipitation.toStringAsFixed(1)} mm',
        secondaryTag: '${weather.todayPrecipitationProbabilityMax}%',
        description: WeatherCodeHelper.rainDescription(
          current.precipitation,
          weather.todayPrecipitationProbabilityMax,
        ),
      ),
      _DetailClayTile(
        tintColor: visual.claySurfaceTint,
        medallionColor: const Color(0xFFD8F5EE),
        iconColor: const Color(0xFF1E856F),
        icon: Icons.air_rounded,
        title: 'Angin',
        primaryValue: '${current.windSpeed10m.toStringAsFixed(1)} km/j',
        secondaryTag: windDir,
        description: WeatherCodeHelper.windDescription(current.windSpeed10m),
      ),
      _DetailClayTile(
        tintColor: visual.claySurfaceTint,
        medallionColor: const Color(0xFFDDF0FF),
        iconColor: const Color(0xFF2872B8),
        icon: Icons.water_drop_rounded,
        title: 'Kelembapan',
        primaryValue: '${current.relativeHumidity2m}%',
        description:
            WeatherCodeHelper.humidityDescription(current.relativeHumidity2m),
      ),
      _DetailClayTile(
        tintColor: visual.claySurfaceTint,
        medallionColor: const Color(0xFFFFE4DB),
        iconColor: const Color(0xFFD65336),
        icon: Icons.device_thermostat_rounded,
        title: 'Suhu Terasa',
        primaryValue: '${current.apparentTemperature.toStringAsFixed(1)}°C',
        secondaryTag: 'WMO ${current.weatherCode}',
        description: 'Kondisi ${visual.label.toLowerCase()}',
      ),
      _DetailClayTile(
        tintColor: visual.claySurfaceTint,
        medallionColor: const Color(0xFFFFF1CE),
        iconColor: const Color(0xFFC48012),
        icon: Icons.wb_sunny_outlined,
        title: 'Indeks UV',
        primaryValue: uvValueText,
        secondaryTag: uvInfo.label,
        description: uvInfo.advice,
      ),
      _SunArcClayTile(
        tintColor: visual.claySurfaceTint,
        sunrise: weather.todaySunrise,
        sunset: weather.todaySunset,
        currentTime: weather.currentDateTime,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 660 ? 3 : 2;
        const spacing = 12.0;
        final cardWidth =
            (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DetailClayTile extends StatelessWidget {
  const _DetailClayTile({
    required this.tintColor,
    required this.medallionColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.primaryValue,
    required this.description,
    this.secondaryTag,
  });

  final Color tintColor;
  final Color medallionColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String primaryValue;
  final String? secondaryTag;
  final String description;

  @override
  Widget build(BuildContext context) {
    return FrostedClayCard(
      tintColor: tintColor,
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClayContainer(
                  borderRadius: 11,
                  elevation: 0.4,
                  color: medallionColor,
                  padding: const EdgeInsets.all(6),
                  child: Icon(icon, size: 15, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    primaryValue,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (secondaryTag != null) ...[
                  Text(
                    '  |  ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  Text(
                    secondaryTag!,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: Colors.white.withValues(alpha: 0.78),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SunArcClayTile extends StatelessWidget {
  const _SunArcClayTile({
    required this.tintColor,
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
  });

  final Color tintColor;
  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? currentTime;

  @override
  Widget build(BuildContext context) {
    final sunriseStr =
        sunrise != null ? DateFormat('HH:mm').format(sunrise!) : '--:--';
    final sunsetStr =
        sunset != null ? DateFormat('HH:mm').format(sunset!) : '--:--';

    double progress = 0.5;
    if (sunrise != null && sunset != null && currentTime != null) {
      final total = sunset!.difference(sunrise!).inMinutes;
      final elapsed = currentTime!.difference(sunrise!).inMinutes;
      if (total > 0) {
        progress = (elapsed / total).clamp(0.0, 1.0);
      }
    }

    return FrostedClayCard(
      tintColor: tintColor,
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClayContainer(
                  borderRadius: 11,
                  elevation: 0.4,
                  color: const Color(0xFFFFE5B4),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.wb_twilight_rounded,
                    size: 15,
                    color: Color(0xFFD67D1A),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Matahari',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SunArcPainter(progress: progress),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sunriseStr,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  sunsetStr,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height - 4;
    final leftX = 12.0;
    final rightX = size.width - 12.0;
    final radius = (rightX - leftX) / 2;
    final center = Offset(size.width / 2, horizonY);

    // Garis horizon
    final horizonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      horizonPaint,
    );

    // Busur putus-putus lintasan matahari
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const segments = 18;
    for (var i = 0; i < segments; i += 2) {
      final startAngle = math.pi + (math.pi * (i / segments));
      final sweep = math.pi / segments;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: math.min(radius, size.height - 10)),
        startAngle,
        sweep,
        false,
        arcPaint,
      );
    }

    // Titik matahari pada posisi saat ini
    final effectiveRadius = math.min(radius, size.height - 10);
    final angle = math.pi + (math.pi * progress);
    final sunPos = Offset(
      center.dx + effectiveRadius * math.cos(angle),
      center.dy + effectiveRadius * math.sin(angle),
    );

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(sunPos, 9, glowPaint);

    final sunPaint = Paint()..color = const Color(0xFFFFD875);
    canvas.drawCircle(sunPos, 5.2, sunPaint);
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
