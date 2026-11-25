import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weatherapp/services/open_meteo_service.dart';

void main() {
  group('OpenMeteoService', () {
    test('fetchWeather mengurai JSON Open-Meteo Forecast API dengan benar',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.path, '/v1/forecast');
        expect(request.url.queryParameters['timezone'], 'auto');

        return http.Response(
          jsonEncode({
            'latitude': -7.7956,
            'longitude': 110.3695,
            'timezone': 'Asia/Jakarta',
            'current': {
              'time': '2026-11-25T15:00',
              'temperature_2m': 30.4,
              'relative_humidity_2m': 72,
              'apparent_temperature': 34.1,
              'precipitation': 0.2,
              'weather_code': 2,
              'wind_speed_10m': 11.5,
              'wind_direction_10m': 135,
              'is_day': 1,
            },
            'hourly': {
              'time': ['2026-11-25T15:00', '2026-11-25T16:00'],
              'temperature_2m': [30.4, 29.1],
              'weather_code': [2, 61],
              'precipitation_probability': [40, 75],
            },
            'daily': {
              'time': ['2026-11-25', '2026-11-26'],
              'weather_code': [2, 61],
              'temperature_2m_max': [32.0, 29.5],
              'temperature_2m_min': [24.0, 23.2],
              'precipitation_probability_max': [40, 85],
              'sunrise': ['2026-11-25T05:15', '2026-11-26T05:15'],
              'sunset': ['2026-11-25T17:44', '2026-11-26T17:45'],
              'uv_index_max': [6.5, 4.2],
            },
          }),
          200,
        );
      });

      final service = OpenMeteoService(client: mockClient);
      final weather = await service.fetchWeather(
        latitude: -7.7956,
        longitude: 110.3695,
      );

      expect(weather.timezone, 'Asia/Jakarta');
      expect(weather.current.temperature2m, 30.4);
      expect(weather.current.relativeHumidity2m, 72);
      expect(weather.current.apparentTemperature, 34.1);
      expect(weather.current.precipitation, 0.2);
      expect(weather.current.weatherCode, 2);
      expect(weather.current.windSpeed10m, 11.5);
      expect(weather.current.windDirection10m, 135);
      expect(weather.hourly.length, 2);
      expect(weather.hourly[1].precipitationProbability, 75);
      expect(weather.daily.length, 2);
      expect(weather.daily.first.temperatureMax, 32.0);
      expect(weather.daily.first.temperatureMin, 24.0);
      expect(weather.daily.first.precipitationProbabilityMax, 40);
      expect(weather.todayUvIndexMax, 6.5);
      expect(weather.todaySunrise?.hour, 5);
      expect(weather.todaySunset?.hour, 17);
      expect(weather.daily[1].weatherCode, 61);
    });

    test('searchLocations mengurai daftar kota dan menangani hasil kosong',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.path, '/v1/search');

        if (request.url.queryParameters['name'] == 'Yogyakarta') {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'id': 1621177,
                  'name': 'Yogyakarta',
                  'latitude': -7.79558,
                  'longitude': 110.36949,
                  'country': 'Indonesia',
                  'admin1': 'Daerah Istimewa Yogyakarta',
                  'country_code': 'ID',
                  'timezone': 'Asia/Jakarta',
                }
              ]
            }),
            200,
          );
        }

        return http.Response(jsonEncode({'generationtime_ms': 0.5}), 200);
      });

      final service = OpenMeteoService(client: mockClient);

      final found = await service.searchLocations('Yogyakarta');
      expect(found.length, 1);
      expect(found.first.name, 'Yogyakarta');
      expect(found.first.admin1, 'Daerah Istimewa Yogyakarta');

      final empty = await service.searchLocations('KotaTidakAda123');
      expect(empty, isEmpty);
    });

    test('melempar WeatherApiException saat HTTP status bukan 200', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Internal Server Error', 500),
      );
      final service = OpenMeteoService(client: mockClient);

      expect(
        () => service.fetchWeather(latitude: 0, longitude: 0),
        throwsA(isA<WeatherApiException>()),
      );
    });
  });
}
