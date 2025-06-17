import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import '../models/ghost_encounter.dart';
import '../widgets/encounter_card.dart';

class EncountersScreen extends StatefulWidget {
  @override
  _EncountersScreenState createState() => _EncountersScreenState();
}

class _EncountersScreenState extends State<EncountersScreen> with TickerProviderStateMixin {
  List<GhostEncounter> _encounters = [];
  bool _isLoading = true;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _flickerController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadEncounters();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _rotateController.repeat();
    
    // Random flicker effect
    Timer.periodic(Duration(seconds: 4 + Random().nextInt(6)), (timer) {
      if (mounted) {
        _flickerController.forward().then((_) {
          _flickerController.reverse();
        });
      }
    });
  }

  Future<void> _loadEncounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> encounterStrings = prefs.getStringList('ghost_encounters') ?? [];
      
      _encounters = encounterStrings.map((encounterString) {
        return GhostEncounter.fromJson(jsonDecode(encounterString));
      }).toList();
      
      // Urutkan berdasarkan waktu (terbaru dulu)
      _encounters.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      setState(() {
        _isLoading = false;
      });
      
      // Animate fade in dengan delay
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _fadeController.forward();
        }
      });
      
    } catch (e) {
      print('Error memuat perjumpaan: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllEncounters() async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A0000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.red.withOpacity(0.5 + _pulseController.value * 0.3),
                  width: 2,
                ),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'HAPUS SEMUA JIWA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              content: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '💀 Apakah Anda yakin ingin menghapus semua catatan perjumpaan dengan alam baka? \n\n⚠️ Arwah-arwah ini akan hilang selamanya dari dunia ini.',
                  style: TextStyle(
                    color: Colors.grey[300],
                    height: 1.4,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'BATALKAN',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('ghost_encounters');
                    setState(() {
                      _encounters.clear();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('💀 Semua arwah telah dibebaskan ke alam baka'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'HAPUS SEMUA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _flickerController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
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
                                // Floating book icon
                                AnimatedBuilder(
                                  animation: _floatController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, sin(_floatController.value * 2 * pi) * 8),
                                      child: Text(
                                        '📖',
                                        style: TextStyle(
                                          fontSize: 40,
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
                                  'BUKU KEMATIAN',
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
                                  'CHRONICLES OF THE DAMNED',
                                  style: TextStyle(
                                    color: Colors.red.withOpacity(0.7),
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_encounters.isNotEmpty)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3 + _pulseController.value * 0.2),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.delete_sweep, color: Colors.red, size: 28),
                                    onPressed: _clearAllEncounters,
                                  ),
                                );
                              },
                            ),
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
                            // Rotating loading indicator
                            AnimatedBuilder(
                              animation: _rotateController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateController.value * 2 * pi,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.8),
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.auto_stories,
                                      color: Colors.red,
                                      size: 35,
                                    ),
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
                                    'MEMBACA CATATAN KEMATIAN...',
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
                    : _encounters.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Floating empty book
                                AnimatedBuilder(
                                  animation: _floatController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, sin(_floatController.value * 2 * pi) * 15),
                                      child: Container(
                                        padding: EdgeInsets.all(30),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red.withOpacity(0.1),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          '📖',
                                          style: TextStyle(
                                            fontSize: 80,
                                            shadows: [
                                              Shadow(
                                                color: Colors.red.withOpacity(0.5),
                                                offset: Offset(0, 0),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 30),
                                Text(
                                  'BUKU MASIH KOSONG',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
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
                                SizedBox(height: 15),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Belum ada catatan perjumpaan dengan alam baka\nMulai ritual pemanggilan untuk mengisi halaman ini',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3 + _pulseController.value * 0.2),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF8B0000),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.auto_stories, color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'MULAI MENULIS SEJARAH',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Stats Header dengan animasi fade
                              AnimatedBuilder(
                                animation: _fadeController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _fadeController.value,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF1A0000),
                                            Colors.black.withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.2),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '💀 STATISTIK KEMATIAN 💀',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildAnimatedStatItem(
                                                'TOTAL JIWA',
                                                _encounters.length.toString(),
                                                Colors.green,
                                                Icons.psychology,
                                              ),
                                              _buildAnimatedStatItem(
                                                'BAHAYA TINGGI',
                                                _encounters.where((e) => 
                                                  e.activityLevel.toLowerCase() == 'tinggi' ||
                                                  e.activityLevel.toLowerCase() == 'ekstrem'
                                                ).length.toString(),
                                                Colors.red,
                                                Icons.warning,
                                              ),
                                              _buildAnimatedStatItem(
                                                'MINGGU INI',
                                                _encounters.where((e) => 
                                                  DateTime.now().difference(e.timestamp).inDays < 7
                                                ).length.toString(),
                                                Colors.purple,
                                                Icons.calendar_today,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              // Encounters List dengan animasi fade yang lebih smooth
                              Expanded(
                                child: AnimatedBuilder(
                                  animation: _fadeController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _fadeController.value,
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(bottom: 20),
                                        itemCount: _encounters.length,
                                        itemBuilder: (context, index) {
                                          // Menggunakan delay yang lebih kecil untuk animasi yang lebih smooth
                                          return AnimatedContainer(
                                            duration: Duration(milliseconds: 300 + (index * 50)),
                                            curve: Curves.easeOutBack,
                                            child: EncounterCard(encounter: _encounters[index]),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatItem(String label, String value, Color color, IconData icon) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1 + _pulseController.value * 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3 + _pulseController.value * 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}