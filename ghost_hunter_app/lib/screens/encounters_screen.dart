import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ghost_encounter.dart';
import '../widgets/encounter_card.dart';

class EncountersScreen extends StatefulWidget {
  @override
  _EncountersScreenState createState() => _EncountersScreenState();
}

class _EncountersScreenState extends State<EncountersScreen> {
  List<GhostEncounter> _encounters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEncounters();
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
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Hapus Semua Perjumpaan',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus semua perjumpaan hantu? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('ghost_encounters');
                setState(() {
                  _encounters.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Semua perjumpaan telah dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Hapus Semua',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '👻 Perjumpaan Saya',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (_encounters.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: _clearAllEncounters,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : _encounters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '👻',
                        style: TextStyle(fontSize: 64),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum Ada Perjumpaan Hantu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mulai memindai untuk mendeteksi aktivitas paranormal',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Mulai Berburu Hantu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header Statistik
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total Perjumpaan',
                            _encounters.length.toString(),
                            Colors.green,
                          ),
                          _buildStatItem(
                            'Aktivitas Tinggi',
                            _encounters.where((e) => 
                              e.activityLevel.toLowerCase() == 'tinggi' ||
                              e.activityLevel.toLowerCase() == 'ekstrem'
                            ).length.toString(),
                            Colors.red,
                          ),
                          _buildStatItem(
                            'Minggu Ini',
                            _encounters.where((e) => 
                              DateTime.now().difference(e.timestamp).inDays < 7
                            ).length.toString(),
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),
                    
                    // Daftar Perjumpaan
                    Expanded(
                      child: ListView.builder(
                        itemCount: _encounters.length,
                        itemBuilder: (context, index) {
                          return EncounterCard(encounter: _encounters[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
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
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}