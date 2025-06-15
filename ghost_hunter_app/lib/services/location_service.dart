import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/haunted_location.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error mendapatkan lokasi: $e');
      return null;
    }
  }

  static List<HauntedLocation> generateNearbyHauntedLocations(
    double centerLat, 
    double centerLng
  ) {
    final List<Map<String, String>> locationTemplates = [
      {'name': 'Gedung Sekolah Tua', 'icon': '🏚️'},
      {'name': 'Gereja Terbengkalai', 'icon': '⛪'},
      {'name': 'Hutan Gelap', 'icon': '🌳'},
      {'name': 'Rumah Sakit Lama', 'icon': '🏥'},
      {'name': 'Taman Pemakaman', 'icon': '⚰️'},
      {'name': 'Rumah Berhantu', 'icon': '🏠'},
      {'name': 'Jembatan Tua', 'icon': '🌉'},
      {'name': 'Pabrik Terbengkalai', 'icon': '🏭'},
    ];

    final List<String> descriptions = [
      'Suara aneh terdengar di malam hari',
      'Banyak penampakan hantu dilaporkan',
      'Titik dingin dan fenomena tak dijelaskan',
      'Aktivitas paranormal bersejarah',
      'Legenda lokal menceritakan tentang arwah',
      'Cahaya misterius terlihat melayang',
      'Pengunjung merasa diawasi',
      'Bekas kuburan kuno di dekatnya'
    ];

    final List<String> activityLevels = ['Rendah', 'Sedang', 'Tinggi', 'Ekstrem'];
    final random = Random();
    final locations = <HauntedLocation>[];

    for (int i = 0; i < 6; i++) {
      final template = locationTemplates[i % locationTemplates.length];
      
      // Generate lokasi acak dalam radius 5km
      final double randomLat = centerLat + (random.nextDouble() - 0.5) * 0.05;
      final double randomLng = centerLng + (random.nextDouble() - 0.5) * 0.05;

      locations.add(HauntedLocation(
        id: 'location_$i',
        name: template['name']!,
        latitude: randomLat,
        longitude: randomLng,
        description: descriptions[random.nextInt(descriptions.length)],
        activityLevel: activityLevels[random.nextInt(activityLevels.length)],
        icon: template['icon']!,
      ));
    }

    return locations;
  }
}