import 'package:flutter/material.dart';
import '../models/ghost_encounter.dart';
import 'dart:io';
import 'dart:math';
import 'dart:async';

class EncounterCard extends StatefulWidget {
  final GhostEncounter encounter;

  const EncounterCard({Key? key, required this.encounter}) : super(key: key);

  @override
  State<EncounterCard> createState() => _EncounterCardState();
}

class _EncounterCardState extends State<EncounterCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late AnimationController _flickerController;
  
  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // Start glow animation
    _glowController.repeat(reverse: true);
    
    // Random flicker effect
    Timer.periodic(Duration(seconds: 8 + Random().nextInt(12)), (timer) {
      if (mounted) {
        _flickerController.forward().then((_) {
          _flickerController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  Color _getActivityColor(String level) {
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _glowController, _flickerController]),
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _hoverController.forward(),
          onTapUp: (_) => _hoverController.reverse(),
          onTapCancel: () => _hoverController.reverse(),
          child: Container(
            // Fixed margin untuk alignment yang konsisten
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Transform.scale(
              scale: 1.0 - (_hoverController.value * 0.02),
              child: Opacity(
                opacity: 1.0 - (_flickerController.value * 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getActivityColor(widget.encounter.activityLevel)
                            .withOpacity(0.2 + _glowController.value * 0.3),
                        blurRadius: 15 + (_glowController.value * 10),
                        spreadRadius: 2,
                        offset: Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    margin: EdgeInsets.zero, // Remove default card margin
                    child: Container(
                      width: double.infinity, // Ensure full width
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1A1A1A),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getActivityColor(widget.encounter.activityLevel)
                              .withOpacity(0.3 + _glowController.value * 0.2),
                          width: 1 + (_glowController.value * 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header dengan ghost icon beranimasi
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: _getActivityColor(widget.encounter.activityLevel)
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Transform.rotate(
                                    angle: sin(_glowController.value * 2 * pi) * 0.1,
                                    child: Text(
                                      '👻',
                                      style: TextStyle(
                                        fontSize: 28,
                                        shadows: [
                                          Shadow(
                                            color: _getActivityColor(widget.encounter.activityLevel),
                                            offset: Offset(0, 0),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.encounter.ghostName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: _getActivityColor(widget.encounter.activityLevel),
                                              offset: Offset(0, 0),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '💀 ENTITAS SUPERNATURAL',
                                          style: TextStyle(
                                            color: Colors.red.withOpacity(0.8),
                                            fontSize: 10,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Activity level badge dengan glow
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getActivityColor(widget.encounter.activityLevel),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getActivityColor(widget.encounter.activityLevel)
                                            .withOpacity(0.5 + _glowController.value * 0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget.encounter.activityLevel.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Description dengan container seram
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.encounter.description,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Photo dengan efek seram
                            if (widget.encounter.photoPath != null)
                              Container(
                                width: double.infinity, // Ensure full width
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getActivityColor(widget.encounter.activityLevel)
                                        .withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getActivityColor(widget.encounter.activityLevel)
                                          .withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        File(widget.encounter.photoPath!),
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 180,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey[800]!,
                                                  Colors.grey[900]!,
                                                ],
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[600],
                                                  size: 50,
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'FOTO HILANG DALAM KEGELAPAN',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      // Overlay efek paranormal
                                      Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              _getActivityColor(widget.encounter.activityLevel)
                                                  .withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Label foto
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.red.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '📸 BUKTI SUPERNATURAL',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            
                            SizedBox(height: 15),
                            
                            // Footer info dengan animasi
                            Container(
                              width: double.infinity, // Ensure full width
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
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.red, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'LOKASI TERKUTUK:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    widget.encounter.location,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.red, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'WAKTU KONTAK:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        '${widget.encounter.timestamp.day}/${widget.encounter.timestamp.month}/${widget.encounter.timestamp.year} ${widget.encounter.timestamp.hour}:${widget.encounter.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
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
              ),
            ),
          ),
        );
      },
    );
  }
}