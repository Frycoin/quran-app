import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranWarshTajweedApp());
}

class QuranWarshTajweedApp extends StatelessWidget {
  const QuranWarshTajweedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مصحف ورش والتجويد الملون',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        primaryColor: const Color(0xFF0A4D3C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A4D3C),
          primary: const Color(0xFF0A4D3C),
          secondary: const Color(0xFFD4AF37),
          surface: const Color(0xFFFDFBF7),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A4D3C),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainHomeScreen(),
    );
  }
}

class SurahModel {
  final int number;
  final String name;
  final String revelationType;
  final int versesCount;

  const SurahModel({
    required this.number,
    required this.name,
    required this.revelationType,
    required this.versesCount,
  });
}

class AyahModel {
  final int numberInSurah;
  final String text;
  final int page;
  final int juz;

  AyahModel({
    required this.numberInSurah,
    required this.text,
    required this.page,
    required this.juz,
  });
}

class BookmarkModel {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final DateTime timestamp;

  BookmarkModel({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.timestamp,
  });
}

class ReciterModel {
  final String name;
  final String serverUrl;
  final String description;

  const ReciterModel({
    required this.name,
    required this.serverUrl,
    required this.description,
  });
}

const List<ReciterModel> kWarshReciters = [
  ReciterModel(
    name: 'القارئ ياسين الجزائري',
    serverUrl: 'https://server11.mp3quran.net/qari/',
    description: 'رواية ورش عن نافع من طريق الأزرق',
  ),
  ReciterModel(
    name: 'الشيخ العيون الكوشي',
    serverUrl: 'https://server11.mp3quran.net/koshi/',
    description: 'رواية ورش عن نافع',
  ),
  ReciterModel(
    name: 'الشيخ عمر القزابري',
    serverUrl: 'https://server9.mp3quran.net/omar_warsh/',
    description: 'رواية ورش عن نافع',
  ),
];

const List<SurahModel> kAllSurahs = [
  SurahModel(number: 1, name: "الفاتحة", revelationType: "مكية", versesCount: 7),
  SurahModel(number: 2, name: "البقرة", revelationType: "مدنية", versesCount: 286),
  SurahModel(number: 3, name: "آل عمران", revelationType: "مدنية", versesCount: 200),
  SurahModel(number: 4, name: "النساء", revelationType: "مدنية", versesCount: 176),
  SurahModel(number: 5, name: "المائدة", revelationType: "مدنية", versesCount: 120),
  SurahModel(number: 6, name: "الأنعام", revelationType: "مكية", versesCount: 165),
  SurahModel(number: 7, name: "الأعراف", revelationType: "مكية", versesCount: 206),
  SurahModel(number: 8, name: "الأنفال", revelationType: "مدنية", versesCount: 75),
  SurahModel(number: 9, name: "التوبة", revelationType: "مدنية", versesCount: 129),
  SurahModel(number: 10, name: "يونس", revelationType: "مكية", versesCount: 109),
  SurahModel(number: 11, name: "هود", revelationType: "مكية", versesCount: 123),
  SurahModel(number: 12, name: "يوسف", revelationType: "مكية", versesCount: 111),
  SurahModel(number: 13, name: "الرعد", revelationType: "مدنية", versesCount: 43),
  SurahModel(number: 14, name: "إبراهيم", revelationType: "مكية", versesCount: 52),
  SurahModel(number: 15, name: "الحجر", revelationType: "مكية", versesCount: 99),
  SurahModel(number: 16, name: "النحل", revelationType: "مكية", versesCount: 128),
  SurahModel(number: 17, name: "الإسراء", revelationType: "مكية", versesCount: 111),
  SurahModel(number: 18, name: "الكهف", revelationType: "مكية", versesCount: 110),
  SurahModel(number: 19, name: "مريم", revelationType: "مكية", versesCount: 98),
  SurahModel(number: 20, name: "طه", revelationType: "مكية", versesCount: 135),
  SurahModel(number: 21, name: "الأنبياء", revelationType: "مكية", versesCount: 112),
  SurahModel(number: 22, name: "الحج", revelationType: "مدنية", versesCount: 78),
  SurahModel(number: 23, name: "المؤمنون", revelationType: "مكية", versesCount: 118),
  SurahModel(number: 24, name: "النور", revelationType: "مدنية", versesCount: 64),
  SurahModel(number: 25, name: "الفرقان", revelationType: "مكية", versesCount: 77),
  SurahModel(number: 26, name: "الشعراء", revelationType: "مكية", versesCount: 227),
  SurahModel(number: 27, name: "النمل", revelationType: "مكية", versesCount: 93),
  SurahModel(number: 28, name: "القصص", revelationType: "مكية", versesCount: 88),
  SurahModel(number: 29, name: "العنكبوت", revelationType: "مكية", versesCount: 69),
  SurahModel(number: 30, name: "الروم", revelationType: "مكية", versesCount: 60),
  SurahModel(number: 31, name: "لقمان", revelationType: "مكية", versesCount: 34),
  SurahModel(number: 32, name: "السجدة", revelationType: "مكية", versesCount: 30),
  SurahModel(number: 33, name: "الأحزاب", revelationType: "مدنية", versesCount: 73),
  SurahModel(number: 34, name: "سبأ", revelationType: "مكية", versesCount: 54),
  SurahModel(number: 35, name: "فاطر", revelationType: "مكية", versesCount: 45),
  SurahModel(number: 36, name: "يس", revelationType: "مكية", versesCount: 83),
  SurahModel(number: 37, name: "الصافات", revelationType: "مكية", versesCount: 182),
  SurahModel(number: 38, name: "ص", revelationType: "مكية", versesCount: 88),
  SurahModel(number: 39, name: "الزمر", revelationType: "مكية", versesCount: 75),
  SurahModel(number: 40, name: "غافر", revelationType: "مكية", versesCount: 85),
  SurahModel(number: 41, name: "فصلت", revelationType: "مكية", versesCount: 54),
  SurahModel(number: 42, name: "الشورى", revelationType: "مكية", versesCount: 53),
  SurahModel(number: 43, name: "الزخرف", revelationType: "مكية", versesCount: 89),
  SurahModel(number: 44, name: "الدخان", revelationType: "مكية", versesCount: 59),
  SurahModel(number: 45, name: "الجاثية", revelationType: "مكية", versesCount: 37),
  SurahModel(number: 46, name: "الأحقاف", revelationType: "مكية", versesCount: 35),
  SurahModel(number: 47, name: "محمد", revelationType: "مدنية", versesCount: 38),
  SurahModel(number: 48, name: "الفتح", revelationType: "مدنية", versesCount: 29),
  SurahModel(number: 49, name: "الحجرات", revelationType: "مدنية", versesCount: 18),
  SurahModel(number: 50, name: "ق", revelationType: "مكية", versesCount: 45),
  SurahModel(number: 51, name: "الذاريات", revelationType: "مكية", versesCount: 60),
  SurahModel(number: 52, name: "الطور", revelationType: "مكية", versesCount: 49),
  SurahModel(number: 53, name: "النجم", revelationType: "مكية", versesCount: 62),
  SurahModel(number: 54, name: "القمر", revelationType: "مكية", versesCount: 55),
  SurahModel(number: 55, name: "الرحمن", revelationType: "مدنية", versesCount: 78),
  SurahModel(number: 56, name: "الواقعة", revelationType: "مكية", versesCount: 96),
  SurahModel(number: 57, name: "الحديد", revelationType: "مدنية", versesCount: 29),
  SurahModel(number: 58, name: "المجادلة", revelationType: "مدنية", versesCount: 22),
  SurahModel(number: 59, name: "الحشر", revelationType: "مدنية", versesCount: 24),
  SurahModel(number: 60, name: "الممتحنة", revelationType: "مدنية", versesCount: 13),
  SurahModel(number: 61, name: "الصف", revelationType: "مدنية", versesCount: 14),
  SurahModel(number: 62, name: "الجمعة", revelationType: "مدنية", versesCount: 11),
  SurahModel(number: 63, name: "المنافقون", revelationType: "مدنية", versesCount: 11),
  SurahModel(number: 64, name: "التغابن", revelationType: "مدنية", versesCount: 18),
  SurahModel(number: 65, name: "الطلاق", revelationType: "مدنية", versesCount: 12),
  SurahModel(number: 66, name: "التحريم", revelationType: "مدنية", versesCount: 12),
  SurahModel(number: 67, name: "الملك", revelationType: "مكية", versesCount: 30),
  SurahModel(number: 68, name: "القلم", revelationType: "مكية", versesCount: 52),
  SurahModel(number: 69, name: "الحاقة", revelationType: "مكية", versesCount: 52),
  SurahModel(number: 70, name: "المعارج", revelationType: "مكية", versesCount: 44),
  SurahModel(number: 71, name: "نوح", revelationType: "مكية", versesCount: 28),
  SurahModel(number: 72, name: "الجن", revelationType: "مكية", versesCount: 28),
  SurahModel(number: 73, name: "المزمل", revelationType: "مكية", versesCount: 20),
  SurahModel(number: 74, name: "المدثر", revelationType: "مكية", versesCount: 56),
  SurahModel(number: 75, name: "القيامة", revelationType: "مكية", versesCount: 40),
  SurahModel(number: 76, name: "الإنسان", revelationType: "مدنية", versesCount: 31),
  SurahModel(number: 77, name: "المرسلات", revelationType: "مكية", versesCount: 50),
  SurahModel(number: 78, name: "النبأ", revelationType: "مكية", versesCount: 40),
  SurahModel(number: 79, name: "النازعات", revelationType: "مكية", versesCount: 46),
  SurahModel(number: 80, name: "عبس", revelationType: "مكية", versesCount: 42),
  SurahModel(number: 81, name: "التكوير", revelationType: "مكية", versesCount: 29),
  SurahModel(number: 82, name: "الانفطار", revelationType: "مكية", versesCount: 19),
  SurahModel(number: 83, name: "المطففين", revelationType: "مكية", versesCount: 36),
  SurahModel(number: 84, name: "الانشقاق", revelationType: "مكية", versesCount: 25),
  SurahModel(number: 85, name: "البروج", revelationType: "مكية", versesCount: 22),
  SurahModel(number: 86, name: "الطارق", revelationType: "مكية", versesCount: 17),
  SurahModel(number: 87, name: "الأعلى", revelationType: "مكية", versesCount: 19),
  SurahModel(number: 88, name: "الغاشية", revelationType: "مكية", versesCount: 26),
  SurahModel(number: 89, name: "الفجر", revelationType: "مكية", versesCount: 30),
  SurahModel(number: 90, name: "البلد", revelationType: "مكية", versesCount: 20),
  SurahModel(number: 91, name: "الشمس", revelationType: "مكية", versesCount: 15),
  SurahModel(number: 92, name: "الليل", revelationType: "مكية", versesCount: 21),
  SurahModel(number: 93, name: "الضحى", revelationType: "مكية", versesCount: 11),
  SurahModel(number: 94, name: "الشرح", revelationType: "مكية", versesCount: 8),
  SurahModel(number: 95, name: "التين", revelationType: "مكية", versesCount: 8),
  SurahModel(number: 96, name: "العلق", revelationType: "مكية", versesCount: 19),
  SurahModel(number: 97, name: "القدر", revelationType: "مكية", versesCount: 5),
  SurahModel(number: 98, name: "البينة", revelationType: "مدنية", versesCount: 8),
  SurahModel(number: 99, name: "الزلزلة", revelationType: "مدنية", versesCount: 8),
  SurahModel(number: 100, name: "العاديات", revelationType: "مكية", versesCount: 11),
  SurahModel(number: 101, name: "القارعة", revelationType: "مكية", versesCount: 11),
  SurahModel(number: 102, name: "التكاثر", revelationType: "مكية", versesCount: 8),
  SurahModel(number: 103, name: "العصر", revelationType: "مكية", versesCount: 3),
  SurahModel(number: 104, name: "الهمزة", revelationType: "مكية", versesCount: 9),
  SurahModel(number: 105, name: "الفيل", revelationType: "مكية", versesCount: 5),
  SurahModel(number: 106, name: "قريش", revelationType: "مكية", versesCount: 4),
  SurahModel(number: 107, name: "الماعون", revelationType: "مكية", versesCount: 7),
  SurahModel(number: 108, name: "الكوثر", revelationType: "مكية", versesCount: 3),
  SurahModel(number: 109, name: "الكافرون", revelationType: "مكية", versesCount: 6),
  SurahModel(number: 110, name: "النصر", revelationType: "مدنية", versesCount: 3),
  SurahModel(number: 111, name: "المسد", revelationType: "مكية", versesCount: 5),
  SurahModel(number: 112, name: "الإخلاص", revelationType: "مكية", versesCount: 4),
  SurahModel(number: 113, name: "الفلق", revelationType: "مكية", versesCount: 5),
  SurahModel(number: 114, name: "الناس", revelationType: "مكية", versesCount: 6),
];

class TajweedParser {
  static const Map<String, Color> ruleColors = {
    'ghunnah': Color(0xFF169777),
    'iqlab': Color(0xFF26BFFD),
    'qalqalah': Color(0xFF0055FF),
    'madd_normal': Color(0xFFD48B00),
    'madd_permissible': Color(0xFFFF6600),
    'madd_obligatory': Color(0xFFD50000),
    'ham_wasl': Color(0xFF9E9E9E),
  };

  static List<TextSpan> parseTajweedText(String rawText, bool enableTajweed) {
    if (!enableTajweed) {
      final cleanText = rawText.replaceAllMapped(
        RegExp(r'\[[a-zA-Z_]+(?::\d+)?\[([^\]]+)\]'),
        (match) => match.group(1) ?? '',
      );
      return [TextSpan(text: cleanText)];
    }

    if (rawText.contains('[')) {
      final List<TextSpan> spans = [];
      final RegExp regex = RegExp(r'\[([a-zA-Z_]+)(?::\d+)?\[([^\]]+)\]');
      int lastIndex = 0;

      for (final Match match in regex.allMatches(rawText)) {
        if (match.start > lastIndex) {
          spans.add(TextSpan(text: rawText.substring(lastIndex, match.start)));
        }
        final String ruleCode = match.group(1) ?? '';
        final String coloredSegment = match.group(2) ?? '';
        spans.add(
          TextSpan(
            text: coloredSegment,
            style: TextStyle(
              color: _mapShortCodeToColor(ruleCode),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        lastIndex = match.end;
      }

      if (lastIndex < rawText.length) {
        spans.add(TextSpan(text: rawText.substring(lastIndex)));
      }
      return spans;
    }

    return _applyHeuristicTajweed(rawText);
  }

  static Color _mapShortCodeToColor(String code) {
    switch (code) {
      case 'g':
      case 'c':
      case 'f':
      case 'w':
      case 'a':
        return ruleColors['ghunnah']!;
      case 'i':
        return ruleColors['iqlab']!;
      case 'q':
        return ruleColors['qalqalah']!;
      case 'n':
        return ruleColors['madd_normal']!;
      case 'p':
        return ruleColors['madd_permissible']!;
      case 'o':
      case 'm':
        return ruleColors['madd_obligatory']!;
      default:
        return const Color(0xFF1F1F1F);
    }
  }

  static List<TextSpan> _applyHeuristicTajweed(String text) {
    final List<TextSpan> spans = [];
    final RegExp ruleRegex = RegExp(r'([قطبجد]ْ|[نم]ّ|[اوي]?ٓ|[ٱ])');

    int lastIdx = 0;
    for (final match in ruleRegex.allMatches(text)) {
      if (match.start > lastIdx) {
        spans.add(TextSpan(text: text.substring(lastIdx, match.start)));
      }
      final String token = match.group(0)!;
      Color color = const Color(0xFF1F1F1F);

      if (token.contains('ْ')) {
        color = ruleColors['qalqalah']!;
      } else if (token.contains('ّ')) {
        color = ruleColors['ghunnah']!;
      } else if (token.contains('ٓ')) {
        color = ruleColors['madd_obligatory']!;
      } else if (token == 'ٱ') {
        color = ruleColors['ham_wasl']!;
      }

      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
      lastIdx = match.end;
    }

    if (lastIdx < text.length) {
      spans.add(TextSpan(text: text.substring(lastIdx)));
    }
    return spans;
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<SurahModel> _filteredSurahs = kAllSurahs;

  SurahModel _activeSurah = kAllSurahs[0];
  bool _isWarshEdition = true;
  bool _enableTajweedColors = true;
  bool _isPageViewMode = false;

  BookmarkModel? _savedBookmark = BookmarkModel(
    surahNumber: 18,
    surahName: "الكهف",
    ayahNumber: 1,
    timestamp: DateTime.now(),
  );

  late final AudioPlayer _audioPlayer;
  ReciterModel _selectedReciter = kWarshReciters[0];
  SurahModel? _playingSurah;
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isAudioLoading = false;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _completeSub;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _searchController.addListener(_onSearchChanged);
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();

    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          if (state == PlayerState.playing) {
            _isAudioLoading = false;
          }
        });
      }
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _currentPosition = pos);
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _totalDuration = dur);
    });

    _completeSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _completeSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = kAllSurahs;
      } else {
        _filteredSurahs = kAllSurahs.where((surah) {
          return surah.name.contains(query) || surah.number.toString() == query;
        }).toList();
      }
    });
  }

  Future<void> _playSurahAudio(SurahModel surah) async {
    setState(() {
      _playingSurah = surah;
      _isAudioLoading = true;
    });

    final String formattedNumber = surah.number.toString().padLeft(3, '0');
    final String audioUrl = '${_selectedReciter.serverUrl}$formattedNumber.mp3';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      if (mounted) {
        setState(() => _isAudioLoading = false);
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_playingSurah == null) {
      await _playSurahAudio(_activeSurah);
      return;
    }
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _openSurahReader(SurahModel surah, {int initialAyah = 1}) {
    setState(() {
      _activeSurah = surah;
      _selectedTabIndex = 1;
    });
  }

  void _saveBookmark(SurahModel surah, int ayahNumber) {
    setState(() {
      _savedBookmark = BookmarkModel(
        surahNumber: surah.number,
        surahName: surah.name,
        ayahNumber: ayahNumber,
        timestamp: DateTime.now(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ العلامة: سورة ${surah.name} - الآية $ayahNumber'),
        backgroundColor: const Color(0xFF0A4D3C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            Text(
              _selectedTabIndex == 0
                  ? 'المصحف الشريف (ورش)'
                  : _selectedTabIndex == 1
                      ? 'سورة ${_activeSurah.name}'
                      : 'السبحة الإلكترونية',
            ),
          ],
        ),
      ),
      drawer: _buildIslamicDrawer(),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildSurahIndexTab(),
                SurahReaderView(
                  surah: _activeSurah,
                  isWarshEdition: _isWarshEdition,
                  enableTajweedColors: _enableTajweedColors,
                  isPageViewMode: _isPageViewMode,
                  bookmarkedAyah: _savedBookmark?.surahNumber == _activeSurah.number
                      ? _savedBookmark?.ayahNumber
                      : null,
                  onBookmarkAyah: (ayahNum) => _saveBookmark(_activeSurah, ayahNum),
                  onPlaySurah: () => _playSurahAudio(_activeSurah),
                  onToggleEdition: (val) => setState(() => _isWarshEdition = val),
                  onToggleTajweed: (val) => setState(() => _enableTajweedColors = val),
                  onToggleViewMode: (val) => setState(() => _isPageViewMode = val),
                  onChangeSurah: (newSurah) => setState(() => _activeSurah = newSurah),
                ),
                const TasbihScreenView(),
              ],
            ),
          ),
          _buildPersistentAudioPlayer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (idx) => setState(() => _selectedTabIndex = idx),
        backgroundColor: const Color(0xFFF6F1E3),
        indicatorColor: const Color(0xFF0A4D3C).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.format_list_numbered_rtl),
            label: 'فهرس السور',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories),
            label: 'تصفح المصحف',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_checked),
            label: 'السبحة الرقمية',
          ),
        ],
      ),
    );
  }

  Widget _buildSurahIndexTab() {
    return Column(
      children: [
        if (_savedBookmark != null)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A4D3C), Color(0xFF126E56)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: Color(0xFFD4AF37), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'آخر قراءة: سورة ${_savedBookmark!.surahName} (الآية ${_savedBookmark!.ayahNumber})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0A4D3C),
                  ),
                  onPressed: () {
                    final surah = kAllSurahs.firstWhere((s) => s.number == _savedBookmark!.surahNumber);
                    _openSurahReader(surah, initialAyah: _savedBookmark!.ayahNumber);
                  },
                  child: const Text('متابعة'),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث باسم السورة أو رقمها...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0A4D3C)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredSurahs.length,
            itemBuilder: (context, index) {
              final surah = _filteredSurahs[index];
              final isPlayingThis = _playingSurah?.number == surah.number && _playerState == PlayerState.playing;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0A4D3C),
                    foregroundColor: Colors.white,
                    child: Text('${surah.number}'),
                  ),
                  title: Text('سورة ${surah.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${surah.revelationType} • ${surah.versesCount} آية'),
                  trailing: IconButton(
                    icon: Icon(
                      isPlayingThis ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: const Color(0xFFD4AF37),
                      size: 32,
                    ),
                    onPressed: () => isPlayingThis ? _togglePlayPause() : _playSurahAudio(surah),
                  ),
                  onTap: () => _openSurahReader(surah),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersistentAudioPlayer() {
    final surahToDisplay = _playingSurah ?? _activeSurah;
    final maxSec = _totalDuration.inSeconds > 0 ? _totalDuration.inSeconds.toDouble() : 1.0;
    final currentSec = _currentPosition.inSeconds.toDouble().clamp(0.0, maxSec);

    return Container(
      color: const Color(0xFF0A4D3C),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          if (_isAudioLoading)
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2))
          else
            IconButton(
              icon: Icon(
                _playerState == PlayerState.playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: const Color(0xFFD4AF37),
                size: 36,
              ),
              onPressed: _togglePlayPause,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تلاوة سورة ${surahToDisplay.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${_selectedReciter.name} (ورش)', style: const TextStyle(color: Color(0xFFE6DEC8), fontSize: 11)),
              ],
            ),
          ),
          PopupMenuButton<ReciterModel>(
            icon: const Icon(Icons.record_voice_over, color: Color(0xFFD4AF37)),
            onSelected: (reciter) {
              setState(() => _selectedReciter = reciter);
              if (_playingSurah != null) _playSurahAudio(_playingSurah!);
            },
            itemBuilder: (context) => kWarshReciters.map((r) => PopupMenuItem(value: r, child: Text(r.name))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0A4D3C)),
            child: Center(
              child: Text(
                'مصحف ورش والتجويد الملون',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_list_numbered_rtl),
            title: const Text('فهرس السور'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedTabIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories),
            title: const Text('تصفح المصحف'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedTabIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.radio_button_checked),
            title: const Text('السبحة الرقمية'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedTabIndex = 2);
            },
          ),
          SwitchListTile(
            title: const Text('ألوان التجويد'),
            value: _enableTajweedColors,
            onChanged: (val) {
              setState(() => _enableTajweedColors = val);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class SurahReaderView extends StatefulWidget {
  final SurahModel surah;
  final bool isWarshEdition;
  final bool enableTajweedColors;
  final bool isPageViewMode;
  final int? bookmarkedAyah;
  final ValueChanged<int> onBookmarkAyah;
  final VoidCallback onPlaySurah;
  final ValueChanged<bool> onToggleEdition;
  final ValueChanged<bool> onToggleTajweed;
  final ValueChanged<bool> onToggleViewMode;
  final ValueChanged<SurahModel> onChangeSurah;

  const SurahReaderView({
    super.key,
    required this.surah,
    required this.isWarshEdition,
    required this.enableTajweedColors,
    required this.isPageViewMode,
    required this.bookmarkedAyah,
    required this.onBookmarkAyah,
    required this.onPlaySurah,
    required this.onToggleEdition,
    required this.onToggleTajweed,
    required this.onToggleViewMode,
    required this.onChangeSurah,
  });

  @override
  State<SurahReaderView> createState() => _SurahReaderViewState();
}

class _SurahReaderViewState extends State<SurahReaderView> {
  bool _isLoading = true;
  String? _errorMessage;
  List<AyahModel> _ayahs = [];
  double _fontSize = 22.0;

  @override
  void initState() {
    super.initState();
    _fetchSurahData();
  }

  @override
  void didUpdateWidget(covariant SurahReaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surah.number != widget.surah.number || oldWidget.isWarshEdition != widget.isWarshEdition) {
      _fetchSurahData();
    }
  }

  Future<void> _fetchSurahData() async {
    final String edition = widget.isWarshEdition ? 'quran-warsh' : 'quran-tajweed';
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Uri url = Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surah.number}/$edition');
      final response = await http.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> rawAyahs = decoded['data']['ayahs'];

        setState(() {
          _ayahs = rawAyahs.map((item) => AyahModel(
            numberInSurah: item['numberInSurah'] ?? 1,
            text: item['text'] ?? '',
            page: item['page'] ?? 1,
            juz: item['juz'] ?? 1,
          )).toList();
          _isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعذر تحميل الآيات. يرجى التحقق من اتصال الإنترنت.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: const Color(0xFFF6F1E3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChoiceChip(
                label: const Text('ورش'),
                selected: widget.isWarshEdition,
                onSelected: (_) => widget.onToggleEdition(true),
              ),
              ChoiceChip(
                label: const Text('التجويد الملون'),
                selected: !widget.isWarshEdition,
                onSelected: (_) => widget.onToggleEdition(false),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () { if (_fontSize > 16) setState(() => _fontSize -= 2); },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () { if (_fontSize < 36) setState(() => _fontSize += 2); },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A4D3C)))
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _ayahs.length,
                      itemBuilder: (context, index) {
                        final ayah = _ayahs[index];
                        final isBookmarked = widget.bookmarkedAyah == ayah.numberInSurah;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: isBookmarked ? const Color(0xFFFFF9E6) : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('الآية ${ayah.numberInSurah} (صفحة ${ayah.page})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    IconButton(
                                      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFFD4AF37)),
                                      onPressed: () => widget.onBookmarkAyah(ayah.numberInSurah),
                                    ),
                                  ],
                                ),
                                RichText(
                                  textAlign: TextAlign.right,
                                  text: TextSpan(
                                    style: TextStyle(fontSize: _fontSize, height: 1.9, color: Colors.black87),
                                    children: [
                                      ...TajweedParser.parseTajweedText(ayah.text, widget.enableTajweedColors),
                                      TextSpan(
                                        text: ' ﴿${ayah.numberInSurah}﴾',
                                        style: TextStyle(color: const Color(0xFF0A4D3C), fontSize: _fontSize * 0.8),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class TasbihScreenView extends StatefulWidget {
  const TasbihScreenView({super.key});

  @override
  State<TasbihScreenView> createState() => _TasbihScreenViewState();
}

class _TasbihScreenViewState extends State<TasbihScreenView> {
  int _counter = 0;
  int _totalCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A4D3C))),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () {
              setState(() {
                _counter++;
                _totalCounter++;
              });
            },
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0A4D3C),
              ),
              alignment: Alignment.center,
              child: Text('$_counter', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Text('المجموع الكلي: $_totalCounter', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() => _counter = 0),
            child: const Text('إعادة ضبط العداد'),
          ),
        ],
      ),
    );
  }
}
