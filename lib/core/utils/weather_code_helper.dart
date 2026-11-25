import 'package:flutter/material.dart';

import '../../models/weather_model.dart';

enum WeatherAtmosphere {
  clearDay,
  clearNight,
  cloudy,
  rain,
  storm,
  fog,
  snow,
}

/// Informasi visual dan konteks cuaca dari kode WMO Open-Meteo.
class WeatherVisualInfo {
  const WeatherVisualInfo({
    required this.label,
    required this.icon,
    required this.atmosphere,
    required this.skyColors,
    required this.claySurfaceTint,
    required this.medallionColor,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final WeatherAtmosphere atmosphere;
  final List<Color> skyColors;
  final Color claySurfaceTint;
  final Color medallionColor;
  final Color accentColor;
}

/// Helper untuk menerjemahkan `weather_code` WMO serta menghasilkan ringkasan
/// kontekstual dari data API live (tanpa data statis/hardcoded).
class WeatherCodeHelper {
  WeatherCodeHelper._();

  static WeatherVisualInfo describe(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return isDay
            ? const WeatherVisualInfo(
                label: 'Cerah',
                icon: Icons.wb_sunny_rounded,
                atmosphere: WeatherAtmosphere.clearDay,
                skyColors: [
                  Color(0xFF4778B8),
                  Color(0xFF6495CC),
                  Color(0xFF4F7AA8),
                ],
                claySurfaceTint: Color(0xFF5683BC),
                medallionColor: Color(0xFFFFD875),
                accentColor: Color(0xFFFFC95C),
              )
            : const WeatherVisualInfo(
                label: 'Cerah Berbintang',
                icon: Icons.nights_stay_rounded,
                atmosphere: WeatherAtmosphere.clearNight,
                skyColors: [
                  Color(0xFF1A2138),
                  Color(0xFF283254),
                  Color(0xFF1F2640),
                ],
                claySurfaceTint: Color(0xFF2C3659),
                medallionColor: Color(0xFFDCD6FF),
                accentColor: Color(0xFFB5ACFF),
              );
      case 1:
        return isDay
            ? const WeatherVisualInfo(
                label: 'Sebagian Cerah',
                icon: Icons.wb_sunny_outlined,
                atmosphere: WeatherAtmosphere.clearDay,
                skyColors: [
                  Color(0xFF4F7AA8),
                  Color(0xFF6B94BF),
                  Color(0xFF557AA1),
                ],
                claySurfaceTint: Color(0xFF5D83AC),
                medallionColor: Color(0xFFFFDF8E),
                accentColor: Color(0xFFFFD166),
              )
            : const WeatherVisualInfo(
                label: 'Cerah Berawan',
                icon: Icons.nights_stay_outlined,
                atmosphere: WeatherAtmosphere.clearNight,
                skyColors: [
                  Color(0xFF202842),
                  Color(0xFF2F3A5E),
                  Color(0xFF242D4A),
                ],
                claySurfaceTint: Color(0xFF333E63),
                medallionColor: Color(0xFFD6CEFF),
                accentColor: Color(0xFFB5ACFF),
              );
      case 2:
        return WeatherVisualInfo(
          label: 'Berawan Sebagian',
          icon: Icons.cloud_queue_rounded,
          atmosphere: WeatherAtmosphere.cloudy,
          skyColors: isDay
              ? const [
                  Color(0xFF536682),
                  Color(0xFF6B7F9C),
                  Color(0xFF546680),
                ]
              : const [
                  Color(0xFF263044),
                  Color(0xFF364259),
                  Color(0xFF293347),
                ],
          claySurfaceTint:
              isDay ? const Color(0xFF5E718E) : const Color(0xFF39455E),
          medallionColor: const Color(0xFFFFE4B5),
          accentColor: const Color(0xFF9EC5FF),
        );
      case 3:
        return const WeatherVisualInfo(
          label: 'Mendung',
          icon: Icons.cloud_rounded,
          atmosphere: WeatherAtmosphere.cloudy,
          skyColors: [
            Color(0xFF4F5B6E),
            Color(0xFF647185),
            Color(0xFF4E596B),
          ],
          claySurfaceTint: Color(0xFF5C687D),
          medallionColor: Color(0xFFE4E9F2),
          accentColor: Color(0xFFB8C7DE),
        );
      case 45:
      case 48:
        return const WeatherVisualInfo(
          label: 'Berkabut',
          icon: Icons.foggy,
          atmosphere: WeatherAtmosphere.fog,
          skyColors: [
            Color(0xFF566270),
            Color(0xFF6D7A8A),
            Color(0xFF576372),
          ],
          claySurfaceTint: Color(0xFF637080),
          medallionColor: Color(0xFFE7ECF2),
          accentColor: Color(0xFFC7D3E0),
        );
      case 51:
      case 53:
      case 55:
        return const WeatherVisualInfo(
          label: 'Gerimis',
          icon: Icons.grain_rounded,
          atmosphere: WeatherAtmosphere.rain,
          skyColors: [
            Color(0xFF49566B),
            Color(0xFF617087),
            Color(0xFF475469),
          ],
          claySurfaceTint: Color(0xFF56647B),
          medallionColor: Color(0xFFCDE9F6),
          accentColor: Color(0xFF8FD3F4),
        );
      case 56:
      case 57:
        return const WeatherVisualInfo(
          label: 'Gerimis Beku',
          icon: Icons.ac_unit_rounded,
          atmosphere: WeatherAtmosphere.rain,
          skyColors: [
            Color(0xFF485E75),
            Color(0xFF5D7691),
            Color(0xFF465C73),
          ],
          claySurfaceTint: Color(0xFF556E87),
          medallionColor: Color(0xFFDDF3FF),
          accentColor: Color(0xFFA2DCFA),
        );
      case 61:
        return const WeatherVisualInfo(
          label: 'Hujan Ringan',
          icon: Icons.water_drop_outlined,
          atmosphere: WeatherAtmosphere.rain,
          skyColors: [
            Color(0xFF44556E),
            Color(0xFF5B6E8A),
            Color(0xFF43536B),
          ],
          claySurfaceTint: Color(0xFF526480),
          medallionColor: Color(0xFFC8ECFA),
          accentColor: Color(0xFF84D2F6),
        );
      case 63:
        return const WeatherVisualInfo(
          label: 'Hujan Sedang',
          icon: Icons.water_drop_rounded,
          atmosphere: WeatherAtmosphere.rain,
          skyColors: [
            Color(0xFF3E4F69),
            Color(0xFF546885),
            Color(0xFF3D4D66),
          ],
          claySurfaceTint: Color(0xFF4C5F7D),
          medallionColor: Color(0xFFBFE6FA),
          accentColor: Color(0xFF79CCF2),
        );
      case 65:
        return const WeatherVisualInfo(
          label: 'Hujan Lebat',
          icon: Icons.umbrella_rounded,
          atmosphere: WeatherAtmosphere.rain,
          skyColors: [
            Color(0xFF34435C),
            Color(0xFF495B78),
            Color(0xFF324159),
          ],
          claySurfaceTint: Color(0xFF435470),
          medallionColor: Color(0xFFB8DEFA),
          accentColor: Color(0xFF6AC2F0),
        );
      case 66:
      case 67:
        return const WeatherVisualInfo(
          label: 'Hujan Beku',
          icon: Icons.ac_unit_rounded,
          atmosphere: WeatherAtmosphere.rain,
          skyColors: [
            Color(0xFF3E5570),
            Color(0xFF526D8C),
            Color(0xFF3D536E),
          ],
          claySurfaceTint: Color(0xFF4C6482),
          medallionColor: Color(0xFFD5EBFF),
          accentColor: Color(0xFF9FD6FA),
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return const WeatherVisualInfo(
          label: 'Salju',
          icon: Icons.cloudy_snowing,
          atmosphere: WeatherAtmosphere.snow,
          skyColors: [
            Color(0xFF54688A),
            Color(0xFF7085A8),
            Color(0xFF566A8C),
          ],
          claySurfaceTint: Color(0xFF64799C),
          medallionColor: Color(0xFFF0F5FF),
          accentColor: Color(0xFFD6E5FF),
        );
      case 80:
      case 81:
      case 82:
        return const WeatherVisualInfo(
          label: 'Hujan Lokal',
          icon: Icons.beach_access_rounded,
          atmosphere: WeatherAtmosphere.rain,
          skyColors: [
            Color(0xFF3F526B),
            Color(0xFF566C8A),
            Color(0xFF3F5169),
          ],
          claySurfaceTint: Color(0xFF4E6380),
          medallionColor: Color(0xFFC9EEF8),
          accentColor: Color(0xFF83D0F2),
        );
      case 85:
      case 86:
        return const WeatherVisualInfo(
          label: 'Hujan Salju',
          icon: Icons.ac_unit_rounded,
          atmosphere: WeatherAtmosphere.snow,
          skyColors: [
            Color(0xFF4B6082),
            Color(0xFF657DA3),
            Color(0xFF4B6082),
          ],
          claySurfaceTint: Color(0xFF5B7196),
          medallionColor: Color(0xFFE6EEFF),
          accentColor: Color(0xFFCCE0FF),
        );
      case 95:
        return const WeatherVisualInfo(
          label: 'Badai Petir',
          icon: Icons.thunderstorm_rounded,
          atmosphere: WeatherAtmosphere.storm,
          skyColors: [
            Color(0xFF30354D),
            Color(0xFF454C6B),
            Color(0xFF2D3247),
          ],
          claySurfaceTint: Color(0xFF3E4461),
          medallionColor: Color(0xFFFFD875),
          accentColor: Color(0xFFFFCC4D),
        );
      case 96:
      case 99:
        return const WeatherVisualInfo(
          label: 'Badai & Hujan Es',
          icon: Icons.flash_on_rounded,
          atmosphere: WeatherAtmosphere.storm,
          skyColors: [
            Color(0xFF2B2F45),
            Color(0xFF3F4563),
            Color(0xFF272B40),
          ],
          claySurfaceTint: Color(0xFF383E59),
          medallionColor: Color(0xFFFFD875),
          accentColor: Color(0xFFFFCC4D),
        );
      default:
        return const WeatherVisualInfo(
          label: 'Cuaca Berubah',
          icon: Icons.wb_cloudy_rounded,
          atmosphere: WeatherAtmosphere.cloudy,
          skyColors: [
            Color(0xFF4C5E78),
            Color(0xFF647996),
            Color(0xFF4C5E78),
          ],
          claySurfaceTint: Color(0xFF596D8A),
          medallionColor: Color(0xFFE4EBF5),
          accentColor: Color(0xFFB3CAE8),
        );
    }
  }

  /// Mengubah sudut arah angin (0-360°) menjadi kode arah mata angin.
  static String windDirectionLabel(int? degrees) {
    if (degrees == null) return 'Variabel';
    const dirs = ['U', 'TL', 'T', 'TG', 'S', 'BD', 'B', 'BL'];
    final index = ((degrees % 360) / 45).round() % 8;
    return dirs[index];
  }

  /// Menghasilkan ringkasan saran cuaca dari nilai API aktual.
  static ({String title, String message, IconData icon}) buildAdvisory(
    WeatherModel weather,
  ) {
    final rainProb = weather.todayPrecipitationProbabilityMax;
    final precip = weather.current.precipitation;
    final code = weather.current.weatherCode;
    final wind = weather.current.windSpeed10m;

    if (code >= 95) {
      return (
        title: 'Waspada Badai Petir',
        message:
            'Terdeteksi potensi badai petir dengan peluang hujan $rainProb%. Utamakan berada di dalam ruangan.',
        icon: Icons.thunderstorm_rounded,
      );
    }
    if (rainProb >= 70 || precip > 0.5) {
      return (
        title: 'Kemungkinan Hujan Tinggi',
        message:
            'Peluang hujan hari ini mencapai $rainProb% dengan curah ${precip.toStringAsFixed(1)} mm. Siapkan payung sebelum bepergian.',
        icon: Icons.umbrella_rounded,
      );
    }
    if (wind >= 25) {
      return (
        title: 'Angin Cukup Kencang',
        message:
            'Kecepatan angin mencapai ${wind.toStringAsFixed(1)} km/j. Berhati-hatilah saat berkendara di area terbuka.',
        icon: Icons.air_rounded,
      );
    }
    if (rainProb >= 35) {
      return (
        title: 'Potensi Hujan Ringan',
        message:
            'Ada peluang hujan sekitar $rainProb% hari ini. Pantau perubahan cuaca sebelum beraktivitas di luar.',
        icon: Icons.grain_rounded,
      );
    }
    return (
      title: 'Cuaca Cukup Kondusif',
      message:
          'Peluang hujan rendah ($rainProb%) dengan suhu terasa ${weather.current.apparentTemperature.round()}°C. Nyaman untuk aktivitas luar ruangan.',
      icon: Icons.wb_sunny_outlined,
    );
  }

  static String rainDescription(double precipitation, int probability) {
    if (precipitation >= 7.0) return 'Hujan lebat, waspadai genangan air';
    if (precipitation > 0.5) return 'Hujan ringan hingga sedang';
    if (probability >= 60) return 'Berpotensi hujan dalam hari ini';
    return 'Curah hujan minimal atau nihil';
  }

  static String windDescription(double speed) {
    if (speed < 6) return 'Angin tenang, udara terasa lembut';
    if (speed < 18) return 'Angin sepoi-sepoi nyaman';
    if (speed < 30) return 'Angin bertiup cukup kencang';
    return 'Angin kencang di area terbuka';
  }

  static String humidityDescription(int humidity) {
    if (humidity >= 85) return 'Sangat lembap dan terasa pengap';
    if (humidity >= 60) return 'Kelembapan udara cukup nyaman';
    if (humidity >= 35) return 'Udara segar dan seimbang';
    return 'Udara cenderung kering';
  }

  static ({String label, String advice}) uvSummary(double? uv) {
    if (uv == null) {
      return (label: 'Tidak tersedia', advice: 'Data UV belum dimuat');
    }
    if (uv < 3) {
      return (label: 'Terlemah', advice: 'Tidak perlu perlindungan khusus');
    }
    if (uv < 6) {
      return (label: 'Sedang', advice: 'Gunakan kacamata atau topi siang hari');
    }
    if (uv < 8) {
      return (label: 'Tinggi', advice: 'Disarankan memakai tabir surya');
    }
    return (
      label: 'Sangat Tinggi',
      advice: 'Batasi paparan matahari langsung'
    );
  }
}
