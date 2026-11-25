/// Model utama respons cuaca dari Open-Meteo Forecast API.
class WeatherModel {
  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
    this.hourly = const [],
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  /// Mengurai respons JSON Open-Meteo Forecast API menjadi [WeatherModel].
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>?;
    final dailyMap = json['daily'] as Map<String, dynamic>?;

    if (currentMap == null || dailyMap == null) {
      throw const FormatException('Data cuaca current atau daily tidak tersedia.');
    }

    final times = (dailyMap['time'] as List<dynamic>? ?? const []);
    final codes = (dailyMap['weather_code'] as List<dynamic>? ?? const []);
    final maxTemps =
        (dailyMap['temperature_2m_max'] as List<dynamic>? ?? const []);
    final minTemps =
        (dailyMap['temperature_2m_min'] as List<dynamic>? ?? const []);
    final rainProbs =
        (dailyMap['precipitation_probability_max'] as List<dynamic>? ?? const []);
    final sunrises = (dailyMap['sunrise'] as List<dynamic>? ?? const []);
    final sunsets = (dailyMap['sunset'] as List<dynamic>? ?? const []);
    final uvMaxes = (dailyMap['uv_index_max'] as List<dynamic>? ?? const []);

    final count = [
      times.length,
      codes.length,
      maxTemps.length,
      minTemps.length,
    ].reduce((a, b) => a < b ? a : b);

    final dailyList = <DailyForecast>[];
    for (var i = 0; i < count; i++) {
      final parsedDate = DateTime.tryParse(times[i].toString());
      if (parsedDate == null) continue;

      final prob = i < rainProbs.length && rainProbs[i] != null
          ? (rainProbs[i] as num).toInt()
          : 0;

      final sunrise = i < sunrises.length && sunrises[i] != null
          ? DateTime.tryParse(sunrises[i].toString())
          : null;
      final sunset = i < sunsets.length && sunsets[i] != null
          ? DateTime.tryParse(sunsets[i].toString())
          : null;
      final uvMax = i < uvMaxes.length && uvMaxes[i] != null
          ? (uvMaxes[i] as num).toDouble()
          : null;

      dailyList.add(
        DailyForecast(
          date: parsedDate,
          weatherCode: (codes[i] as num?)?.toInt() ?? 0,
          temperatureMax: (maxTemps[i] as num?)?.toDouble() ?? 0.0,
          temperatureMin: (minTemps[i] as num?)?.toDouble() ?? 0.0,
          precipitationProbabilityMax: prob,
          sunrise: sunrise,
          sunset: sunset,
          uvIndexMax: uvMax,
        ),
      );
    }

    final current = CurrentWeather.fromJson(currentMap);
    final hourlyList = _parseHourly(json['hourly'] as Map<String, dynamic>?, current.time);

    return WeatherModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      current: current,
      daily: dailyList,
      hourly: hourlyList,
    );
  }

  static List<HourlyForecast> _parseHourly(
    Map<String, dynamic>? hourlyMap,
    String currentTimeIso,
  ) {
    if (hourlyMap == null) return const [];
    final times = (hourlyMap['time'] as List<dynamic>? ?? const []);
    final temps = (hourlyMap['temperature_2m'] as List<dynamic>? ?? const []);
    final codes = (hourlyMap['weather_code'] as List<dynamic>? ?? const []);
    final probs =
        (hourlyMap['precipitation_probability'] as List<dynamic>? ?? const []);

    final count = [times.length, temps.length, codes.length]
        .reduce((a, b) => a < b ? a : b);
    if (count == 0) return const [];

    final currentDt = DateTime.tryParse(currentTimeIso);
    final parsed = <HourlyForecast>[];

    for (var i = 0; i < count; i++) {
      final dt = DateTime.tryParse(times[i].toString());
      if (dt == null) continue;
      if (currentDt != null && dt.isBefore(currentDt.subtract(const Duration(minutes: 59)))) {
        continue;
      }
      final prob = i < probs.length && probs[i] != null
          ? (probs[i] as num).toInt()
          : 0;
      parsed.add(
        HourlyForecast(
          time: dt,
          temperature: (temps[i] as num?)?.toDouble() ?? 0.0,
          weatherCode: (codes[i] as num?)?.toInt() ?? 0,
          precipitationProbability: prob,
        ),
      );
      if (parsed.length >= 24) break;
    }
    return parsed;
  }

  /// Peluang hujan maksimum hari ini.
  int get todayPrecipitationProbabilityMax =>
      daily.isNotEmpty ? daily.first.precipitationProbabilityMax : 0;

  /// Suhu maksimum hari ini.
  double? get todayMaxTemp =>
      daily.isNotEmpty ? daily.first.temperatureMax : null;

  /// Suhu minimum hari ini.
  double? get todayMinTemp =>
      daily.isNotEmpty ? daily.first.temperatureMin : null;

  /// Waktu matahari terbit hari ini.
  DateTime? get todaySunrise =>
      daily.isNotEmpty ? daily.first.sunrise : null;

  /// Waktu matahari terbenam hari ini.
  DateTime? get todaySunset =>
      daily.isNotEmpty ? daily.first.sunset : null;

  /// Indeks UV maksimum hari ini.
  double? get todayUvIndexMax =>
      daily.isNotEmpty ? daily.first.uvIndexMax : null;

  /// Waktu saat ini menurut timezone lokasi.
  DateTime? get currentDateTime => DateTime.tryParse(current.time);
}

/// Model data cuaca terkini (`current`) dari Open-Meteo.
class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    this.windDirection10m,
    this.isDay = true,
  });

  final String time;
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final int? windDirection10m;
  final bool isDay;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: (json['time'] as String?) ?? '',
      temperature2m: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m:
          (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection10m: (json['wind_direction_10m'] as num?)?.toInt(),
      isDay: (json['is_day'] as num?)?.toInt() != 0,
    );
  }
}

/// Model perkiraan cuaca per jam (`hourly`) untuk 24 jam ke depan.
class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
}

/// Model data perkiraan cuaca harian (`daily`) dari Open-Meteo.
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
  });

  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? uvIndexMax;
}
