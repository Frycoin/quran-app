import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranWarshTajweedApp());
}

// ==========================================
// 1. التطبيق الرئيسي وإعدادات الثيم
// ==========================================
class QuranWarshTajweedApp extends StatelessWidget {
  const QuranWarshTajweedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مصحف ورش والتجويد الملون',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), // بيج فاتح مريح للعين
        primaryColor: const Color(0xFF0A4D3C), // زمردي داكن
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A4D3C),
          primary: const Color(0xFF0A4D3C),
          secondary: const Color(0xFFD4AF37), // ذهبي إسلامي
          surface: const Color(0xFFFDFBF7),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A4D3C),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFDFBF7),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE6DEC8), width: 1),
          ),
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

// ==========================================
// 2. نماذج البيانات والبيانات الثابتة (114 سورة)
// ==========================================
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

// ==========================================
// 3. محلل علامات التجويد الملون (Tajweed Parser)
// ==========================================
class TajweedParser {
  // ألوان أحكام التجويد المعتمدة في مصحف التجويد الملون
  static const Map<String, Color> ruleColors = {
    'ghunnah': Color(0xFF169777), // أخضر: غنة / إخفاء / إدغام بغنة
    'ikhafa': Color(0xFF169777),
    'ikhafa_shafawi': Color(0xFF169777),
    'idgham_ghunnah': Color(0xFF169777),
    'idgham_shafawi': Color(0xFF169777),
    'iqlab': Color(0xFF26BFFD), // أزرق سماوي: إقلاب
    'qalqalah': Color(0xFF0055FF), // أزرق داكن: قلقلة (قطب جد)
    'madd_normal': Color(0xFFD48B00), // برتقالي/ذهبي: مد طبيعي
    'madd_permissible': Color(0xFFFF6600), // برتقالي داكن: مد جائز منفصل
    'madd_obligatory': Color(0xFFD50000), // أحمر: مد واجب متصل
    'madd_necessary': Color(0xFF9E0000), // أحمر قاني: مد لازم
    'ham_wasl': Color(0xFF9E9E9E), // رمادي: همزة وصل / حروف لا تنطق
    'slnt': Color(0xFF9E9E9E),
    'laam_shamsiyah': Color(0xFF9E9E9E),
    'idgham_wo_ghunnah': Color(0xFF795548), // بني: إدغام بغير غنة
  };

  /// تحويل النص المحتوي على وسوم التجويد (مثل [n[نص]) أو النص العادي إلى TextSpan ملون
  static List<TextSpan> parseTajweedText(String rawText, bool enableTajweed) {
    if (!enableTajweed) {
      final cleanText = rawText.replaceAllMapped(
        RegExp(r'\[[a-zA-Z_]+(?::\d+)?\[([^\]]+)\]'),
        (match) => match.group(1) ?? '',
      );
      return [TextSpan(text: cleanText)];
    }

    // في حال كان النص يحتوي على ترميز مصحف التجويد الرسمي من API
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

    // في حال كان النص برواية ورش الصافية بدون وسوم مسبقة، نطبق تلوين التجويد الذكي للحروف
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
        return ruleColors['madd_obligatory']!;
      case 'm':
        return ruleColors['madd_necessary']!;
      case 'h':
      case 's':
      case 'l':
        return ruleColors['ham_wasl']!;
      case 'u':
        return ruleColors['idgham_wo_ghunnah']!;
      default:
        return const Color(0xFF1F1F1F);
    }
  }

  /// تلوين ذكي لأحكام القلقلة والغنة والمدود للنص القرآني المباشر (رواية ورش)
  static List<TextSpan> _applyHeuristicTajweed(String text) {
    final List<TextSpan> spans = [];
    // تلوين حروف القلقلة الساكنة، النون والميم المشددتين، وعلامات المد
    final RegExp ruleRegex = RegExp(
      r'([قطبجد]ْ|[نم]ّ|[اوي]?ٓ|[ٱ])',
    );

    int lastIdx = 0;
    for (final match in ruleRegex.allMatches(text)) {
      if (match.start > lastIdx) {
        spans.add(TextSpan(text: text.substring(lastIdx, match.start)));
      }
      final String token = match.group(0)!;
      Color color = const Color(0xFF1F1F1F);

      if (token.contains('ْ')) {
        color = ruleColors['qalqalah']!; // قلقلة
      } else if (token.contains('ّ')) {
        color = ruleColors['ghunnah']!; // غنة المشدد
      } else if (token.contains('ٓ')) {
        color = ruleColors['madd_obligatory']!; // مد مشبع في ورش
      } else if (token == 'ٱ') {
        color = ruleColors['ham_wasl']!; // همزة وصل
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

// ==========================================
// 4. الشاشة الرئيسية وإدارة الحالة الشاملة
// ==========================================
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<SurahModel> _filteredSurahs = kAllSurahs;

  // حالة القارئ والمصحف
  SurahModel _activeSurah = kAllSurahs[0];
  bool _isWarshEdition = true; // true = رواية ورش، false = مصحف التجويد الملون المرمز
  bool _enableTajweedColors = true;
  bool _isPageViewMode = false; // التبديل بين نظام الآيات ونظام الصفحات

  // العلامة المرجعية
  BookmarkModel? _savedBookmark = BookmarkModel(
    surahNumber: 18,
    surahName: "الكهف",
    ayahNumber: 1,
    timestamp: DateTime.now(),
  );

  // حالة المشغل الصوتي المدمج
  late final AudioPlayer _audioPlayer;
  ReciterModel _selectedReciter = kWarshReciters[0];
  SurahModel? _playingSurah;
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isAudioLoading = false;
  String? _audioError;

  // اشتراكات التدفقات (Streams) لإغلاقها بأمان
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
      if (mounted) {
        setState(() => _currentPosition = pos);
      }
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() => _totalDuration = dur);
      }
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
    // إغلاق كافة المتحكمات والاشتراكات لمنع تسريب الذاكرة (Memory Leaks)
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
          final matchesName = surah.name.contains(query);
          final matchesNumber = surah.number.toString() == query;
          return matchesName || matchesNumber;
        }).toList();
      }
    });
  }

  Future<void> _playSurahAudio(SurahModel surah) async {
    setState(() {
      _playingSurah = surah;
      _isAudioLoading = true;
      _audioError = null;
    });

    final String formattedNumber = surah.number.toString().padLeft(3, '0');
    final String audioUrl = '${_selectedReciter.serverUrl}$formattedNumber.mp3';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
          _audioError = 'تعذر تشغيل الصوت. يرجى التحقق من اتصال الإنترنت.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_audioError!),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_playingSurah == null) {
      await _playSurahAudio(_activeSurah);
      return;
    }

    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (_) {
      await _playSurahAudio(_playingSurah!);
    }
  }

  void _openSurahReader(SurahModel surah, {int initialAyah = 1}) {
    setState(() {
      _activeSurah = surah;
      _selectedTabIndex = 1; // الانتقال إلى تبويب المصحف
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
        content: Text('تم حفظ العلامة المرجعية: سورة ${surah.name} - الآية $ayahNumber'),
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
            const SizedBox(width: 10),
            Text(
              _selectedTabIndex == 0
                  ? 'المصحف الشريف (رواية ورش)'
                  : _selectedTabIndex == 1
                      ? 'سورة ${_activeSurah.name}'
                      : 'السبحة الإلكترونية والأذكار',
            ),
          ],
        ),
        actions: [
          if (_savedBookmark != null)
            IconButton(
              tooltip: 'الانتقال للعلامة المرجعية (سورة ${_savedBookmark!.surahName})',
              icon: const Icon(Icons.bookmark_rounded, color: Color(0xFFD4AF37)),
              onPressed: () {
                final bookmarkedSurah = kAllSurahs.firstWhere(
                  (s) => s.number == _savedBookmark!.surahNumber,
                  orElse: () => kAllSurahs[0],
                );
                _openSurahReader(bookmarkedSurah, initialAyah: _savedBookmark!.ayahNumber);
              },
            ),
          IconButton(
            tooltip: 'مفتاح ألوان التجويد',
            icon: const Icon(Icons.palette_outlined),
            onPressed: _showTajweedLegendDialog,
          ),
        ],
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
          // المشغل الصوتي المدمج في أسفل الشاشة
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
            selectedIcon: Icon(Icons.format_list_numbered_rtl, color: Color(0xFF0A4D3C)),
            label: 'فهرس السور',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories, color: Color(0xFF0A4D3C)),
            label: 'تصفح المصحف',
          ),
          NavigationDestination(
            icon: Icon(Icons.Radio_button_checked),
            selectedIcon: Icon(Icons.Radio_button_checked, color: Color(0xFF0A4D3C)),
            label: 'السبحة الرقمية',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. بناء فهرس السور وشريط البحث الفوري
  // ==========================================
  Widget _buildSurahIndexTab() {
    return Column(
      children: [
        // لافتة العلامة المرجعية السريعة
        if (_savedBookmark != null)
          Container(
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A4D3C), Color(0xFF126E56)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: Color(0xFFD4AF37), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'آخر موضع قراءة محفوظ',
                        style: TextStyle(color: Color(0xFFE6DEC8), fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'سورة ${_savedBookmark!.surahName} - الآية ${_savedBookmark!.ayahNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0A4D3C),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                  label: const Text('متابعة', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final surah = kAllSurahs.firstWhere(
                      (s) => s.number == _savedBookmark!.surahNumber,
                      orElse: () => kAllSurahs[0],
                    );
                    _openSurahReader(surah, initialAyah: _savedBookmark!.ayahNumber);
                  },
                ),
              ],
            ),
          ),

        // حقل البحث الفوري باسم السورة أو رقمها
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث باسم السورة أو رقمها (مثال: الكهف أو 18)...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0A4D3C)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD4AF37)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE6DEC8), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF0A4D3C), width: 2),
              ),
            ),
          ),
        ),

        // قائمة السور (114 سورة)
        Expanded(
          child: _filteredSurahs.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد سورة مطابقة لبحثك',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    final isPlayingThis = _playingSurah?.number == surah.number &&
                        _playerState == PlayerState.playing;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A4D3C).withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          ),
                          child: Text(
                            '${surah.number}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A4D3C),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          'سورة ${surah.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A4D3C),
                          ),
                        ),
                        subtitle: Text(
                          '${surah.revelationType} • آياتها: ${surah.versesCount}',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'تشغيل التلاوة برواية ورش',
                              icon: Icon(
                                isPlayingThis
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: const Color(0xFFD4AF37),
                                size: 32,
                              ),
                              onPressed: () {
                                if (isPlayingThis) {
                                  _togglePlayPause();
                                } else {
                                  _playSurahAudio(surah);
                                }
                              },
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF0A4D3C)),
                          ],
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

  // ==========================================
  // 6. المشغل الصوتي المدمج (رواية ورش)
  // ==========================================
  Widget _buildPersistentAudioPlayer() {
    final surahToDisplay = _playingSurah ?? _activeSurah;
    final maxSeconds = _totalDuration.inSeconds > 0 ? _totalDuration.inSeconds.toDouble() : 1.0;
    final currentSeconds = _currentPosition.inSeconds.toDouble().clamp(0.0, maxSeconds);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A4D3C),
        border: const Border(top: BorderSide(color: Color(0xFFD4AF37), width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // زر التشغيل / الإيقاف المؤقت
              if (_isAudioLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    _playerState == PlayerState.playing
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: const Color(0xFFD4AF37),
                    size: 38,
                  ),
                  onPressed: _togglePlayPause,
                ),
              const SizedBox(width: 8),
              // معلومات السورة والقارئ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تلاوة سورة ${surahToDisplay.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_selectedReciter.name} (رواية ورش)',
                      style: const TextStyle(
                        color: Color(0xFFE6DEC8),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // اختيار القارئ
              PopupMenuButton<ReciterModel>(
                tooltip: 'تغيير القارئ (رواية ورش)',
                icon: const Icon(Icons.record_voice_over_rounded, color: Color(0xFFD4AF37)),
                onSelected: (reciter) {
                  setState(() => _selectedReciter = reciter);
                  if (_playingSurah != null) {
                    _playSurahAudio(_playingSurah!);
                  }
                },
                itemBuilder: (context) => kWarshReciters
                    .map(
                      (r) => PopupMenuItem<ReciterModel>(
                        value: r,
                        child: Row(
                          children: [
                            Icon(
                              _selectedReciter.name == r.name
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: const Color(0xFF0A4D3C),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          // شريط التقدم الزمني
          if (_playingSurah != null && _totalDuration.inSeconds > 0)
            Row(
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: const Color(0xFFD4AF37),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFFD4AF37),
                    ),
                    child: Slider(
                      value: currentSeconds,
                      max: maxSeconds,
                      onChanged: (val) {
                        _audioPlayer.seek(Duration(seconds: val.toInt()));
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  // ==========================================
  // 7. القائمة الجانبية ودليل التجويد
  // ==========================================
  Widget _buildIslamicDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFFDFBF7),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A4D3C), Color(0xFF063327)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFFD4AF37), size: 32),
                ),
                const SizedBox(height: 10),
                const Text(
                  'مصحف ورش والتجويد الملون',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'برواية ورش عن نافع من طريق الأزرق',
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_list_numbered_rtl, color: Color(0xFF0A4D3C)),
            title: const Text('فهرس السور الكامل'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedTabIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories, color: Color(0xFF0A4D3C)),
            title: const Text('تصفح المصحف الشريف'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedTabIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.Radio_button_checked, color: Color(0xFF0A4D3C)),
            title: const Text('السبحة الإلكترونية'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedTabIndex = 2);
            },
          ),
          const Divider(),
          SwitchListTile(
            activeColor: const Color(0xFF0A4D3C),
            title: const Text('تلوين أحكام التجويد'),
            subtitle: const Text('إظهار الألوان الإرشادية للأحكام'),
            value: _enableTajweedColors,
            onChanged: (val) {
              setState(() => _enableTajweedColors = val);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Color(0xFFD4AF37)),
            title: const Text('دليل ألوان أحكام التجويد'),
            onTap: () {
              Navigator.pop(context);
              _showTajweedLegendDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showTajweedLegendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        title: const Row(
          children: [
            Icon(Icons.palette, color: Color(0xFF0A4D3C)),
            SizedBox(width: 8),
            Text(
              'مفتاح ألوان التجويد',
              style: TextStyle(color: Color(0xFF0A4D3C), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendItem(const Color(0xFFD50000), 'المد اللازم والواجب والمشبع (ورش)'),
            _legendItem(const Color(0xFFD48B00), 'المد الطبيعي والمد الجائز'),
            _legendItem(const Color(0xFF169777), 'الغنة، الإخفاء، والإدغام بغنة'),
            _legendItem(const Color(0xFF0055FF), 'القلقلة (قطب جد)'),
            _legendItem(const Color(0xFF26BFFD), 'الإقلاب'),
            _legendItem(const Color(0xFF9E9E9E), 'حروف لا تنطق (همزة الوصل واللام الشمسية)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Color(0xFF0A4D3C))),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. شاشة قارئ المصحف الشريف (ورش / التجويد الملون)
// ==========================================
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
  double _fontSize = 24.0;

  // تخزين مؤقت في الذاكرة لتسريع التصفح وعدم إعادة التحميل عند التبديل
  final Map<String, List<AyahModel>> _memoryCache = {};

  @override
  void initState() {
    super.initState();
    _fetchSurahData();
  }

  @override
  void didUpdateWidget(covariant SurahReaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surah.number != widget.surah.number ||
        oldWidget.isWarshEdition != widget.isWarshEdition) {
      _fetchSurahData();
    }
  }

  Future<void> _fetchSurahData() async {
    final String edition = widget.isWarshEdition ? 'quran-warsh' : 'quran-tajweed';
    final String cacheKey = '${widget.surah.number}_$edition';

    if (_memoryCache.containsKey(cacheKey)) {
      setState(() {
        _ayahs = _memoryCache[cacheKey]!;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Uri url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/${widget.surah.number}/$edition',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> rawAyahs = decoded['data']['ayahs'];

        final List<AyahModel> parsedAyahs = rawAyahs.map((item) {
          return AyahModel(
            numberInSurah: item['numberInSurah'] ?? 1,
            text: item['text'] ?? '',
            page: item['page'] ?? 1,
            juz: item['juz'] ?? 1,
          );
        }).toList();

        _memoryCache[cacheKey] = parsedAyahs;

        if (mounted) {
          setState(() {
            _ayahs = parsedAyahs;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Server status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'تعذر تحميل آيات السورة بسبب ضعف الاتصال بالإنترنت.\nيرجى التحقق من الشبكة والمحاولة مجدداً.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط أدوات القراءة والتحكم بالرواية والخط
        _buildReaderToolbar(),

        // محتوى الآيات أو الصفحات
        Expanded(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0A4D3C)),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل آيات المصحف الشريف...',
                        style: TextStyle(
                          color: Color(0xFF0A4D3C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : widget.isPageViewMode
                      ? _buildMushafPageView()
                      : _buildAyahListView(),
        ),
      ],
    );
  }

  Widget _buildReaderToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E3),
        border: Border(bottom: BorderSide(color: Color(0xFFE6DEC8))),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // التبديل بين رواية ورش ومصحف التجويد
          ChoiceChip(
            label: const Text('رواية ورش'),
            selected: widget.isWarshEdition,
            selectedColor: const Color(0xFF0A4D3C),
            labelStyle: TextStyle(
              color: widget.isWarshEdition ? Colors.white : const Color(0xFF0A4D3C),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            onSelected: (_) => widget.onToggleEdition(true),
          ),
          ChoiceChip(
            label: const Text('مصحف التجويد الملون'),
            selected: !widget.isWarshEdition,
            selectedColor: const Color(0xFF0A4D3C),
            labelStyle: TextStyle(
              color: !widget.isWarshEdition ? Colors.white : const Color(0xFF0A4D3C),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            onSelected: (_) => widget.onToggleEdition(false),
          ),
          // أزرار تكبير وتصغير الخط وطريقة العرض
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: widget.isPageViewMode ? 'عرض كقائمة آيات' : 'عرض كصفحة مصحف متصلة',
                icon: Icon(
                  widget.isPageViewMode ? Icons.view_agenda_outlined : Icons.menu_book_outlined,
                  color: const Color(0xFF0A4D3C),
                ),
                onPressed: () => widget.onToggleViewMode(!widget.isPageViewMode),
              ),
              IconButton(
                tooltip: 'تصغير الخط',
                icon: const Icon(Icons.text_decrease, color: Color(0xFF0A4D3C)),
                onPressed: () {
                  if (_fontSize > 18) setState(() => _fontSize -= 2);
                },
              ),
              IconButton(
                tooltip: 'تكبير الخط',
                icon: const Icon(Icons.text_increase, color: Color(0xFF0A4D3C)),
                onPressed: () {
                  if (_fontSize < 38) setState(() => _fontSize += 2);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 60, color: Color(0xFFD4AF37)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A4D3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              onPressed: _fetchSurahData,
            ),
          ],
        ),
      ),
    );
  }

  // عرض المصحف بنظام الصفحات المتصلة (كالمصحف الورقي)
  Widget _buildMushafPageView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSurahHeaderBanner(),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 2.1,
                  color: const Color(0xFF1F1F1F),
                  fontFamily: 'serif',
                ),
                children: _ayahs.expand((ayah) {
                  final spans = TajweedParser.parseTajweedText(
                    ayah.text,
                    widget.enableTajweedColors,
                  );
                  return [
                    ...spans,
                    TextSpan(
                      text: ' ﴿${ayah.numberInSurah}﴾ ',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: _fontSize * 0.8,
                      ),
                    ),
                  ];
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSurahNavigationFooter(),
          ],
        ),
      ),
    );
  }

  // عرض المصحف بنظام الآيات المفصلة مع خيارات الحفظ المرجعي لكل آية
  Widget _buildAyahListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _ayahs.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSurahHeaderBanner();
        }
        if (index == _ayahs.length + 1) {
          return _buildSurahNavigationFooter();
        }

        final ayah = _ayahs[index - 1];
        final isBookmarked = widget.bookmarkedAyah == ayah.numberInSurah;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isBookmarked ? const Color(0xFFFFF9E6) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A4D3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'الآية ${ayah.numberInSurah} • صفحة ${ayah.page} • جزء ${ayah.juz}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0A4D3C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'حفظ علامة مرجعية عند هذه الآية',
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: const Color(0xFFD4AF37),
                      ),
                      onPressed: () => widget.onBookmarkAyah(ayah.numberInSurah),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.95,
                      color: const Color(0xFF1F1F1F),
                    ),
                    children: [
                      ...TajweedParser.parseTajweedText(ayah.text, widget.enableTajweedColors),
                      TextSpan(
                        text: ' ﴿${ayah.numberInSurah}﴾',
                        style: TextStyle(
                          color: const Color(0xFF0A4D3C),
                          fontWeight: FontWeight.bold,
                          fontSize: _fontSize * 0.85,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahHeaderBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A4D3C), Color(0xFF126E56)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.surah.revelationType} • ${widget.surah.versesCount} آية',
                style: const TextStyle(color: Color(0xFFE6DEC8), fontSize: 13),
              ),
              Text(
                'سورة ${widget.surah.name}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0A4D3C),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.volume_up_rounded, size: 18),
                label: const Text('استماع', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: widget.onPlaySurah,
              ),
            ],
          ),
          if (widget.surah.number != 1 && widget.surah.number != 9) ...[
            const Divider(color: Colors.white24, height: 24),
            const Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSurahNavigationFooter() {
    final hasPrev = widget.surah.number > 1;
    final hasNext = widget.surah.number < 114;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasPrev)
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              label: Text('سورة ${kAllSurahs[widget.surah.number - 2].name}'),
              onPressed: () => widget.onChangeSurah(kAllSurahs[widget.surah.number - 2]),
            )
          else
            const SizedBox.shrink(),
          if (hasNext)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A4D3C),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              label: Text('سورة ${kAllSurahs[widget.surah.number].name}'),
              onPressed: () => widget.onChangeSurah(kAllSurahs[widget.surah.number]),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

// ==========================================
// 9. السبحة الإلكترونية الرقمية
// ==========================================
class TasbihScreenView extends StatefulWidget {
  const TasbihScreenView({super.key});

  @override
  State<TasbihScreenView> createState() => _TasbihScreenViewState();
}

class _TasbihScreenViewState extends State<TasbihScreenView> {
  int _counter = 0;
  int _totalCounter = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;

  final List<String> _adhkarList = const [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
  ];

  void _incrementCounter() {
    setState(() {
      _counter++;
      _totalCounter++;
      if (_counter > _target) {
        _counter = 1;
        _selectedDhikrIndex = (_selectedDhikrIndex + 1) % _adhkarList.length;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // اختيار الذكر
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A4D3C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'الذكر الحالي',
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _adhkarList[_selectedDhikrIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [33, 100, 1000].map((targetVal) {
                    final isSelected = _target == targetVal;
                    return ChoiceChip(
                      label: Text('الهدف: $targetVal'),
                      selected: isSelected,
                      selectedColor: const Color(0xFFD4AF37),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF0A4D3C) : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() {
                        _target = targetVal;
                        _counter = 0;
                      }),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // زر السبحة الدائري الكبير
          GestureDetector(
            onTap: _incrementCounter,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF126E56), Color(0xFF0A4D3C)],
                ),
                border: Border.all(color: const Color(0xFFD4AF37), width: 5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A4D3C).withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_counter',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'من $_target',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اضغط للتسبيح',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // إحصائيات التسابيح وزر التصفير
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      const Text('مجموع التسابيح', style: TextStyle(color: Colors.grey)),
                      Text(
                        '$_totalCounter',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A4D3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0A4D3C),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تصفير العداد', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _resetCounter,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // قائمة الأذكار السريعة للتبديل
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _adhkarList.length,
              itemBuilder: (context, idx) {
                final isSelected = idx == _selectedDhikrIndex;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ActionChip(
                    backgroundColor: isSelected ? const Color(0xFF0A4D3C) : Colors.white,
                    label: Text(
                      _adhkarList[idx],
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF0A4D3C),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDhikrIndex = idx;
                        _counter = 0;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
