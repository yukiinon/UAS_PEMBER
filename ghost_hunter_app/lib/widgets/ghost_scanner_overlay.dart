import 'package:flutter/material.dart';
import 'dart:math';

class GhostScannerOverlay extends StatefulWidget {
  final bool isScanning;
  final VoidCallback? onScanComplete;

  const GhostScannerOverlay({
    Key? key,
    required this.isScanning,
    this.onScanComplete,
  }) : super(key: key);

  @override
  State<GhostScannerOverlay> createState() => _GhostScannerOverlayState();
}

class _GhostScannerOverlayState extends State<GhostScannerOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.isScanning) {
      _startScanning();
    }
  }

  void _startScanning() {
    _scanController.repeat();
    _pulseController.repeat(reverse: true);
    
    // Auto selesai scan setelah 3-5 detik
    Future.delayed(Duration(seconds: 3 + Random().nextInt(3)), () {
      if (mounted) {
        _scanController.stop();
        _pulseController.stop();
        widget.onScanComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.3),
      child: Stack(
        children: [
          // Lingkaran scanning
          Center(
            child: AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _scanController.value * 2 * pi,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withOpacity(0.8),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Garis scanning
                        Positioned(
                          top: 0,
                          left: 98,
                          child: Container(
                            width: 4,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green,
                                  Colors.green.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Titik tengah berkedip
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 20 + (_pulseController.value * 10),
                  height: 20 + (_pulseController.value * 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.8 - _pulseController.value * 0.3),
                  ),
                );
              },
            ),
          ),
          
          // Teks scanning
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'MEMINDAI AKTIVITAS PARANORMAL...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}