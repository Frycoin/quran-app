import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مصحف القرآن الكريم',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFFBF9F4),
      ),
      home: const SurahListScreen(),
    );
  }
}

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  List surahs = [];
  List filteredSurahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSurahs();
  }

  Future<void> fetchSurahs() async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          surahs = data['data'];
          filteredSurahs = surahs;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredSurahs = surahs.where((s) {
        return s['name'].toString().contains(query) ||
               s['number'].toString() == query;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المصحف الشريف', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF135D54),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: filterSearch,
                decoration: InputDecoration(
                  hintText: 'ابحث عن اسم السورة أو رقمها...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF135D54)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF135D54)))
                  : ListView.builder(
                      itemCount: filteredSurahs.length,
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF135D54),
                              foregroundColor: Colors.white,
                              child: Text('${surah['number']}'),
                            ),
                            title: Text(
                              surah['name'],
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'} • ${surah['numberOfAyahs']} آيات',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SurahDetailScreen(
                                    surahNumber: surah['number'],
                                    surahName: surah['name'],
                                  ),
                                ),
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
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({super.key, required this.surahNumber, required this.surahName});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List ayahs = [];
  bool isLoading = true;
  final AudioPlayer _player = AudioPlayer();
  int currentPlayingIndex = -1;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    fetchSurahDetails();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> fetchSurahDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surahNumber}/ar.alafasy'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ayahs = data['data']['ayahs'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playAyah(int index) async {
    if (currentPlayingIndex == index && isPlaying) {
      await _player.pause();
      setState(() => isPlaying = false);
    } else {
      await _player.stop();
      await _player.play(UrlSource(ayahs[index]['audio']));
      setState(() {
        currentPlayingIndex = index;
        isPlaying = true;
      });

      _player.onPlayerComplete.listen((event) {
        if (mounted && currentPlayingIndex + 1 < ayahs.length) {
          playAyah(currentPlayingIndex + 1);
        } else {
          setState(() {
            isPlaying = false;
            currentPlayingIndex = -1;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.surahName, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF135D54),
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF135D54)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = ayahs[index];
                  final bool isSelected = currentPlayingIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF135D54) : Colors.black12,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          ayah['text'],
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 22,
                            height: 2.0,
                            color: isSelected ? const Color(0xFF135D54) : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'آية رقم: ${ayah['numberInSurah']}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            IconButton(
                              icon: Icon(
                                isSelected && isPlaying ? Icons.pause_circle : Icons.play_circle,
                                color: const Color(0xFF135D54),
                                size: 32,
                              ),
                              onPressed: () => playAyah(index),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
