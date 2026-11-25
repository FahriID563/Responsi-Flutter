import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service penyimpanan lokal menggunakan [SharedPreferences] untuk
/// lokasi favorit, riwayat pencarian, dan lokasi terakhir yang dipilih.
class LocalStorageService {
  LocalStorageService({this._preferences});

  SharedPreferences? _preferences;

  static const String _favoritesKey = 'favorite_locations_v1';
  static const String _historyKey = 'search_history_v1';
  static const String _selectedLocationKey = 'selected_location_v1';
  static const int maxHistoryItems = 10;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  /// Membaca daftar lokasi favorit yang tersimpan.
  Future<List<LocationModel>> getFavorites() async {
    return _readLocationList(_favoritesKey);
  }

  /// Menyimpan daftar lokasi favorit ke penyimpanan lokal.
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    await _writeLocationList(_favoritesKey, favorites);
  }

  /// Membaca riwayat pencarian lokasi yang tersimpan.
  Future<List<LocationModel>> getSearchHistory() async {
    return _readLocationList(_historyKey);
  }

  /// Menyimpan riwayat pencarian lokasi (dibatasi hingga [maxHistoryItems]).
  Future<void> saveSearchHistory(List<LocationModel> history) async {
    await _writeLocationList(
      _historyKey,
      history.take(maxHistoryItems).toList(),
    );
  }

  /// Membaca lokasi terakhir yang dipilih pengguna.
  Future<LocationModel?> getSelectedLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_selectedLocationKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return LocationModel.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Menyimpan lokasi terakhir yang dipilih pengguna.
  Future<void> saveSelectedLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(
      _selectedLocationKey,
      jsonEncode(location.toJson()),
    );
  }

  Future<List<LocationModel>> _readLocationList(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeLocationList(
    String key,
    List<LocationModel> locations,
  ) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(locations.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }
}
