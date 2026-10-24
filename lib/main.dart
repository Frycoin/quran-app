import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AstralSeveranceApp());
}

enum GameLang { ar, en }
enum AppScreen { menu, game }
enum EraState { present, past }

class AstralSeveranceApp extends StatefulWidget {
  const AstralSeveranceApp({super.key});

  @override
  State<AstralSeveranceApp> createState() => _AstralSeveranceAppState();
}

class _AstralSeveranceAppState extends State<AstralSeveranceApp> {
  GameLang _lang = GameLang.ar;
  AppScreen _screen = AppScreen.menu;

  void _toggleLang() {
    setState(() {
      _lang = _lang == GameLang.ar ? GameLang.en : GameLang.ar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astral Severance: Crown of Cinders',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF03050A),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: _lang == GameLang.ar ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _screen == AppScreen.menu
          ? MainMenuScreen(
              lang: _lang,
              onToggleLang: _toggleLang,
              onStartGame: () => setState(() => _screen = AppScreen.game),
            )
          : GameScreen(
              lang: _lang,
              onToggleLang: _toggleLang,
              onBackToMenu: () => setState(() => _screen = AppScreen.menu),
            ),
    );
  }
}

// ====================================================================
// الشاشة الرئيسية السينمائية (Main Menu)
// ====================================================================
class MainMenuScreen extends StatelessWidget {
  final GameLang lang;
  final VoidCallback onToggleLang;
  final VoidCallback onStartGame;

  const MainMenuScreen({
    super.key,
    required this.lang,
    required this.onToggleLang,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: MenuBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4AF37)),
                        ),
                        child: const Text(
                          'WAH STUDIO',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A192F),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        onPressed: onToggleLang,
                        icon: const Icon(Icons.language, size: 18),
                        label: Text(lang == GameLang.ar ? 'English' : 'العربية'),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        lang == GameLang.ar ? 'الانفصال النجمي' : 'ASTRAL SEVERANCE',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang == GameLang.ar ? 'تاج الرماد' : 'CROWN OF CINDERS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFD4AF37),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 240,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: const Color(0xFF03050A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: onStartGame,
                          child: Text(
                            lang == GameLang.ar ? 'بدء الملحمة' : 'START ODYSSEY',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'v1.0.0 • Powered by Flutter & WAH Engine',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
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

class MenuBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF020408), Color(0xFF0C1425), Color(0xFF050811)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final Random rng = Random(42);
    final Paint starPaint = Paint()..color = Colors.white70;
    for (int i = 0; i < 50; i++) {
      final double x = rng.nextDouble() * size.width;
      final double y = rng.nextDouble() * size.height * 0.7;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.5 + 0.5, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ====================================================================
// شاشة اللعب الكبرى (Game Screen)
// ====================================================================
class GameScreen extends StatefulWidget {
  final GameLang lang;
  final VoidCallback onToggleLang;
  final VoidCallback onBackToMenu;

  const GameScreen({
    super.key,
    required this.lang,
    required this.onToggleLang,
    required this.onBackToMenu,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _gameTimer;
  final Random _rng = Random();

  static const double worldWidth = 2400.0;
  static const double groundY = 560.0;

  // بطل اللعبة: زايدن (Zayden)
  Offset _playerPos = const Offset(200, 450);
  Offset _playerVel = Offset.zero;
  final Size _playerSize = const Size(34, 48);
  int _facing = 1;
  bool _onGround = false;
  int _jumpsRemaining = 2;
  int _masks = 5;
  double _energy = 50.0;

  // نظام العصور (Time-Fold Era Switch)
  EraState _currentEra = EraState.present;

  // المدخلات
  bool _moveLeft = false;
  bool _moveRight = false;
  bool _jumpHeld = false;

  // الكاميرا والمؤثرات
  Offset _cameraPos = Offset.zero;
  double _screenShake = 0.0;

  @override
  void initState() {
    super.initState();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateGame(0.016);
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _toggleEra() {
    setState(() {
      _currentEra = _currentEra == EraState.present ? EraState.past : EraState.present;
      _screenShake = 12.0;
    });
  }

  void _updateGame(double dt) {
    if (_screenShake > 0) {
      _screenShake = max(0, _screenShake - dt * 30);
    }

    // الفيزياء والحركة
    double targetVx = 0;
    if (_moveLeft) {
      targetVx = -280.0;
      _facing = -1;
    } else if (_moveRight) {
      targetVx = 280.0;
      _facing = 1;
    }

    _playerVel = Offset(
      _playerVel.dx + (targetVx - _playerVel.dx) * min(1.0, 15.0 * dt),
      _playerVel.dy + 1400.0 * dt,
    );

    Offset nextPos = _playerPos + _playerVel * dt;
    _onGround = false;

    // الأرضية
    if (nextPos.dy >= groundY - _playerSize.height / 2) {
      nextPos = Offset(nextPos.dx, groundY - _playerSize.height / 2);
      _playerVel = Offset(_playerVel.dx, 0);
      _onGround = true;
      _jumpsRemaining = 2;
    }

    // حدود العالم
    nextPos = Offset(nextPos.dx.clamp(30.0, worldWidth - 30.0), nextPos.dy);
    _playerPos = nextPos;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Size screenSize = Size(constraints.maxWidth, constraints.maxHeight);

          final double targetCamX = (_playerPos.dx - screenSize.width * 0.45)
              .clamp(0.0, max(0.0, worldWidth - screenSize.width));
          
          final Offset shake = _screenShake > 0
              ? Offset((_rng.nextDouble() - 0.5) * _screenShake, (_rng.nextDouble() - 0.5) * _screenShake)
              : Offset.zero;

          _cameraPos = Offset(targetCamX, 0) + shake;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GameWorldPainter(
                    cameraPos: _cameraPos,
                    playerPos: _playerPos,
                    playerSize: _playerSize,
                    facing: _facing,
                    era: _currentEra,
                  ),
                ),
              ),
              // أعلى الشاشة: الـ HUD وتغيير اللغة وزر العصور (Time-Fold)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: widget.onBackToMenu,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.lang == GameLang.ar ? 'الصحوة النجمية' : 'Astral Awakening',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentEra == EraState.present ? Colors.grey.shade800 : const Color(0xFFD4AF37),
                            foregroundColor: _currentEra == EraState.present ? Colors.white : Colors.black,
                          ),
                          onPressed: _toggleEra,
                          child: Text(widget.lang == GameLang.ar ? 'زمن: ${_currentEra == EraState.present ? "الحاضر" : "الماضي"}' : 'Era: ${_currentEra.name}'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.language, color: Colors.white),
                          onPressed: widget.onToggleLang,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // أزرار التحكم باللمس
              Positioned(
                left: 20,
                bottom: 24,
                child: Row(
                  children: [
                    _controlButton(
                      icon: Icons.arrow_back,
                      onActive: (val) => setState(() => _moveLeft = val),
                    ),
                    const SizedBox(width: 16),
                    _controlButton(
                      icon: Icons.arrow_forward,
                      onActive: (val) => setState(() => _moveRight = val),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 24,
                child: Row(
                  children: [
                    _actionButton(
                      label: widget.lang == GameLang.ar ? 'سيف' : 'BLADE',
                      color: Colors.blueGrey,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _actionButton(
                      label: widget.lang == GameLang.ar ? 'قفز' : 'JUMP',
                      color: const Color(0xFFD4AF37),
                      onTap: () {
                        if (_jumpsRemaining > 0) {
                          _jumpsRemaining--;
                          setState(() {
                            _playerVel = Offset(_playerVel.dx, -560.0);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _controlButton({required IconData icon, required ValueChanged<bool> onActive}) {
    return Listener(
      onPointerDown: (_) => onActive(true),
      onPointerUp: (_) => onActive(false),
      onPointerCancel: (_) => onActive(false),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _actionButton({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

// ====================================================================
// الرسام البرمجي لعالم اللعبة وعصور الزمن (Game World Painter)
// ====================================================================
class GameWorldPainter extends CustomPainter {
  final Offset cameraPos;
  final Offset playerPos;
  final Size playerSize;
  final int facing;
  final EraState era;

  GameWorldPainter({
    required this.cameraPos,
    required this.playerPos,
    required this.playerSize,
    required this.facing,
    required this.era,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screenRect = Offset.zero & size;
    
    // تدرج ألوان الخلفية يتغير ديناميكياً بحسب العصر (الحاضر الرمادي أو الماضي الذهبي)
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: era == EraState.present
            ? [const Color(0xFF090D16), const Color(0xFF161F33), const Color(0xFF0A0E1A)]
            : [const Color(0xFF1B1405), const Color(0xFF38290A), const Color(0xFF1A1303)],
      ).createShader(screenRect);
    canvas.drawRect(screenRect, bgPaint);

    canvas.save();
    canvas.translate(-cameraPos.dx, -cameraPos.dy);

    // رسم الأرضية الرئيسية
    final Paint groundPaint = Paint()
      ..color = era == EraState.present ? const Color(0xFF1E293B) : const Color(0xFF533F10);
    canvas.drawRect(Rect.fromLTWH(0, GameScreen.groundY, GameScreen.worldWidth, 300), groundPaint);

    // رسم بطل اللعبة: زايدن (Zayden)
    canvas.save();
    canvas.translate(playerPos.dx, playerPos.dy);
    canvas.scale(facing.toDouble(), 1.0);

    // الوشاح القرمزي المتدفق
    final Paint scarfPaint = Paint()..color = const Color(0xFF991B1B);
    canvas.drawPath(
      Path()
        ..moveTo(-10, -5)
        ..lineTo(-25, 12)
        ..lineTo(-12, 22)
        ..close(),
      scarfPaint,
    );

    // درع البطل والبدلة النجمية
    final Paint armorPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: playerSize.width, height: playerSize.height),
        const Radius.circular(8),
      ),
      armorPaint,
    );

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GameWorldPainter oldDelegate) => true;
}
