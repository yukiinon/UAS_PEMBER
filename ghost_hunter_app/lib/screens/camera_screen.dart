import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../services/ghost_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../models/ghost_encounter.dart';
import '../widgets/ghost_scanner_overlay.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isScanning = false;
  bool _ghostDetected = false;
  GhostEncounter? _detectedGhost;
  String _statusMessage = 'Ketuk untuk mulai memindai';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
      _statusMessage = 'Memindai aktivitas paranormal...';
    });
  }

  Future<void> _onScanComplete() async {
    bool detected = GhostService.detectGhost();
    
    if (detected) {
      // Ambil foto
      String? photoPath = await _takePhoto();
      
      // Dapatkan lokasi
      String location = 'Lokasi Tidak Diketahui';
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        location = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
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
        _statusMessage = 'HANTU TERDETEKSI!';
      });
    } else {
      setState(() {
        _statusMessage = 'Tidak ada aktivitas paranormal terdeteksi';
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
      final String photoPath = '${appDir.path}/hantu_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Pemindai Hantu', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Preview Kamera
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          
          // Overlay hijau
          Positioned.fill(
            child: Container(
              color: Colors.green.withOpacity(0.1),
            ),
          ),
          
          // Overlay Scanner
          if (_isScanning)
            GhostScannerOverlay(
              isScanning: _isScanning,
              onScanComplete: _onScanComplete,
            ),
          
          // Bar Atas
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
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, _ghostDetected),
                  ),
                  Expanded(
                    child: Text(
                      'Pemindai Hantu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // Seimbangkan tombol kembali
                ],
              ),
            ),
          ),
          
          // Kontrol Bawah
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
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pesan Status
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _ghostDetected ? Colors.red : Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (_ghostDetected && _detectedGhost != null) ...[
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '👻 ${_detectedGhost!.ghostName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _detectedGhost!.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Tingkat Aktivitas: ${_detectedGhost!.activityLevel}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 20),
                  
                  // Tombol Scan
                  GestureDetector(
                    onTap: _isScanning ? null : _startScanning,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isScanning 
                            ? Colors.grey 
                            : Colors.green.withOpacity(0.8),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        _isScanning ? Icons.hourglass_empty : Icons.search,
                        color: Colors.white,
                        size: 30,
                      ),
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