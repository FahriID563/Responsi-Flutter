import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/open_meteo_service.dart';

/// ViewModel untuk Search / Location Screen yang menangani pencarian kota ke API.
class LocationSearchViewModel extends ChangeNotifier {
  LocationSearchViewModel({required this._apiService});

  final OpenMeteoService _apiService;

  Timer? _debounceTimer;
  int _searchToken = 0;

  String _query = '';
  List<LocationModel> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  String get query => _query;
  List<LocationModel> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSearched => _hasSearched;

  /// Menangani perubahan teks pencarian dengan debounce 400ms.
  void onQueryChanged(String value) {
    _query = value;
    _debounceTimer?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _searchToken++;
      _results = [];
      _errorMessage = null;
      _isLoading = false;
      _hasSearched = false;
      notifyListeners();
      return;
    }

    if (trimmed.length < 2) {
      _results = [];
      _errorMessage = null;
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => search(trimmed),
    );
  }

  /// Menjalankan request pencarian langsung ke Open-Meteo Geocoding API.
  Future<void> search([String? overrideQuery]) async {
    _debounceTimer?.cancel();
    final target = (overrideQuery ?? _query).trim();
    _query = overrideQuery ?? _query;

    if (target.isEmpty) {
      clearSearch();
      return;
    }

    final token = ++_searchToken;
    _isLoading = true;
    _errorMessage = null;
    _hasSearched = true;
    notifyListeners();

    try {
      final fetched = await _apiService.searchLocations(target);
      if (token != _searchToken) return;
      _results = fetched;
    } on WeatherApiException catch (e) {
      if (token != _searchToken) return;
      _errorMessage = e.message;
      _results = [];
    } catch (_) {
      if (token != _searchToken) return;
      _errorMessage = 'Gagal mencari lokasi. Silakan coba lagi.';
      _results = [];
    } finally {
      if (token == _searchToken) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Mengosongkan hasil dan status pencarian.
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchToken++;
    _query = '';
    _results = [];
    _isLoading = false;
    _errorMessage = null;
    _hasSearched = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
