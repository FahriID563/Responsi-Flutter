import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/local_storage_service.dart';
import 'services/open_meteo_service.dart';
import 'viewmodels/location_search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_weather_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WeatherApp());
}

/// Root widget aplikasi cuaca dengan arsitektur MVVM dan Provider.
class WeatherApp extends StatelessWidget {
  WeatherApp({
    super.key,
    OpenMeteoService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? OpenMeteoService(),
        _storageService = storageService ?? LocalStorageService();

  final OpenMeteoService _apiService;
  final LocalStorageService _storageService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            apiService: _apiService,
            storageService: _storageService,
          )..initialize(),
        ),
        ChangeNotifierProvider<LocationSearchViewModel>(
          create: (_) => LocationSearchViewModel(
            apiService: _apiService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'WeatherApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeWeatherScreen(),
      ),
    );
  }
}
