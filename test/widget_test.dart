import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/main.dart';
import 'package:weatherapp/services/local_storage_service.dart';
import 'package:weatherapp/services/open_meteo_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  OpenMeteoService createMockService() {
    final client = MockClient((request) async {
      if (request.url.host == 'geocoding-api.open-meteo.com') {
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
              },
            ],
          }),
          200,
        );
      }

      final isYogya = request.url.queryParameters['latitude'] == '-7.79558';
      return http.Response(
        jsonEncode({
          'latitude': isYogya ? -7.79558 : -6.21462,
          'longitude': isYogya ? 110.36949 : 106.84513,
          'timezone': 'Asia/Jakarta',
          'current': {
            'time': '2026-11-25T15:00',
            'temperature_2m': isYogya ? 28.4 : 31.2,
            'relative_humidity_2m': 74,
            'apparent_temperature': 33.5,
            'precipitation': 0.4,
            'weather_code': 2,
            'wind_speed_10m': 12.8,
            'wind_direction_10m': 135,
            'is_day': 1,
          },
          'hourly': {
            'time': [
              '2026-11-25T15:00',
              '2026-11-25T16:00',
              '2026-11-25T17:00',
            ],
            'temperature_2m': [31.2, 29.8, 28.5],
            'weather_code': [2, 61, 3],
            'precipitation_probability': [45, 75, 30],
          },
          'daily': {
            'time': ['2026-11-25', '2026-11-26', '2026-11-27'],
            'weather_code': [2, 61, 0],
            'temperature_2m_max': [33.0, 30.0, 32.0],
            'temperature_2m_min': [24.0, 23.0, 23.5],
            'precipitation_probability_max': [45, 80, 15],
            'sunrise': [
              '2026-11-25T05:15',
              '2026-11-26T05:15',
              '2026-11-27T05:16',
            ],
            'sunset': [
              '2026-11-25T17:44',
              '2026-11-26T17:45',
              '2026-11-27T17:45',
            ],
            'uv_index_max': [5.0, 3.0, 7.0],
          },
        }),
        200,
      );
    });
    return OpenMeteoService(client: client);
  }

  testWidgets(
      'HomeWeatherScreen menampilkan data cuaca dan SearchLocationScreen dapat mencari & memilih kota',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      WeatherApp(
        apiService: createMockService(),
        storageService: LocalStorageService(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi Home Screen menampilkan kota default, suhu, kondisi, dan strip 24 jam
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.text('31°C'), findsOneWidget);
    expect(find.text('Berawan Sebagian'), findsWidgets);
    expect(find.text('24 Jam Berikutnya'), findsOneWidget);

    // Navigasi ke Search / Location Screen
    await tester.tap(find.byTooltip('Cari Lokasi'));
    await tester.pumpAndSettle();

    expect(find.text('Cari & Kelola Lokasi'), findsOneWidget);

    // Cari kota Yogyakarta
    await tester.enterText(find.byType(TextField), 'Yogyakarta');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Yogyakarta'), findsOneWidget);

    // Simpan ke favorit lalu pilih kota
    await tester.tap(find.byTooltip('Simpan favorit').first);
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Yogyakarta'));
    await tester.pumpAndSettle();

    // Kembali ke Home Screen dengan data cuaca Yogyakarta
    expect(find.text('Yogyakarta'), findsWidgets);
    expect(find.text('28°C'), findsOneWidget);

    // Scroll ke bawah untuk memverifikasi perkiraan 7 hari dan detail grid (kelembapan & matahari)
    final verticalScrollable = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );

    await tester.scrollUntilVisible(
      find.text('Hari Ini'),
      200,
      scrollable: verticalScrollable,
    );
    expect(find.text('Perkiraan 7 Hari ke Depan'), findsOneWidget);
    expect(find.text('Hari Ini'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Matahari'),
      200,
      scrollable: verticalScrollable,
    );
    expect(find.text('74%'), findsOneWidget);
    expect(find.text('Matahari'), findsOneWidget);
  });
}
