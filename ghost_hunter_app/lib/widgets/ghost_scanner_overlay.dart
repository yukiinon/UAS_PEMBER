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
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.isScanning) {
      _startScanning();
    }
  }

  void _startScanning() {
    _scanController.repeat();
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
    
    // Auto selesai scan setelah 3-5 detik
    Future.delayed(Duration(seconds: 3 + Random().nextInt(3)), () {
      if (mounted) {
        _scanController.stop();
        _pulseController.stop();
        _rippleController.stop();
        widget.onScanComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.4),
      child: Stack(
        children: [
          // Ripple effect
          Center(
            child: AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 0.3;
                    final animValue = (_rippleController.value - delay).clamp(0.0, 1.0);
                    
                    return Container(
                      width: 300 * animValue,
                      height: 300 * animValue,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5 - animValue * 0.5),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          
          // Lingkaran scanning utama
          Center(
            child: AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _scanController.value * 2 * pi,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(0.8),
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Garis scanning merah
                        Positioned(
                          top: 0,
                          left: 122,
                          child: Container(
                            width: 6,
                            height: 125,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.red,
                                  Colors.red.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Titik-titik seram di lingkaran
                        ...List.generate(8, (index) {
                          final angle = (index * pi / 4);
                          return Positioned(
                            top: 125 + cos(angle) * 110,
                            left: 125 + sin(angle) * 110,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
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
                  width: 30 + (_pulseController.value * 20),
                  height: 30 + (_pulseController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.9 - _pulseController.value * 0.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20 + (_pulseController.value * 10),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.visibility,
                    color: Colors.white,
                    size: 16,
                  ),
                );
              },
            ),
          ),
          
          // Teks scanning dengan efek berkedip
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.7 + (_pulseController.value * 0.3),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '💀 MEMANGGIL ARWAH DARI KEGELAPAN 💀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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
                );
              },
            ),
          ),
          
          // Partikel mengambang
          ...List.generate(10, (index) {
            return AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                final offset = Offset(
                  sin(_scanController.value * 2 * pi + index) * 100,
                  cos(_scanController.value * 2 * pi + index) * 100,
                );
                
                return Positioned(
                  top: MediaQuery.of(context).size.height / 2 + offset.dy,
                  left: MediaQuery.of(context).size.width / 2 + offset.dx,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}