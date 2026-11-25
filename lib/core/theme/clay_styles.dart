import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/weather_code_helper.dart';

/// Palet warna untuk halaman manajemen lokasi (Claymorphism soft lavender/dusk)
/// dan helper permukaan frosted-clay atmosferik untuk Home screen.
class ClayPalette {
  ClayPalette._();

  static const Color lightCanvas = Color(0xFFEEE9F6);
  static const Color lightCanvasBottom = Color(0xFFE4DDF0);
  static const Color lightSurface = Color(0xFFFAF8FF);
  static const Color lightSurfaceSoft = Color(0xFFF1ECF9);

  static const Color darkCanvas = Color(0xFF1D1A2B);
  static const Color darkCanvasBottom = Color(0xFF151221);
  static const Color darkSurface = Color(0xFF2B263E);
  static const Color darkSurfaceSoft = Color(0xFF231F34);

  static const Color lightInk = Color(0xFF26203A);
  static const Color lightInkMuted = Color(0xFF6B6285);
  static const Color darkInk = Color(0xFFF3EFFB);
  static const Color darkInkMuted = Color(0xFFA9A0C4);

  static const Color coralPrimary = Color(0xFFFF7A5C);
  static const Color coralDeep = Color(0xFFE85A3C);
  static const Color irisAccent = Color(0xFF6F63D9);
  static const Color mintAccent = Color(0xFF34B399);
  static const Color honeyAccent = Color(0xFFF4B942);
  static const Color skyAccent = Color(0xFF5BA4E6);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color surfaceSoft(BuildContext context) =>
      isDark(context) ? darkSurfaceSoft : lightSurfaceSoft;

  static Color ink(BuildContext context) =>
      isDark(context) ? darkInk : lightInk;

  static Color inkMuted(BuildContext context) =>
      isDark(context) ? darkInkMuted : lightInkMuted;
}

/// Latar belakang langit atmosferik hidup (awan lembut, garis hujan, cahaya matahari, bintang)
/// yang menyesuaikan kondisi cuaca terkini dari Open-Meteo API.
class AtmosphericWeatherBackdrop extends StatelessWidget {
  const AtmosphericWeatherBackdrop({
    super.key,
    required this.visual,
    required this.child,
  });

  final WeatherVisualInfo visual;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: visual.skyColors,
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: _AtmosphericSkyPainter(visual.atmosphere),
          ),
        ),
        child,
      ],
    );
  }
}

class _AtmosphericSkyPainter extends CustomPainter {
  const _AtmosphericSkyPainter(this.atmosphere);

  final WeatherAtmosphere atmosphere;

  @override
  void paint(Canvas canvas, Size size) {
    if (atmosphere == WeatherAtmosphere.clearDay) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE59E).withValues(alpha: 0.42),
            const Color(0xFFFFE59E).withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.82, size.height * 0.14),
            radius: size.width * 0.52,
          ),
        );
      canvas.drawCircle(
        Offset(size.width * 0.82, size.height * 0.14),
        size.width * 0.52,
        glowPaint,
      );
    }

    if (atmosphere == WeatherAtmosphere.clearNight) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
      final stars = [
        Offset(size.width * 0.14, size.height * 0.10),
        Offset(size.width * 0.35, size.height * 0.06),
        Offset(size.width * 0.62, size.height * 0.12),
        Offset(size.width * 0.84, size.height * 0.08),
        Offset(size.width * 0.72, size.height * 0.21),
        Offset(size.width * 0.22, size.height * 0.24),
        Offset(size.width * 0.90, size.height * 0.19),
      ];
      for (var i = 0; i < stars.length; i++) {
        canvas.drawCircle(stars[i], i.isEven ? 1.8 : 1.2, starPaint);
      }
    }

    if (atmosphere == WeatherAtmosphere.cloudy ||
        atmosphere == WeatherAtmosphere.rain ||
        atmosphere == WeatherAtmosphere.storm ||
        atmosphere == WeatherAtmosphere.fog) {
      _drawSoftClouds(canvas, size);
    }

    if (atmosphere == WeatherAtmosphere.rain ||
        atmosphere == WeatherAtmosphere.storm) {
      _drawRainStreaks(canvas, size);
    }
  }

  void _drawSoftClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: atmosphere == WeatherAtmosphere.storm ? 0.07 : 0.11,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.11),
      size.width * 0.32,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.09),
      size.width * 0.38,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.15),
      size.width * 0.34,
      cloudPaint,
    );
  }

  void _drawRainStreaks(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final rng = math.Random(42);
    for (var i = 0; i < 42; i++) {
      final startX = rng.nextDouble() * size.width;
      final startY = rng.nextDouble() * (size.height * 0.65);
      final length = 18.0 + rng.nextDouble() * 34.0;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX - 4, startY + length),
        rainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmosphericSkyPainter oldDelegate) {
    return oldDelegate.atmosphere != atmosphere;
  }
}

/// Kartu Frosted-Clay atmosferik untuk Home screen: memadukan panel transparan lembut
/// ala aplikasi cuaca Android dengan kontur menggelembung lembut khas Claymorphism.
class FrostedClayCard extends StatelessWidget {
  const FrostedClayCard({
    super.key,
    required this.child,
    this.tintColor,
    this.borderRadius = 26,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Color? tintColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baseTint = tintColor ?? Colors.white;
    final radius = BorderRadius.circular(borderRadius);

    final content = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(baseTint, Colors.white, 0.22)!.withValues(alpha: 0.24),
            baseTint.withValues(alpha: 0.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            spreadRadius: -3,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ClayInnerCushionPainter(
          borderRadius: borderRadius,
          isDark: true,
          hasColoredFill: true,
          topAlpha: 0.34,
          bottomAlpha: 0.14,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(18),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// Wadah Claymorphism 3D menggelembung untuk medali ikon dan tombol pill.
class ClayContainer extends StatelessWidget {
  const ClayContainer({
    super.key,
    required this.child,
    this.color,
    this.gradientColors,
    this.borderRadius = 26,
    this.padding,
    this.shadowColor,
    this.elevation = 1.0,
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final List<Color>? gradientColors;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? shadowColor;
  final double elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = ClayPalette.isDark(context);
    final baseColor = color ?? ClayPalette.surface(context);
    final effectiveGradient = gradientColors ??
        [
          Color.lerp(baseColor, Colors.white, dark ? 0.06 : 0.35)!,
          baseColor,
        ];
    final effectiveShadow = shadowColor ??
        (dark
            ? Colors.black.withValues(alpha: 0.48)
            : const Color(0xFF9C8FB8).withValues(alpha: 0.24));

    final radius = BorderRadius.circular(borderRadius);

    final body = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: effectiveGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveShadow,
            blurRadius: 20 * elevation,
            spreadRadius: -2,
            offset: Offset(0, 10 * elevation),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: dark ? 0.05 : 0.72),
            blurRadius: 8 * elevation,
            offset: Offset(-2, -3 * elevation),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ClayInnerCushionPainter(
          borderRadius: borderRadius,
          isDark: dark,
          hasColoredFill: gradientColors != null,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );

    if (onTap == null) return body;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class _ClayInnerCushionPainter extends CustomPainter {
  const _ClayInnerCushionPainter({
    required this.borderRadius,
    required this.isDark,
    required this.hasColoredFill,
    this.topAlpha,
    this.bottomAlpha,
  });

  final double borderRadius;
  final bool isDark;
  final bool hasColoredFill;
  final double? topAlpha;
  final double? bottomAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.save();
    canvas.clipRRect(rrect);

    final topHighlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(
            alpha: topAlpha ??
                (hasColoredFill ? 0.42 : (isDark ? 0.14 : 0.90)),
          ),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect.deflate(1.1), topHighlight);

    final bottomDepth = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          (hasColoredFill
                  ? Colors.black
                  : (isDark ? Colors.black : const Color(0xFF9F92BD)))
              .withValues(
            alpha: bottomAlpha ??
                (hasColoredFill ? 0.18 : (isDark ? 0.35 : 0.18)),
          ),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect.deflate(1.3), bottomDepth);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ClayInnerCushionPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hasColoredFill != hasColoredFill ||
        oldDelegate.topAlpha != topAlpha ||
        oldDelegate.bottomAlpha != bottomAlpha;
  }
}

/// Tombol ikon bundar bergaya Claymorphism (mendukung mode solid & mode atmosferik).
class ClayIconButton extends StatelessWidget {
  const ClayIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.frosted = false,
    this.size = 42,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool frosted;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final effectiveColor = frosted
        ? (iconColor ?? Colors.white)
        : (iconColor ?? ClayPalette.ink(context));

    if (frosted) {
      return Tooltip(
        message: tooltip,
        child: FrostedClayCard(
          borderRadius: size / 2,
          padding: EdgeInsets.zero,
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: 20,
              color: enabled
                  ? effectiveColor
                  : effectiveColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: ClayContainer(
        borderRadius: size / 2,
        elevation: 0.75,
        color: backgroundColor,
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? effectiveColor
                : effectiveColor.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

/// Tombol kapsul CTA bergaya Claymorphism.
class ClayPillButton extends StatelessWidget {
  const ClayPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.colors,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final gradient = colors ??
        const [
          Color(0xFFFF8F73),
          ClayPalette.coralPrimary,
        ];

    return ClayContainer(
      borderRadius: 999,
      elevation: 0.95,
      gradientColors: gradient,
      shadowColor: gradient.last.withValues(alpha: 0.42),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
