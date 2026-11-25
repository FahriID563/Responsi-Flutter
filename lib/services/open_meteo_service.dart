import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Exception khusus untuk kesalahan komunikasi atau parsing API Open-Meteo.
class WeatherApiException implements Exception {
  const WeatherApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Service REST API menggunakan HTTP GET ke Open-Meteo Forecast & Geocoding API.
class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _forecastHost = 'api.open-meteo.com';
  static const String _geocodingHost = 'geocoding-api.open-meteo.com';
  static const Duration _timeout = Duration(seconds: 15);

  /// Mengambil data cuaca terkini (`current`), per jam (`hourly`), dan harian (`daily`).
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m,is_day',
      'hourly': 'temperature_2m,weather_code,precipitation_probability',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset,uv_index_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final decoded = await _getJson(uri);
    try {
      return WeatherModel.fromJson(decoded);
    } on FormatException catch (e) {
      throw WeatherApiException(e.message);
    }
  }

  /// Mencari lokasi berdasarkan nama kota melalui Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': trimmed,
      'count': '15',
      'language': 'id',
      'format': 'json',
    });

    final decoded = await _getJson(uri);
    final results = decoded['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      return const [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(LocationModel.fromGeocodingJson)
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Server mengembalikan status ${response.statusCode}.',
        );
      }

      final dynamic parsed = jsonDecode(response.body);
      if (parsed is! Map<String, dynamic>) {
        throw const WeatherApiException('Format respons API tidak valid.');
      }

      if (parsed['error'] == true) {
        final reason = parsed['reason']?.toString() ?? 'Permintaan API ditolak.';
        throw WeatherApiException(reason);
      }

      return parsed;
    } on SocketException {
      throw const WeatherApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const WeatherApiException(
        'Koneksi ke server Open-Meteo melebihi batas waktu.',
      );
    } on http.ClientException {
      throw const WeatherApiException(
        'Gagal menghubungi server cuaca. Coba beberapa saat lagi.',
      );
    } on FormatException {
      throw const WeatherApiException(
        'Gagal membaca format data JSON dari server.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
