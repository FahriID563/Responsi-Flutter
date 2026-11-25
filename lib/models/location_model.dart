/// Model data untuk lokasi geografis hasil Geocoding API dan penyimpanan lokal.
class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.countryCode,
    this.timezone,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;
  final String? countryCode;
  final String? timezone;

  /// Lokasi default saat pertama kali aplikasi dijalankan sebelum ada riwayat.
  static const LocationModel defaultLocation = LocationModel(
    id: 1642911,
    name: 'Jakarta',
    latitude: -6.21462,
    longitude: 106.84513,
    country: 'Indonesia',
    admin1: 'Daerah Khusus Ibukota Jakarta',
    countryCode: 'ID',
    timezone: 'Asia/Jakarta',
  );

  /// Membuat [LocationModel] dari respons JSON Open-Meteo Geocoding API.
  factory LocationModel.fromGeocodingJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ??
          Object.hash(json['name'], json['latitude'], json['longitude']),
      name: (json['name'] as String?)?.trim() ?? 'Lokasi Tidak Diketahui',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?)?.trim(),
      admin1: (json['admin1'] as String?)?.trim(),
      countryCode: (json['country_code'] as String?)?.trim(),
      timezone: (json['timezone'] as String?)?.trim(),
    );
  }

  /// Membuat [LocationModel] dari JSON penyimpanan lokal (SharedPreferences).
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      countryCode: json['countryCode'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Mengonversi [LocationModel] menjadi Map JSON untuk penyimpanan lokal.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'countryCode': countryCode,
      'timezone': timezone,
    };
  }

  /// Menggabungkan wilayah administratif dan negara menjadi subtitle yang rapi.
  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.isNotEmpty && admin1 != name) admin1!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return parts.isEmpty ? formattedCoordinates : parts.join(', ');
  }

  /// Koordinat lintang dan bujur dalam format ringkas.
  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.id == id &&
        other.name == name &&
        (other.latitude - latitude).abs() < 0.0001 &&
        (other.longitude - longitude).abs() < 0.0001;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        latitude.toStringAsFixed(4),
        longitude.toStringAsFixed(4),
      );
}
