import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/open_meteo_service.dart';

/// ViewModel utama untuk Home / Weather Screen serta manajemen lokasi favorit & riwayat.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    required this._apiService,
    required this._storageService,
  });

  final OpenMeteoService _apiService;
  final LocalStorageService _storageService;

  LocationModel _selectedLocation = LocationModel.defaultLocation;
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  List<LocationModel> _favorites = [];
  List<LocationModel> _searchHistory = [];
  bool _initialized = false;

  LocationModel get selectedLocation => _selectedLocation;
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  bool get isInitialized => _initialized;

  bool get isSelectedLocationFavorite => isFavorite(_selectedLocation);

  /// Mengecek apakah [location] sudah tersimpan sebagai favorit.
  bool isFavorite(LocationModel location) => _favorites.contains(location);

  /// Memuat data awal dari Local Storage lalu mengambil cuaca terkini dari API.
  Future<void> initialize() async {
    if (_initialized) return;

    final results = await Future.wait([
      _storageService.getFavorites(),
      _storageService.getSearchHistory(),
      _storageService.getSelectedLocation(),
    ]);

    _favorites = List<LocationModel>.from(results[0] as List<LocationModel>);
    _searchHistory = List<LocationModel>.from(results[1] as List<LocationModel>);

    final savedSelected = results[2] as LocationModel?;
    if (savedSelected != null) {
      _selectedLocation = savedSelected;
    } else if (_favorites.isNotEmpty) {
      _selectedLocation = _favorites.first;
    }

    _initialized = true;
    notifyListeners();

    await loadWeather();
  }

  /// Mengambil data cuaca dari Open-Meteo Forecast API untuk [_selectedLocation].
  Future<void> loadWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.fetchWeather(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );
      _weather = result;
      _lastUpdated = DateTime.now();
    } on WeatherApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat memuat data cuaca.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memilih lokasi baru, menyimpannya ke riwayat & preferensi, lalu memuat ulang cuaca.
  Future<void> selectLocation(
    LocationModel location, {
    bool recordHistory = true,
  }) async {
    _selectedLocation = location;
    await _storageService.saveSelectedLocation(location);

    if (recordHistory) {
      _searchHistory = [
        location,
        ..._searchHistory.where((item) => item != location),
      ].take(LocalStorageService.maxHistoryItems).toList();
      await _storageService.saveSearchHistory(_searchHistory);
    }

    notifyListeners();
    await loadWeather();
  }

  /// Menambah atau menghapus lokasi dari daftar favorit dan menyimpannya secara lokal.
  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      _favorites = _favorites.where((item) => item != location).toList();
    } else {
      _favorites = [location, ..._favorites];
    }
    notifyListeners();
    await _storageService.saveFavorites(_favorites);
  }

  /// Menghapus satu item dari riwayat pencarian.
  Future<void> removeHistoryItem(LocationModel location) async {
    _searchHistory = _searchHistory.where((item) => item != location).toList();
    notifyListeners();
    await _storageService.saveSearchHistory(_searchHistory);
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearHistory() async {
    _searchHistory = [];
    notifyListeners();
    await _storageService.saveSearchHistory(_searchHistory);
  }
}
