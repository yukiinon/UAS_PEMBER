import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // ← TAMBAHKAN INI
import 'dart:math';
import '../services/location_service.dart';
import '../services/ghost_service.dart';
import '../services/notification_service.dart';
import 'camera_screen.dart';
import 'map_screen.dart';
import 'encounters_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _currentLocation = 'Mendapatkan lokasi...';
  String _ghostActivity = 'Tidak Diketahui';
  DateTime? _lastScan;
  
  late AnimationController _flickerController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateGhostActivity();
    
    // Animasi untuk efek seram
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Mulai animasi
    _startSpookyAnimations();
    
    // Kirim notifikasi acak setelah 30 detik
    Future.delayed(Duration(seconds: 30), () {
      NotificationService.showRandomGhostAlert();
    });
  }

  void _startSpookyAnimations() {
    // Flicker effect acak
    Timer.periodic(Duration(seconds: 5 + Random().nextInt(10)), (timer) {
      if (mounted) {
        _flickerController.forward().then((_) {
          _flickerController.reverse();
        });
      }
    });
    
    // Pulse effect kontinyu
    _pulseController.repeat(reverse: true);
    
    // Float effect kontinyu
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _flickerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentLocation = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        });
      } else {
        setState(() {
          _currentLocation = 'Lokasi tidak tersedia';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Error mendapatkan lokasi';
      });
    }
  }

  void _updateGhostActivity() {
    setState(() {
      _ghostActivity = GhostService.getRandomActivityLevel();
    });
  }

  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              const Color(0xFF1A0000), // Dark red
              const Color(0xFF0A0A0A), // Black
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header dengan efek flicker
                  AnimatedBuilder(
                    animation: _flickerController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1.0 - (_flickerController.value * 0.3),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              // Floating ghost emoji
                              AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, sin(_floatController.value * 2 * pi) * 10),
                                    child: Text(
                                      '👻',
                                      style: TextStyle(
                                        fontSize: 60,
                                        shadows: [
                                          Shadow(
                                            color: Colors.red.withOpacity(0.8),
                                            offset: Offset(0, 0),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10),
                              Text(
                                'DETEKTOR HANTU',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.red,
                                      offset: Offset(0, 0),
                                      blurRadius: 15,
                                    ),
                                    Shadow(
                                      color: Colors.red.withOpacity(0.5),
                                      offset: Offset(2, 2),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'REALM OF THE DEAD',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.withOpacity(0.8),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Status Card dengan efek seram
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3 + _pulseController.value * 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Card(
                          color: const Color(0xFF1A1A1A),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'LOKASI TERKUTUK:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _currentLocation,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 20),
                                
                                Row(
                                  children: [
                                    Text(
                                      '💀 AKTIVITAS ARWAH: ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getActivityColor(_ghostActivity),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getActivityColor(_ghostActivity).withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        _ghostActivity.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                if (_lastScan != null) ...[
                                  SizedBox(height: 12),
                                  Text(
                                    '⚰️ RITUAL TERAKHIR: ${_lastScan!.hour}:${_lastScan!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Action Buttons dengan efek seram
                  _buildSpookyActionButton(
                    icon: '📸',
                    title: 'RITUAL PEMANGGILAN',
                    subtitle: 'Panggil arwah dengan kamera mistis',
                    colors: [const Color(0xFF8B0000), const Color(0xFF4B0000)],
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraScreen()),
                      );
                      if (result == true) {
                        setState(() {
                          _lastScan = DateTime.now();
                        });
                      }
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildSpookyActionButton(
                    icon: '🗺️',
                    title: 'PETA KEMATIAN',
                    subtitle: 'Jelajahi tempat-tempat terkutuk',
                    colors: [const Color(0xFF4B0082), const Color(0xFF2F0052)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapScreen()),
                      );
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildSpookyActionButton(
                    icon: '💀',
                    title: 'BUKU KEMATIAN',
                    subtitle: 'Catatan perjumpaan dengan alam baka',
                    colors: [const Color(0xFF006400), const Color(0xFF003200)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EncountersScreen()),
                      );
                    },
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Warning text
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'PERINGATAN: Aplikasi ini dapat membuka portal ke alam lain. Gunakan dengan hati-hati.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpookyActionButton({
    required String icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 5),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                icon,
                style: TextStyle(fontSize: 30),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}