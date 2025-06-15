import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = 'Mendapatkan lokasi...';
  String _ghostActivity = 'Tidak Diketahui';
  DateTime? _lastScan;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateGhostActivity();
    
    // Kirim notifikasi acak setelah 30 detik
    Future.delayed(Duration(seconds: 30), () {
      NotificationService.showRandomGhostAlert();
    });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '👻 Detektor Hantu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Kartu Status
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Lokasi Saat Ini:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                          '🎲 Aktivitas Hantu: ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getActivityColor(_ghostActivity),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _ghostActivity,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (_lastScan != null) ...[
                      SizedBox(height: 12),
                      Text(
                        '⏰ Scan Terakhir: ${_lastScan!.hour}:${_lastScan!.minute.toString().padLeft(2, '0')}',
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
            
            SizedBox(height: 40),
            
            // Tombol Aksi
            _buildActionButton(
              icon: '📸',
              title: 'PINDAI HANTU',
              subtitle: 'Gunakan kamera untuk mendeteksi arwah',
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
            
            _buildActionButton(
              icon: '📍',
              title: 'PETA BERHANTU',
              subtitle: 'Jelajahi lokasi berhantu di sekitar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
            ),
            
            SizedBox(height: 16),
            
            _buildActionButton(
              icon: '👻',
              title: 'PERJUMPAAN SAYA',
              subtitle: 'Lihat riwayat perjumpaan hantu Anda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EncountersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[900]!, Colors.purple[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 30),
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
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
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