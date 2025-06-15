import 'dart:math';
import '../models/ghost_encounter.dart';

class GhostService {
  static final List<String> _ghostNames = [
    'Wanita Menangis',
    'Bayangan Hitam', 
    'Wanita Berbaju Putih',
    'Arwah Kakek Tua',
    'Hantu Anak Kecil',
    'Bola Cahaya Mengambang',
    'Entitas Gelap',
    'Jiwa Tersesat',
    'Pocong Gentayangan',
    'Kuntilanak',
    'Sundel Bolong',
    'Tuyul Nakal'
  ];

  static final List<String> _ghostDescriptions = [
    'Sosok misterius berbaju putih panjang',
    'Bayangan gelap bergerak cepat',
    'Bola cahaya bersinar terang',
    'Kakek tua berpakaian lusuh',
    'Anak kecil bermain sendirian',
    'Entitas transparan melayang',
    'Kehadiran gelap yang menakutkan',
    'Arwah yang mencari ketenangan',
    'Kain kafan putih melompat-lompat',
    'Wanita berambut panjang menakutkan',
    'Sosok wanita dengan lubang di punggung',
    'Makhluk kecil pencuri uang'
  ];

  static final List<String> _activityLevels = [
    'Rendah', 'Sedang', 'Tinggi', 'Ekstrem'
  ];

  static bool detectGhost() {
    // 60% kemungkinan mendeteksi hantu
    return Random().nextInt(100) < 60;
  }

  static GhostEncounter generateRandomGhost(String location, String? photoPath) {
    final random = Random();
    
    return GhostEncounter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ghostName: _ghostNames[random.nextInt(_ghostNames.length)],
      description: _ghostDescriptions[random.nextInt(_ghostDescriptions.length)],
      location: location,
      timestamp: DateTime.now(),
      photoPath: photoPath,
      activityLevel: _activityLevels[random.nextInt(_activityLevels.length)],
    );
  }

  static String getRandomActivityLevel() {
    return _activityLevels[Random().nextInt(_activityLevels.length)];
  }
}