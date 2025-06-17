import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async'; // ← TAMBAHKAN INI
import '../services/ghost_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../models/ghost_encounter.dart';
import '../widgets/ghost_scanner_overlay.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isScanning = false;
  bool _ghostDetected = false;
  GhostEncounter? _detectedGhost;
  String _statusMessage = 'Ketuk untuk memulai ritual...';
  
  late AnimationController _glitchController;
  late AnimationController _redFlashController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    // Animasi untuk efek glitch dan flash
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _redFlashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error menginisialisasi kamera: $e');
    }
  }

  Future<void> _startScanning() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _ghostDetected = false;
      _statusMessage = 'MEMANGGIL ARWAH DARI ALAM BAKA...';
    });
    
    // Efek glitch saat scanning
    _startGlitchEffect();
  }

  void _startGlitchEffect() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (_isScanning && mounted) {
        _glitchController.forward().then((_) {
          _glitchController.reverse();
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _onScanComplete() async {
    bool detected = GhostService.detectGhost();
    
    if (detected) {
      // Flash merah saat hantu terdeteksi
      _redFlashController.forward().then((_) {
        _redFlashController.reverse();
      });
      
      // Ambil foto
      String? photoPath = await _takePhoto();
      
      // Dapatkan lokasi
      String location = 'Dimensi Tidak Diketahui';
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        location = 'Koordinat Terkutuk: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }
      
      // Generate perjumpaan hantu
      final ghost = GhostService.generateRandomGhost(location, photoPath);
      
      // Simpan perjumpaan
      await _saveEncounter(ghost);
      
      // Tampilkan notifikasi
      await NotificationService.showGhostDetectedNotification(ghost.ghostName);
      
      setState(() {
        _ghostDetected = true;
        _detectedGhost = ghost;
        _statusMessage = '💀 KONTAK DENGAN ALAM BAKA BERHASIL! 💀';
      });
    } else {
      setState(() {
        _statusMessage = 'Arwah menolak untuk menampakkan diri...';
      });
    }
    
    setState(() {
      _isScanning = false;
    });
  }

  Future<String?> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photoPath = '${appDir.path}/arwah_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final XFile photo = await _controller!.takePicture();
      await photo.saveTo(photoPath);
      
      return photoPath;
    } catch (e) {
      print('Error mengambil foto: $e');
      return null;
    }
  }

  Future<void> _saveEncounter(GhostEncounter encounter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> encounters = prefs.getStringList('ghost_encounters') ?? [];
      encounters.add(jsonEncode(encounter.toJson()));
      await prefs.setStringList('ghost_encounters', encounters);
    } catch (e) {
      print('Error menyimpan perjumpaan: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _glitchController.dispose();
    _redFlashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.red.withOpacity(0.3),
                Colors.black,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.red,
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'MEMBUKA PORTAL...',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Preview Kamera dengan efek
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _glitchController.value * (Random().nextDouble() - 0.5) * 10,
                    _glitchController.value * (Random().nextDouble() - 0.5) * 10,
                  ),
                  child: CameraPreview(_controller!),
                );
              },
            ),
          ),
          
          // Overlay merah gelap
          Positioned.fill(
            child: Container(
              color: Colors.red.withOpacity(0.15),
            ),
          ),
          
          // Flash merah saat deteksi
          AnimatedBuilder(
            animation: _redFlashController,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  color: Colors.red.withOpacity(_redFlashController.value * 0.7),
                ),
              );
            },
          ),
          
          // Overlay Scanner
          if (_isScanning)
            GhostScannerOverlay(
              isScanning: _isScanning,
              onScanComplete: _onScanComplete,
            ),
          
          // Bar Atas dengan efek seram
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.red, size: 28),
                    onPressed: () => Navigator.pop(context, _ghostDetected),
                  ),
                  Expanded(
                    child: Text(
                      '💀 PORTAL ALAM BAKA 💀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            color: Colors.red,
                            offset: Offset(0, 0),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
          ),
          
          // Kontrol Bawah dengan desain seram
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pesan Status dengan efek berkedip
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ghostDetected ? Colors.red : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  if (_ghostDetected && _detectedGhost != null) ...[
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '👻 ${_detectedGhost!.ghostName.toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.red,
                                  offset: Offset(0, 0),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _detectedGhost!.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'TINGKAT BAHAYA: ${_detectedGhost!.activityLevel.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 30),
                  
                  // Tombol Ritual dengan efek seram
                  GestureDetector(
                    onTap: _isScanning ? null : _startScanning,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: _isScanning 
                              ? [Colors.grey[800]!, Colors.grey[900]!]
                              : [Colors.red, const Color(0xFF8B0000)],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isScanning ? Colors.grey : Colors.red,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isScanning ? Icons.hourglass_empty : Icons.visibility,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  
                  Text(
                    _isScanning ? 'RITUAL BERLANGSUNG...' : 'MULAI RITUAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}