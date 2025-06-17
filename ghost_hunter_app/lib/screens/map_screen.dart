import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';
import '../services/location_service.dart';
import '../models/haunted_location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  Position? _currentPosition;
  List<HauntedLocation> _hauntedLocations = [];
  bool _isLoading = true;
  int _selectedLocationIndex = -1;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _flickerController;
  late AnimationController _rotateController;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeMap();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _radarController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _rotateController.repeat();
    _radarController.repeat();
    
    // Random flicker effect
    Timer.periodic(Duration(seconds: 3 + Random().nextInt(7)), (timer) {
      if (mounted) {
        _flickerController.forward().then((_) {
          _flickerController.reverse();
        });
      }
    });
  }

  Future<void> _initializeMap() async {
    try {
      _currentPosition = await LocationService.getCurrentLocation();
      
      if (_currentPosition != null) {
        _hauntedLocations = _generateHauntedLocations();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error menginisialisasi peta: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<HauntedLocation> _generateHauntedLocations() {
    final random = Random();
    return [
      HauntedLocation(
        id: '1',
        name: 'Kuburan Tua Angker',
        description: 'Kuburan kuno yang dipenuhi arwah gentayangan. Sering terdengar suara tangisan di malam hari.',
        latitude: (_currentPosition?.latitude ?? -6.2088) + (random.nextDouble() - 0.5) * 0.01,
        longitude: (_currentPosition?.longitude ?? 106.8456) + (random.nextDouble() - 0.5) * 0.01,
        activityLevel: 'Ekstrem',
        icon: '⚰️',
      ),
      HauntedLocation(
        id: '2',
        name: 'Rumah Kosong Berhantu',
        description: 'Rumah tua yang ditinggalkan pemiliknya. Lampu sering menyala sendiri di malam hari.',
        latitude: (_currentPosition?.latitude ?? -6.2088) + (random.nextDouble() - 0.5) * 0.01,
        longitude: (_currentPosition?.longitude ?? 106.8456) + (random.nextDouble() - 0.5) * 0.01,
        activityLevel: 'Tinggi',
        icon: '🏚️',
      ),
      HauntedLocation(
        id: '3',
        name: 'Jembatan Setan',
        description: 'Jembatan tua tempat banyak kecelakaan misterius. Arwah korban masih berkeliaran.',
        latitude: (_currentPosition?.latitude ?? -6.2088) + (random.nextDouble() - 0.5) * 0.01,
        longitude: (_currentPosition?.longitude ?? 106.8456) + (random.nextDouble() - 0.5) * 0.01,
        activityLevel: 'Tinggi',
        icon: '🌉',
      ),
      HauntedLocation(
        id: '4',
        name: 'Hutan Keramat',
        description: 'Hutan yang dianggap keramat oleh penduduk setempat. Banyak penampakan makhluk halus.',
        latitude: (_currentPosition?.latitude ?? -6.2088) + (random.nextDouble() - 0.5) * 0.01,
        longitude: (_currentPosition?.longitude ?? 106.8456) + (random.nextDouble() - 0.5) * 0.01,
        activityLevel: 'Sedang',
        icon: '🌲',
      ),
      HauntedLocation(
        id: '5',
        name: 'Sekolah Terbengkalai',
        description: 'Bekas sekolah yang sudah lama ditutup. Sering terdengar suara anak-anak bermain.',
        latitude: (_currentPosition?.latitude ?? -6.2088) + (random.nextDouble() - 0.5) * 0.01,
        longitude: (_currentPosition?.longitude ?? 106.8456) + (random.nextDouble() - 0.5) * 0.01,
        activityLevel: 'Sedang',
        icon: '🏫',
      ),
    ];
  }

  Color _getActivityLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'rendah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'tinggi':
        return Colors.red;
      case 'ekstrem':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _flickerController.dispose();
    _rotateController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              const Color(0xFF1A0000),
              const Color(0xFF0A0A0A),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header dengan animasi
              AnimatedBuilder(
                animation: _flickerController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - (_flickerController.value * 0.2),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.red, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                // Rotating skull
                                AnimatedBuilder(
                                  animation: _rotateController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _rotateController.value * 2 * pi,
                                      child: Text(
                                        '💀',
                                        style: TextStyle(
                                          fontSize: 35,
                                          shadows: [
                                            Shadow(
                                              color: Colors.red.withOpacity(0.8),
                                              offset: Offset(0, 0),
                                              blurRadius: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'PETA KEMATIAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.red,
                                        offset: Offset(0, 0),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'REALM OF THE DAMNED',
                                  style: TextStyle(
                                    color: Colors.red.withOpacity(0.7),
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 48),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Radar scanning effect
                            AnimatedBuilder(
                              animation: _radarController,
                              builder: (context, child) {
                                return Container(
                                  width: 150,
                                  height: 150,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Radar circles
                                      for (int i = 0; i < 3; i++)
                                        Container(
                                          width: 50.0 + (i * 30) + (_radarController.value * 20),
                                          height: 50.0 + (i * 30) + (_radarController.value * 20),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.red.withOpacity(0.8 - (i * 0.2) - _radarController.value * 0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      // Center icon
                                      Icon(
                                        Icons.radar,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            AnimatedBuilder(
                              animation: _flickerController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: 1.0 - (_flickerController.value * 0.3),
                                  child: Text(
                                    'MEMINDAI DIMENSI KEMATIAN...',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : _currentPosition == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Floating warning icon
                                AnimatedBuilder(
                                  animation: _floatController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, sin(_floatController.value * 2 * pi) * 10),
                                      child: Icon(
                                        Icons.location_off,
                                        color: Colors.red,
                                        size: 80,
                                        shadows: [
                                          Shadow(
                                            color: Colors.red.withOpacity(0.5),
                                            offset: Offset(0, 0),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'PORTAL TERTUTUP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Tidak dapat mengakses dimensi lokasi\nAktifkan layanan lokasi untuk membuka portal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Current Location Info
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF1A0000),
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2 + _pulseController.value * 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.my_location,
                                            color: Colors.blue,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '🔮 LOKASI ANDA SAAT INI',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Haunted Locations List
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _hauntedLocations.length,
                                  itemBuilder: (context, index) {
                                    final location = _hauntedLocations[index];
                                    final distance = Geolocator.distanceBetween(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                      location.latitude,
                                      location.longitude,
                                    );
                                    
                                    return AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedLocationIndex = _selectedLocationIndex == index ? -1 : index;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getActivityLevelColor(location.activityLevel)
                                                      .withOpacity(0.2 + _pulseController.value * 0.2),
                                                  blurRadius: 15,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Card(
                                              color: Colors.transparent,
                                              elevation: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xFF1A1A1A),
                                                      Colors.black.withOpacity(0.8),
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(15),
                                                  border: Border.all(
                                                    color: _getActivityLevelColor(location.activityLevel)
                                                        .withOpacity(0.3 + _pulseController.value * 0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          // Icon dengan animasi float
                                                          AnimatedBuilder(
                                                            animation: _floatController,
                                                            builder: (context, child) {
                                                              return Transform.translate(
                                                                offset: Offset(0, sin((_floatController.value + index * 0.2) * 2 * pi) * 3),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(12),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black.withOpacity(0.5),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    border: Border.all(
                                                                      color: _getActivityLevelColor(location.activityLevel).withOpacity(0.3),
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    location.icon,
                                                                    style: TextStyle(fontSize: 24),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(width: 15),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  location.name,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.bold,
                                                                    shadows: [
                                                                      Shadow(
                                                                        color: _getActivityLevelColor(location.activityLevel),
                                                                        offset: Offset(0, 0),
                                                                        blurRadius: 8,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(height: 5),
                                                                Row(
                                                                  children: [
                                                                    Icon(Icons.location_on, color: Colors.red, size: 14),
                                                                    SizedBox(width: 5),
                                                                    Text(
                                                                      '${(distance / 1000).toStringAsFixed(1)} km',
                                                                      style: TextStyle(
                                                                        color: Colors.grey[400],
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                            decoration: BoxDecoration(
                                                              color: _getActivityLevelColor(location.activityLevel),
                                                              borderRadius: BorderRadius.circular(12),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: _getActivityLevelColor(location.activityLevel).withOpacity(0.5),
                                                                  blurRadius: 8,
                                                                  spreadRadius: 1,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Text(
                                                              location.activityLevel.toUpperCase(),
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      
                                                      // Expanded details
                                                      if (_selectedLocationIndex == index) ...[
                                                        SizedBox(height: 15),
                                                        Container(
                                                          padding: EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.3),
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(
                                                              color: Colors.red.withOpacity(0.2),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                '👻 DESKRIPSI KUTUKAN:',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              SizedBox(height: 8),
                                                              Text(
                                                                location.description,
                                                                style: TextStyle(
                                                                  color: Colors.grey[300],
                                                                  fontSize: 13,
                                                                  fontStyle: FontStyle.italic,
                                                                  height: 1.3,
                                                                ),
                                                              ),
                                                              SizedBox(height: 12),
                                                              Text(
                                                                '📍 KOORDINAT TERKUTUK:',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Text(
                                                                'Lat: ${location.latitude.toStringAsFixed(6)}\nLng: ${location.longitude.toStringAsFixed(6)}',
                                                                style: TextStyle(
                                                                  color: Colors.grey[400],
                                                                  fontSize: 11,
                                                                  fontFamily: 'monospace',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
              
              // Bottom warning
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3 + _pulseController.value * 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '⚠️ PERINGATAN: Tempat-tempat ini dikutuk oleh arwah jahat. Kunjungi dengan risiko sendiri.',
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.9),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}