import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/models/location_model.dart';
import 'package:weatherapp/services/local_storage_service.dart';
import 'package:weatherapp/services/open_meteo_service.dart';
import 'package:weatherapp/viewmodels/weather_viewmodel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  OpenMeteoService buildMockApi({bool shouldFail = false}) {
    final mockClient = MockClient((request) async {
      if (shouldFail) {
        return http.Response('Error', 500);
      }
      return http.Response(
        jsonEncode({
          'latitude': -7.7956,
          'longitude': 110.3695,
          'timezone': 'Asia/Jakarta',
          'current': {
            'time': '2026-11-25T15:00',
            'temperature_2m': 29.0,
            'relative_humidity_2m': 78,
            'apparent_temperature': 32.0,
            'precipitation': 0.0,
            'weather_code': 1,
            'wind_speed_10m': 9.2,
            'is_day': 1,
          },
          'daily': {
            'time': ['2026-11-25'],
            'weather_code': [1],
            'temperature_2m_max': [31.5],
            'temperature_2m_min': [23.5],
            'precipitation_probability_max': [30],
          },
        }),
        200,
      );
    });
    return OpenMeteoService(client: mockClient);
  }

  test('menyimpan dan memulihkan lokasi favorit serta riwayat pencarian',
      () async {
    const bandung = LocationModel(
      id: 1650357,
      name: 'Bandung',
      latitude: -6.92222,
      longitude: 107.60694,
      country: 'Indonesia',
      admin1: 'Jawa Barat',
    );

    final storage = LocalStorageService();
    final vm1 = WeatherViewModel(
      apiService: buildMockApi(),
      storageService: storage,
    );

    await vm1.initialize();
    await vm1.toggleFavorite(bandung);
    await vm1.selectLocation(bandung);

    expect(vm1.isFavorite(bandung), isTrue);
    expect(vm1.selectedLocation, bandung);
    expect(vm1.searchHistory.first, bandung);

    // Simulasi aplikasi dibuka kembali dengan ViewModel baru
    final vm2 = WeatherViewModel(
      apiService: buildMockApi(),
      storageService: LocalStorageService(),
    );
    await vm2.initialize();

    expect(vm2.selectedLocation, bandung);
    expect(vm2.favorites, contains(bandung));
    expect(vm2.searchHistory, contains(bandung));
    expect(vm2.weather?.current.temperature2m, 29.0);
  });

  test('menangani kondisi error saat permintaan API gagal', () async {
    final vm = WeatherViewModel(
      apiService: buildMockApi(shouldFail: true),
      storageService: LocalStorageService(),
    );

    await vm.initialize();

    expect(vm.weather, isNull);
    expect(vm.errorMessage, isNotNull);
    expect(vm.isLoading, isFalse);
  });
}
