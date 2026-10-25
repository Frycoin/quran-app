import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AstralSeveranceApp());
}

// ================================================================
// ENUMS
// ================================================================
enum GameLang { ar, en }
enum AppScreen { splash, menu, lore, game }
enum EraState { present, past }
enum AstralSkill { starBolt, chronoBomb, tetherHook, timeFold }
enum WeaponTier { rustyBlade, starlightEdge, chronosSunCleaver }
enum ElementalCore { none, solarFire, frostSlow, stormChain, voidLeech }
enum EnemyKind { ashStalker, chronoSentinel, astralWeaver, wingedDrake, automatonBoss, archonVaelenBoss }
enum PortraitKind { zayden, aethel, kaelis, nyxia, warden, vaelen, lyra }

// ================================================================
// MODEL CLASSES
// ================================================================
class Platform25D {
  final Rect rect;
  final bool isHazard;
  final bool onlyInPast;
  final bool onlyInPresent;
  final bool hasGrass;
  const Platform25D(
    this.rect, {
    this.isHazard = false,
    this.onlyInPast = false,
    this.onlyInPresent = false,
    this.hasGrass = true,
  });
  bool isActiveIn(EraState era) {
    if (onlyInPast && era != EraState.past) return false;
    if (onlyInPresent && era != EraState.present) return false;
    return true;
  }
}

class BreakableWall {
  final Rect rect;
  bool destroyed;
  BreakableWall(this.rect, {this.destroyed = false});
}

class PushBlock {
  Rect rect;
  PushBlock(this.rect);
}

class PressurePlate {
  final Rect rect;
  final int targetGateId;
  bool isPressed = false;
  PressurePlate({required this.rect, required this.targetGateId});
}

class GateDoor {
  final int id;
  final Rect closedRect;
  double openProgress = 0.0;
  bool isOpen = false;
  GateDoor({required this.id, required this.closedRect});
  Rect get currentRect => Rect.fromLTWH(
        closedRect.left,
        closedRect.top - (closedRect.height * openProgress),
        closedRect.width,
        closedRect.height,
      );
}

class GrappleRing {
  final Offset pos;
  const GrappleRing(this.pos);
}

class TreasureChest {
  final String id;
  final Offset pos;
  final int oreReward;
  final bool onlyInPast;
  bool opened = false;
  TreasureChest({
    required this.id,
    required this.pos,
    required this.oreReward,
    this.onlyInPast = false,
  });
}

class BreakableCrystal {
  final Offset pos;
  int hp = 2;
  bool broken = false;
  BreakableCrystal(this.pos);
}

class DialogueLine {
  final PortraitKind speaker;
  final String speakerAr;
  final String speakerEn;
  final String textAr;
  final String textEn;
  const DialogueLine({
    required this.speaker,
    required this.speakerAr,
    required this.speakerEn,
    required this.textAr,
    required this.textEn,
  });
}

class NpcEntity {
  final String id;
  final Offset pos;
  final String nameAr;
  final String nameEn;
  final PortraitKind portrait;
  final List<DialogueLine> lines;
  final bool opensForge;
  const NpcEntity({
    required this.id,
    required this.pos,
    required this.nameAr,
    required this.nameEn,
    required this.portrait,
    required this.lines,
    this.opensForge = false,
  });
}

class ProjectileEntity {
  Offset pos;
  Offset vel;
  double radius;
  bool fromPlayer;
  bool isDeflected;
  Color color;
  double life;
  int damage;
  ProjectileEntity({
    required this.pos,
    required this.vel,
    this.radius = 10,
    required this.fromPlayer,
    this.isDeflected = false,
    required this.color,
    this.life = 2.5,
    this.damage = 1,
  });
}

class BombEntity {
  Offset pos;
  Offset vel;
  double fuse = 1.35;
  BombEntity({required this.pos, required this.vel});
}

class LootOrb {
  Offset pos;
  Offset vel;
  int oreValue;
  bool isHealth;
  double life = 10.0;
  LootOrb({
    required this.pos,
    required this.vel,
    this.oreValue = 1,
    this.isHealth = false,
  });
}

class EnemyUnit {
  final int id;
  final EnemyKind kind;
  Offset pos;
  Size size;
  int hp;
  int maxHp;
  double minX;
  double maxX;
  int facing = -1;
  double flashTimer = 0;
  double stunTimer = 0;
  double aiTimer = 0;
  double burnTimer = 0;
  double slowTimer = 0;
  EnemyUnit({
    required this.id,
    required this.kind,
    required this.pos,
    required this.size,
    required this.hp,
    required this.minX,
    required this.maxX,
  }) : maxHp = hp;
  Rect get bounds => Rect.fromCenter(center: pos, width: size.width, height: size.height);
}

class VisualParticle {
  Offset pos;
  Offset vel;
  Color color;
  double size;
  double life;
  double maxLife;
  bool gravity;
  VisualParticle({
    required this.pos,
    required this.vel,
    required this.color,
    required this.size,
    required this.life,
    this.gravity = true,
  }) : maxLife = life;
}

class ZoneData {
  final int index;
  final String titleAr;
  final String titleEn;
  final String subAr;
  final String subEn;
  final double width;
  final Offset beaconPos;
  const ZoneData({
    required this.index,
    required this.titleAr,
    required this.titleEn,
    required this.subAr,
    required this.subEn,
    required this.width,
    required this.beaconPos,
  });
}

// ================================================================
// ROOT APP
// ================================================================
class AstralSeveranceApp extends StatefulWidget {
  const AstralSeveranceApp({super.key});
  @override
  State<AstralSeveranceApp> createState() => _AstralSeveranceAppState();
}

class _AstralSeveranceAppState extends State<AstralSeveranceApp> {
  GameLang _lang = GameLang.ar;
  AppScreen _screen = AppScreen.splash;

  void _toggleLang() {
    setState(() {
      _lang = _lang == GameLang.ar ? GameLang.en : GameLang.ar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astral Severance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF04060C)),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.ltr, child: child ?? const SizedBox.shrink()),
      home: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case AppScreen.splash:
        return SplashIntroScreen(
          lang: _lang,
          onDone: () => setState(() => _screen = AppScreen.menu),
        );
      case AppScreen.menu:
        return CinematicMainMenu(
          lang: _lang,
          onToggleLang: _toggleLang,
          onStart: () => setState(() => _screen = AppScreen.game),
          onLore: () => setState(() => _screen = AppScreen.lore),
        );
      case AppScreen.lore:
        return WorldLoreScreen(lang: _lang, onBack: () => setState(() => _screen = AppScreen.menu));
      case AppScreen.game:
        return AstralGameScreen(
          lang: _lang,
          onToggleLang: _toggleLang,
          onExitToMenu: () => setState(() => _screen = AppScreen.menu),
        );
    }
  }
}

// ================================================================
// SPLASH
// ================================================================
class SplashIntroScreen extends StatefulWidget {
  final GameLang lang;
  final VoidCallback onDone;
  const SplashIntroScreen({super.key, required this.lang, required this.onDone});
  @override
  State<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends State<SplashIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    Timer(const Duration(seconds: 4), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = widget.lang == GameLang.ar;
    return Scaffold(
      body: GestureDetector(
        onTap: widget.onDone,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) =>
                    CustomPaint(painter: MenuHeroDioramaPainter(time: _ctrl.value * 2 * pi, showHero: false)),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xCC080D1A),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      boxShadow: const [BoxShadow(color: Color(0x66D4AF37), blurRadius: 20)],
                    ),
                    child: const Text(
                      'WAH STUDIO PRESENTS',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    isAr ? 'الانفصال النجمي' : 'ASTRAL SEVERANCE',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [Shadow(color: Color(0xFF38BDF8), blurRadius: 18)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'تاج الرماد' : 'CROWN OF CINDERS',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 55),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x22FFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0x44FFFFFF)),
                    ),
                    child: Text(
                      isAr ? 'اضغط للدخول إلى سولثاريا' : 'TAP TO ENTER SOLTHARIA',
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// MAIN MENU
// ================================================================
class CinematicMainMenu extends StatefulWidget {
  final GameLang lang;
  final VoidCallback onToggleLang;
  final VoidCallback onStart;
  final VoidCallback onLore;
  const CinematicMainMenu({
    super.key,
    required this.lang,
    required this.onToggleLang,
    required this.onStart,
    required this.onLore,
  });
  @override
  State<CinematicMainMenu> createState() => _CinematicMainMenuState();
}

class _CinematicMainMenuState extends State<CinematicMainMenu> {
  Timer? _timer;
  double _time = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 24), (_) {
      if (mounted) setState(() => _time += 0.04);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = widget.lang == GameLang.ar;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: MenuHeroDioramaPainter(time: _time, showHero: true)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xCC090E1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'WAH STUDIO',
                              style: TextStyle(
                                  color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onToggleLang,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0F172A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFD4AF37)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language, size: 16, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 4),
                              Text(isAr ? 'EN' : 'AR',
                                  style: const TextStyle(
                                      color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        isAr ? 'الانفصال النجمي: تاج الرماد' : 'ASTRAL SEVERANCE: CROWN OF CINDERS',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [Shadow(color: Colors.black, blurRadius: 12)],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isAr
                            ? 'لعبة أكشن وميترويدفينيا ثنائية العصور • 6 مناطق مترابطة'
                            : 'Dual-Era 2.5D Action-RPG & Metroidvania • 6 Zones',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                      ),
                      const SizedBox(height: 24),
                      _ornateButton(
                        title: isAr ? 'بدء الملحمة' : 'START ODYSSEY',
                        icon: Icons.play_arrow_rounded,
                        primary: true,
                        onTap: widget.onStart,
                      ),
                      const SizedBox(height: 10),
                      _ornateButton(
                        title: isAr ? 'قصة العالم والشخصيات' : 'STORY & CHARACTERS',
                        icon: Icons.menu_book_rounded,
                        primary: false,
                        onTap: widget.onLore,
                      ),
                    ],
                  ),
                  Text(
                    isAr ? '© WAH Studio • محرك رسومي 2.5D أصلي بالكامل' : '© WAH Studio • 100% Procedural Engine',
                    style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ornateButton({
    required String title,
    required IconData icon,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: primary
                ? [const Color(0xFFD4AF37), const Color(0xFFB48608)]
                : [const Color(0xE60F172A), const Color(0xE61E293B)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primary ? const Color(0xFFFFF3B0) : const Color(0xFFD4AF37),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (primary ? const Color(0xFFD4AF37) : Colors.black).withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary ? const Color(0xFF050811) : const Color(0xFFD4AF37), size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: primary ? const Color(0xFF050811) : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// MENU DIORAMA PAINTER
// ================================================================
class MenuHeroDioramaPainter extends CustomPainter {
  final double time;
  final bool showHero;
  MenuHeroDioramaPainter({required this.time, required this.showHero});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screen = Offset.zero & size;
    final Paint sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF040711), Color(0xFF0F1B33), Color(0xFF1A1025), Color(0xFF070A12)],
      ).createShader(screen);
    canvas.drawRect(screen, sky);

    final Offset sunCenter = Offset(size.width * 0.72, size.height * 0.28);
    canvas.drawCircle(
      sunCenter,
      78,
      Paint()
        ..color = const Color(0x33D4AF37)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    );
    canvas.drawCircle(
      sunCenter,
      54,
      Paint()
        ..color = const Color(0x77D4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      sunCenter,
      92,
      Paint()
        ..color = const Color(0x5538BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final Path citadel = Path()
      ..moveTo(size.width * 0.60, size.height * 0.50)
      ..lineTo(size.width * 0.65, size.height * 0.30)
      ..lineTo(size.width * 0.69, size.height * 0.37)
      ..lineTo(size.width * 0.73, size.height * 0.19)
      ..lineTo(size.width * 0.76, size.height * 0.37)
      ..lineTo(size.width * 0.80, size.height * 0.28)
      ..lineTo(size.width * 0.85, size.height * 0.50)
      ..lineTo(size.width * 0.73, size.height * 0.60)
      ..close();
    canvas.drawPath(citadel, Paint()..color = const Color(0xFF11192E));

    if (showHero) {
      final Path cliff = Path()
        ..moveTo(0, size.height * 0.70)
        ..lineTo(size.width * 0.36, size.height * 0.66)
        ..lineTo(size.width * 0.42, size.height * 0.76)
        ..lineTo(size.width * 0.30, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(cliff, Paint()..color = const Color(0xFF0B101B));

      final Offset heroPos = Offset(size.width * 0.24, size.height * 0.62);
      final Path scarf = Path()
        ..moveTo(heroPos.dx - 4, heroPos.dy - 14)
        ..quadraticBezierTo(
          heroPos.dx - 45,
          heroPos.dy - 22 + sin(time * 2) * 10,
          heroPos.dx - 75,
          heroPos.dy - 5 + cos(time * 2) * 14,
        )
        ..lineTo(heroPos.dx - 65, heroPos.dy + 8 + sin(time * 2) * 10)
        ..quadraticBezierTo(heroPos.dx - 35, heroPos.dy - 6, heroPos.dx - 4, heroPos.dy - 4)
        ..close();
      canvas.drawPath(scarf, Paint()..color = const Color(0xFFDC2626));

      canvas.drawLine(
        Offset(heroPos.dx + 22, heroPos.dy - 28),
        Offset(heroPos.dx + 26, heroPos.dy + 22),
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..strokeWidth = 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: heroPos, width: 22, height: 38), const Radius.circular(6)),
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawCircle(Offset(heroPos.dx, heroPos.dy - 24), 10, Paint()..color = const Color(0xFF334155));
      canvas.drawCircle(
          Offset(heroPos.dx + 4, heroPos.dy - 24), 2.5, Paint()..color = const Color(0xFF38BDF8));
    }
  }

  @override
  bool shouldRepaint(covariant MenuHeroDioramaPainter oldDelegate) => true;
}

// ================================================================
// LORE SCREEN
// ================================================================
class WorldLoreScreen extends StatelessWidget {
  final GameLang lang;
  final VoidCallback onBack;
  const WorldLoreScreen({super.key, required this.lang, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final bool isAr = lang == GameLang.ar;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090E1A),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)), onPressed: onBack),
        title: Text(
          isAr ? 'موسوعة سولثاريا' : 'Lore of Soltharia',
          style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _loreCard(
            isAr,
            PortraitKind.zayden,
            'زايدن — حائك النجوم',
            'Zayden — The Astral Weaver',
            'استيقظ من كبسولة كهرمان محطمة بعد خطف أخته ليرا. يحمل الأسترولاب الناطق "أثيل" وسيف الكرونوس.',
            'Awakened from a shattered Time-Amber pod after the abduction of his sister Lyra. Bears the sentient Astrolabe Aethel and the Chronos Blade.',
          ),
          _loreCard(
            isAr,
            PortraitKind.kaelis,
            'كايليس — الحداد الآلي',
            'Kaelis — The Forge-Master',
            'عملاق آلي ذو أذرع أربعة في ملاذ الرماد. يصهر خام النجوم لتطوير السلاح والدروع.',
            'Four-armed automaton in Cinderhaven Sanctuary. Reforges Starlight Ore into superior blades and armor.',
          ),
          _loreCard(
            isAr,
            PortraitKind.nyxia,
            'نيكسيا — عرّافة الزمن',
            'Nyxia — The Chrono-Seer',
            'باحثة منشقة تمنح النوى العنصرية وتكشف أسرار طي الزمن.',
            'Defected scholar who grants Elemental Cores and reveals the secrets of time folding.',
          ),
          _loreCard(
            isAr,
            PortraitKind.vaelen,
            'الأركون الأعظم فايلين',
            'Grand Archon Vaelen',
            'سيد برج الدهور. يتحكم بالزمن ويطلق رماحاً شمسية تُعكس بدرع الصد.',
            'Master of the Spire of Eons. Commands time and hurls solar spears that must be deflected.',
          ),
        ],
      ),
    );
  }

  Widget _loreCard(bool isAr, PortraitKind kind, String ta, String te, String ba, String be) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x88D4AF37)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 64, height: 64, child: CustomPaint(painter: CharacterPortraitPainter(kind: kind))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? ta : te,
                    style: const TextStyle(
                        color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(isAr ? ba : be,
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CHARACTER PORTRAIT PAINTER
// ================================================================
class CharacterPortraitPainter extends CustomPainter {
  final PortraitKind kind;
  CharacterPortraitPainter({required this.kind});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Rect rect = Rect.fromLTWH(0, 0, s, s);
    final RRect bg = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.12));
    Color bgColor;
    switch (kind) {
      case PortraitKind.zayden: bgColor = const Color(0xFF1A2138); break;
      case PortraitKind.aethel: bgColor = const Color(0xFF1F1B12); break;
      case PortraitKind.kaelis: bgColor = const Color(0xFF1E1E1E); break;
      case PortraitKind.nyxia: bgColor = const Color(0xFF151225); break;
      case PortraitKind.warden: bgColor = const Color(0xFF1C1310); break;
      case PortraitKind.vaelen: bgColor = const Color(0xFF291508); break;
      case PortraitKind.lyra: bgColor = const Color(0xFF231A10); break;
    }
    canvas.drawRRect(bg, Paint()..color = bgColor);

    switch (kind) {
      case PortraitKind.zayden:
        canvas.drawCircle(Offset(s * 0.5, s * 0.52), s * 0.30, Paint()..color = const Color(0xFF2D3A56));
        canvas.drawCircle(Offset(s * 0.5, s * 0.52), s * 0.24, Paint()..color = const Color(0xFF1B2438));
        canvas.drawCircle(Offset(s * 0.38, s * 0.55), s * 0.035, Paint()..color = const Color(0xFF38BDF8));
        canvas.drawCircle(Offset(s * 0.62, s * 0.55), s * 0.035, Paint()..color = const Color(0xFF38BDF8));
        final Path scarf = Path()
          ..moveTo(s * 0.20, s * 0.82)
          ..quadraticBezierTo(s * 0.5, s * 0.70, s * 0.85, s * 0.85)
          ..lineTo(s * 0.80, s * 0.95)
          ..quadraticBezierTo(s * 0.5, s * 0.85, s * 0.20, s * 0.95)
          ..close();
        canvas.drawPath(scarf, Paint()..color = const Color(0xFFDC2626));
        break;

      case PortraitKind.aethel:
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(s * 0.5, s * 0.5),
            s * (0.20 + i * 0.07),
            Paint()
              ..color = const Color(0xFFD4AF37)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.08, Paint()..color = const Color(0xFFE6C64C));
        break;

      case PortraitKind.kaelis:
        canvas.drawRect(
            Rect.fromLTWH(s * 0.25, s * 0.35, s * 0.5, s * 0.5), Paint()..color = const Color(0xFF4A4A4A));
        canvas.drawRect(
            Rect.fromLTWH(s * 0.25, s * 0.35, s * 0.5, s * 0.10), Paint()..color = const Color(0xFF8B4513));
        canvas.drawCircle(Offset(s * 0.5, s * 0.55), s * 0.08, Paint()..color = const Color(0xFFFF7A00));
        canvas.drawCircle(Offset(s * 0.5, s * 0.55), s * 0.04, Paint()..color = const Color(0xFFFFE082));
        break;

      case PortraitKind.nyxia:
        final Path hood = Path()
          ..moveTo(s * 0.5, s * 0.15)
          ..lineTo(s * 0.85, s * 0.85)
          ..lineTo(s * 0.15, s * 0.85)
          ..close();
        canvas.drawPath(hood, Paint()..color = const Color(0xFF5C2E8B));
        canvas.drawCircle(Offset(s * 0.5, s * 0.55), s * 0.18, Paint()..color = const Color(0xFFEAD1FF));
        canvas.drawCircle(Offset(s * 0.43, s * 0.55), s * 0.025, Paint()..color = const Color(0xFFD500F9));
        canvas.drawCircle(Offset(s * 0.57, s * 0.55), s * 0.025, Paint()..color = const Color(0xFFD500F9));
        break;

      case PortraitKind.warden:
        canvas.drawRect(
            Rect.fromLTWH(s * 0.20, s * 0.30, s * 0.6, s * 0.55), Paint()..color = const Color(0xFF3D2B1F));
        canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.15, Paint()..color = const Color(0xFF8B0000));
        canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.06, Paint()..color = const Color(0xFFFFEB3B));
        break;

      case PortraitKind.vaelen:
        final Path crown = Path()
          ..moveTo(s * 0.25, s * 0.30)
          ..lineTo(s * 0.35, s * 0.15)
          ..lineTo(s * 0.45, s * 0.28)
          ..lineTo(s * 0.5, s * 0.12)
          ..lineTo(s * 0.55, s * 0.28)
          ..lineTo(s * 0.65, s * 0.15)
          ..lineTo(s * 0.75, s * 0.30)
          ..lineTo(s * 0.7, s * 0.45)
          ..lineTo(s * 0.3, s * 0.45)
          ..close();
        canvas.drawPath(crown, Paint()..color = const Color(0xFFD4AF37));
        canvas.drawRect(
            Rect.fromLTWH(s * 0.28, s * 0.45, s * 0.44, s * 0.42), Paint()..color = const Color(0xFF2B1810));
        canvas.drawCircle(Offset(s * 0.40, s * 0.62), s * 0.03, Paint()..color = const Color(0xFFFFD54F));
        canvas.drawCircle(Offset(s * 0.60, s * 0.62), s * 0.03, Paint()..color = const Color(0xFFFFD54F));
        break;

      case PortraitKind.lyra:
        canvas.drawCircle(Offset(s * 0.5, s * 0.52), s * 0.30, Paint()..color = const Color(0xFFE8C86A));
        canvas.drawCircle(Offset(s * 0.5, s * 0.55), s * 0.22, Paint()..color = const Color(0xFFF7E7C1));
        canvas.drawCircle(Offset(s * 0.42, s * 0.55), s * 0.03, Paint()..color = const Color(0xFF38BDF8));
        canvas.drawCircle(Offset(s * 0.58, s * 0.55), s * 0.03, Paint()..color = const Color(0xFF38BDF8));
        break;
    }

    canvas.drawRRect(
      bg,
      Paint()
        ..color = const Color(0x99D4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CharacterPortraitPainter oldDelegate) => oldDelegate.kind != kind;
}

// ================================================================
// GAME SCREEN
// ================================================================
class AstralGameScreen extends StatefulWidget {
  final GameLang lang;
  final VoidCallback onToggleLang;
  final VoidCallback onExitToMenu;
  const AstralGameScreen({
    super.key,
    required this.lang,
    required this.onToggleLang,
    required this.onExitToMenu,
  });
  @override
  State<AstralGameScreen> createState() => _AstralGameScreenState();
}

class _AstralGameScreenState extends State<AstralGameScreen> {
  Timer? _loopTimer;
  final Random _rng = Random();

  static const double groundY = 580.0;

  static const List<ZoneData> kZones = [
    ZoneData(
        index: 0,
        titleAr: '١. أطلال الكهرمان',
        titleEn: '1. The Amber Wastes',
        subAr: 'موقع الصحوة والجسر الزمني',
        subEn: 'Awakening Ruins',
        width: 2800,
        beaconPos: Offset(250, groundY)),
    ZoneData(
        index: 1,
        titleAr: '٢. ملاذ الرماد',
        titleEn: '2. Cinderhaven Sanctuary',
        subAr: 'معقل كايليس ونيكسيا',
        subEn: 'Home of Kaelis & Nyxia',
        width: 2200,
        beaconPos: Offset(420, groundY)),
    ZoneData(
        index: 2,
        titleAr: '٣. التروس الغارقة',
        titleEn: '3. The Sunken Clockwork',
        subAr: 'ألغاز وعرين الحارس',
        subEn: 'Puzzles & Warden Arena',
        width: 3200,
        beaconPos: Offset(300, groundY)),
    ZoneData(
        index: 3,
        titleAr: '٤. هاوية النجوم',
        titleEn: '4. Starlight Chasm',
        subAr: 'خطاف وجزر زمنية',
        subEn: 'Grapple & Time Islands',
        width: 3200,
        beaconPos: Offset(260, groundY)),
    ZoneData(
        index: 4,
        titleAr: '٥. قلعة الأركون',
        titleEn: '5. Citadel of the Archons',
        subAr: 'حراس الدروع الثقيلة',
        subEn: 'Heavy Sentinels',
        width: 3000,
        beaconPos: Offset(260, groundY)),
    ZoneData(
        index: 5,
        titleAr: '٦. برج الدهور',
        titleEn: '6. The Spire of Eons',
        subAr: 'المواجهة الأخيرة',
        subEn: 'Final Showdown',
        width: 2400,
        beaconPos: Offset(260, groundY)),
  ];

  int _currentZoneIdx = 0;
  int _maxZoneReached = 0;
  EraState _era = EraState.present;
  double _eraWaveRadius = 0.0;

  Offset _playerPos = const Offset(220, 540);
  Offset _playerVel = Offset.zero;
  final Size _playerSize = const Size(34, 52);
  int _facing = 1;
  bool _onGround = false;
  bool _onWall = false;
  int _wallDir = 0;
  int _jumpsLeft = 2;
  double _walkCycle = 0.0;
  double _worldTime = 0.0;

  final List<Offset> _scarfNodes = List.generate(7, (_) => const Offset(220, 540));

  int _level = 1;
  int _xp = 0;
  int _xpToNext = 100;
  int _skillPoints = 1;
  int _starlightOre = 35;
  int _vitalityLvl = 1;
  int _mightLvl = 1;
  int _astralLvl = 1;

  int _hp = 6;
  int get _maxHp => 5 + _vitalityLvl;
  double _energy = 80.0;
  double get _maxEnergy => 60.0 + _astralLvl * 20.0;

  WeaponTier _weaponTier = WeaponTier.rustyBlade;
  ElementalCore _elementalCore = ElementalCore.none;
  AstralSkill _activeSkill = AstralSkill.starBolt;

  int _comboStep = 0;
  double _comboResetTimer = 0.0;
  double _slashTimer = 0.0;
  bool _isPlungeAttack = false;
  final Set<int> _hitEnemiesInSwing = {};

  double _parryTimer = 0.0;
  double _parryCooldown = 0.0;
  double _dashTimer = 0.0;
  double _dashCooldown = 0.0;
  double _invulnTimer = 0.0;

  Offset? _activeGrappleTarget;
  double _grappleTimer = 0.0;

  bool _moveLeft = false;
  bool _moveRight = false;
  bool _aimDown = false;
  bool _jumpHeld = false;

  Offset _camera = const Offset(0, 200);
  double _shake = 0.0;
  double _zoneBannerTimer = 3.5;

  final List<Platform25D> _platforms = [];
  final List<BreakableWall> _breakableWalls = [];
  final List<PushBlock> _pushBlocks = [];
  final List<PressurePlate> _plates = [];
  final List<GateDoor> _gates = [];
  final List<GrappleRing> _grappleRings = [];
  final List<TreasureChest> _chests = [];
  final List<BreakableCrystal> _crystals = [];
  final List<NpcEntity> _npcs = [];
  final List<EnemyUnit> _enemies = [];
  final List<ProjectileEntity> _projectiles = [];
  final List<BombEntity> _bombs = [];
  final List<LootOrb> _lootOrbs = [];
  final List<VisualParticle> _particles = [];

  final Set<String> _openedChestIds = {};
  bool _wardenDefeated = false;
  bool _vaelenDefeated = false;

  List<DialogueLine>? _activeDialogueList;
  int _dialogueIndex = 0;
  bool _openForgeAfterDialogue = false;
  bool _showRpgModal = false;
  int _rpgTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _hp = _maxHp;
    _loadZone(0, spawnX: 220);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startDialogue(const [
          DialogueLine(
            speaker: PortraitKind.aethel,
            speakerAr: 'أثيل (الأسترولاب الفلكي)',
            speakerEn: 'Aethel (Sentient Astrolabe)',
            textAr:
                'زايدن! لقد تحطمت كبسولة الكهرمان أخيراً.. الأركون فايلين أخذ أختك ليرا إلى برج الدهور (المنطقة 6).',
            textEn:
                'Zayden! Your Time-Amber pod finally shattered... Archon Vaelen took your sister Lyra to the Spire of Eons (Zone 6).',
          ),
          DialogueLine(
            speaker: PortraitKind.zayden,
            speakerAr: 'زايدن (Zayden)',
            speakerEn: 'Zayden',
            textAr:
                'الطيّ الزمني ما زال يعمل في بوصلتي! سأبدّل بين الحاضر والماضي لعبور الجسور المحطمة.',
            textEn:
                'Time-Fold still resonates in my compass! I will shift between Present and Past to cross broken bridges.',
          ),
        ]);
      }
    });
    _loopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _update(0.016));
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    super.dispose();
  }

  // ================================================================
  // ZONE LOADING
  // ================================================================
  void _loadZone(int zoneIdx, {required double spawnX}) {
    _currentZoneIdx = zoneIdx.clamp(0, kZones.length - 1);
    if (_currentZoneIdx > _maxZoneReached) _maxZoneReached = _currentZoneIdx;
    _zoneBannerTimer = 3.5;
    _playerPos = Offset(spawnX, groundY - 40);
    _playerVel = Offset.zero;
    _activeGrappleTarget = null;
    for (int i = 0; i < _scarfNodes.length; i++) {
      _scarfNodes[i] = _playerPos;
    }
    _platforms.clear();
    _breakableWalls.clear();
    _pushBlocks.clear();
    _plates.clear();
    _gates.clear();
    _grappleRings.clear();
    _chests.clear();
    _crystals.clear();
    _npcs.clear();
    _enemies.clear();
    _projectiles.clear();
    _bombs.clear();
    _lootOrbs.clear();
    _particles.clear();

    final double w = kZones[_currentZoneIdx].width;

    if (_currentZoneIdx == 0) {
      _platforms.addAll(const [
        Platform25D(Rect.fromLTWH(0, groundY, 1050, 220)),
        Platform25D(Rect.fromLTWH(1050, groundY, 380, 36), onlyInPast: true, hasGrass: false),
        Platform25D(Rect.fromLTWH(1060, groundY + 110, 360, 24), isHazard: true, onlyInPresent: true),
        Platform25D(Rect.fromLTWH(1430, groundY, 1370, 220)),
        Platform25D(Rect.fromLTWH(460, 460, 220, 26)),
        Platform25D(Rect.fromLTWH(760, 360, 220, 26)),
        Platform25D(Rect.fromLTWH(1650, 450, 250, 26)),
        Platform25D(Rect.fromLTWH(2020, 350, 240, 26), onlyInPast: true),
      ]);
      _grappleRings.add(const GrappleRing(Offset(1240, 360)));
      _crystals.addAll([
        BreakableCrystal(const Offset(540, 460)),
        BreakableCrystal(const Offset(1720, 450)),
        BreakableCrystal(const Offset(2280, groundY)),
      ]);
      _chests.add(TreasureChest(
          id: 'z0_c1', pos: const Offset(2140, 350), oreReward: 25, onlyInPast: true));
      _enemies.addAll([
        EnemyUnit(id: 101, kind: EnemyKind.ashStalker, pos: const Offset(650, groundY - 22), size: const Size(44, 34), hp: 4, minX: 420, maxX: 980),
        EnemyUnit(id: 102, kind: EnemyKind.astralWeaver, pos: const Offset(1770, 410), size: const Size(42, 54), hp: 5, minX: 1660, maxX: 1880),
        EnemyUnit(id: 103, kind: EnemyKind.chronoSentinel, pos: const Offset(2320, groundY - 30), size: const Size(48, 58), hp: 7, minX: 1980, maxX: 2560),
      ]);
    } else if (_currentZoneIdx == 1) {
      _platforms.addAll([
        Platform25D(Rect.fromLTWH(0, groundY, w, 220)),
        const Platform25D(Rect.fromLTWH(350, 440, 280, 26)),
        const Platform25D(Rect.fromLTWH(920, 400, 340, 26)),
        const Platform25D(Rect.fromLTWH(1480, 440, 280, 26)),
      ]);
      _npcs.addAll(const [
        NpcEntity(
          id: 'kaelis',
          pos: Offset(780, groundY),
          nameAr: 'كايليس (Kaelis)',
          nameEn: 'Kaelis',
          portrait: PortraitKind.kaelis,
          opensForge: true,
          lines: [
            DialogueLine(
              speaker: PortraitKind.kaelis,
              speakerAr: 'كايليس (حدّاد الملاذ)',
              speakerEn: 'Kaelis (Forge-Master)',
              textAr:
                  'مطارقي الأربع لم تهدأ منذ ألف عام يا زايدن! أحضر لي خام ضوء النجوم وسأصهر لك سيفاً يشطر دروع الأركون.',
              textEn:
                  'My four hammers have not rested in a millennium, Zayden! Bring Starlight Ore and I shall forge a blade that cleaves Archon armor.',
            ),
          ],
        ),
        NpcEntity(
          id: 'nyxia',
          pos: Offset(1280, groundY),
          nameAr: 'نيكسيا (Nyxia)',
          nameEn: 'Nyxia',
          portrait: PortraitKind.nyxia,
          opensForge: true,
          lines: [
            DialogueLine(
              speaker: PortraitKind.nyxia,
              speakerAr: 'نيكسيا (عرّافة الزمن)',
              speakerEn: 'Nyxia (Chrono-Seer)',
              textAr:
                  'في "التروس الغارقة" ستواجه جدراناً متصدعة لا يحطمها إلا قنبلة الزمن، ومكعبات رونية تفتح بوابة الحارس.',
              textEn:
                  'In "The Sunken Clockwork" you will face cracked walls shattered only by Chrono-Bomb, and rune blocks that unlock the Warden\'s gate.',
            ),
          ],
        ),
      ]);
      _chests.add(TreasureChest(id: 'z1_c1', pos: const Offset(1090, 400), oreReward: 30));
    } else if (_currentZoneIdx == 2) {
      _platforms.addAll([
        Platform25D(Rect.fromLTWH(0, groundY, w, 220), hasGrass: false),
        const Platform25D(Rect.fromLTWH(520, 450, 240, 26), hasGrass: false),
        const Platform25D(Rect.fromLTWH(1250, 420, 260, 26), hasGrass: false),
        const Platform25D(Rect.fromLTWH(2150, 430, 220, 26), hasGrass: false),
        const Platform25D(Rect.fromLTWH(2620, 430, 220, 26), hasGrass: false),
      ]);
      _breakableWalls.add(BreakableWall(const Rect.fromLTWH(880, groundY - 150, 44, 150)));
      _pushBlocks.add(PushBlock(const Rect.fromLTWH(1420, groundY - 54, 54, 54)));
      _plates.add(PressurePlate(rect: const Rect.fromLTWH(1720, groundY - 10, 70, 10), targetGateId: 1));
      _gates.add(GateDoor(id: 1, closedRect: const Rect.fromLTWH(1880, groundY - 170, 34, 170)));
      _chests.add(TreasureChest(id: 'z2_c1', pos: const Offset(1380, 420), oreReward: 40));
      _enemies.addAll([
        EnemyUnit(id: 201, kind: EnemyKind.chronoSentinel, pos: const Offset(680, groundY - 30), size: const Size(48, 58), hp: 8, minX: 450, maxX: 840),
        EnemyUnit(id: 202, kind: EnemyKind.astralWeaver, pos: const Offset(1380, 380), size: const Size(42, 54), hp: 6, minX: 1260, maxX: 1490),
      ]);
      if (!_wardenDefeated) {
        _enemies.add(EnemyUnit(id: 299, kind: EnemyKind.automatonBoss, pos: const Offset(2520, groundY - 64), size: const Size(96, 126), hp: 45, minX: 2050, maxX: 2950));
      }
    } else if (_currentZoneIdx == 3) {
      _platforms.addAll(const [
        Platform25D(Rect.fromLTWH(0, groundY, 750, 220)),
        Platform25D(Rect.fromLTWH(750, groundY + 120, 1650, 30), isHazard: true, hasGrass: false),
        Platform25D(Rect.fromLTWH(920, 470, 260, 28)),
        Platform25D(Rect.fromLTWH(1340, 390, 260, 28), onlyInPast: true),
        Platform25D(Rect.fromLTWH(1760, 450, 280, 28)),
        Platform25D(Rect.fromLTWH(2400, groundY, 800, 220)),
      ]);
      _grappleRings.addAll(const [
        GrappleRing(Offset(860, 310)),
        GrappleRing(Offset(1280, 260)),
        GrappleRing(Offset(1700, 290)),
        GrappleRing(Offset(2180, 320)),
      ]);
      _chests.add(TreasureChest(id: 'z3_c1', pos: const Offset(1470, 390), oreReward: 50, onlyInPast: true));
      _enemies.addAll([
        EnemyUnit(id: 301, kind: EnemyKind.wingedDrake, pos: const Offset(1080, 320), size: const Size(56, 42), hp: 7, minX: 850, maxX: 1350),
        EnemyUnit(id: 302, kind: EnemyKind.wingedDrake, pos: const Offset(1920, 300), size: const Size(56, 42), hp: 7, minX: 1650, maxX: 2250),
        EnemyUnit(id: 303, kind: EnemyKind.chronoSentinel, pos: const Offset(2680, groundY - 30), size: const Size(48, 58), hp: 10, minX: 2450, maxX: 2950),
      ]);
    } else if (_currentZoneIdx == 4) {
      _platforms.addAll([
        Platform25D(Rect.fromLTWH(0, groundY, w, 220), hasGrass: false),
        const Platform25D(Rect.fromLTWH(480, 440, 280, 26), hasGrass: false),
        const Platform25D(Rect.fromLTWH(980, 340, 320, 26), onlyInPast: true, hasGrass: false),
        const Platform25D(Rect.fromLTWH(1520, 440, 300, 26), hasGrass: false),
        const Platform25D(Rect.fromLTWH(2100, 360, 320, 26), hasGrass: false),
      ]);
      _crystals.addAll([
        BreakableCrystal(const Offset(620, 440)),
        BreakableCrystal(const Offset(1660, 440)),
        BreakableCrystal(const Offset(2240, 360)),
      ]);
      _enemies.addAll([
        EnemyUnit(id: 401, kind: EnemyKind.chronoSentinel, pos: const Offset(750, groundY - 30), size: const Size(48, 58), hp: 11, minX: 500, maxX: 1100),
        EnemyUnit(id: 402, kind: EnemyKind.astralWeaver, pos: const Offset(1650, 400), size: const Size(44, 56), hp: 9, minX: 1540, maxX: 1790),
        EnemyUnit(id: 403, kind: EnemyKind.wingedDrake, pos: const Offset(2050, 260), size: const Size(58, 44), hp: 10, minX: 1800, maxX: 2450),
        EnemyUnit(id: 404, kind: EnemyKind.chronoSentinel, pos: const Offset(2480, groundY - 30), size: const Size(50, 60), hp: 12, minX: 2200, maxX: 2780),
      ]);
    } else if (_currentZoneIdx == 5) {
      _platforms.addAll([
        Platform25D(Rect.fromLTWH(0, groundY, w, 220), hasGrass: false),
        const Platform25D(Rect.fromLTWH(560, 430, 240, 24), hasGrass: false),
        const Platform25D(Rect.fromLTWH(1120, 330, 260, 24), onlyInPast: true, hasGrass: false),
        const Platform25D(Rect.fromLTWH(1640, 430, 240, 24), hasGrass: false),
      ]);
      _grappleRings.addAll(const [
        GrappleRing(Offset(680, 260)),
        GrappleRing(Offset(1760, 260)),
      ]);
      if (!_vaelenDefeated) {
        _enemies.add(EnemyUnit(id: 599, kind: EnemyKind.archonVaelenBoss, pos: const Offset(1520, groundY - 70), size: const Size(84, 132), hp: 75, minX: 520, maxX: 2050));
      } else {
        _npcs.add(const NpcEntity(
          id: 'lyra',
          pos: Offset(1350, groundY),
          nameAr: 'ليرا (Lyra)',
          nameEn: 'Lyra',
          portrait: PortraitKind.lyra,
          lines: [
            DialogueLine(
              speaker: PortraitKind.lyra,
              speakerAr: 'ليرا (Lyra)',
              speakerEn: 'Lyra',
              textAr: 'زايدن! لقد حطّمت الساعة الأبدية وهزمت فايلين! أرواح سولثاريا حرة بفضلك.',
              textEn: 'Zayden! You shattered the Eternal Clock and vanquished Vaelen! The souls of Soltharia are finally free!',
            ),
          ],
        ));
      }
    }
  }

  // ================================================================
  // MAIN UPDATE LOOP
  // ================================================================
  void _update(double dt) {
    if (_showRpgModal || _activeDialogueList != null) return;
    _worldTime += dt;
    if (_zoneBannerTimer > 0) _zoneBannerTimer -= dt;
    if (_shake > 0) _shake = max(0, _shake - dt * 32);
    if (_invulnTimer > 0) _invulnTimer -= dt;
    if (_parryTimer > 0) _parryTimer -= dt;
    if (_parryCooldown > 0) _parryCooldown -= dt;
    if (_dashCooldown > 0) _dashCooldown -= dt;
    if (_comboResetTimer > 0) {
      _comboResetTimer -= dt;
      if (_comboResetTimer <= 0) _comboStep = 0;
    }
    if (_eraWaveRadius > 0) {
      _eraWaveRadius += dt * 1900;
      if (_eraWaveRadius > 2200) _eraWaveRadius = 0;
    }
    _energy = min(_maxEnergy, _energy + dt * 4.5);
    _updatePlayerMovement(dt);
    _updatePushBlocksAndPlates(dt);
    _updateSlashCombat(dt);
    _updateBombsAndProjectiles(dt);
    _updateEnemies(dt);
    _updateLootAndParticles(dt);
    if (mounted) setState(() {});
  }

  void _updatePlayerMovement(double dt) {
    final double zoneW = kZones[_currentZoneIdx].width;
    if (_activeGrappleTarget != null && _grappleTimer > 0) {
      _grappleTimer -= dt;
      final Offset toTarget = _activeGrappleTarget! - _playerPos;
      if (toTarget.distance < 36 || _grappleTimer <= 0) {
        _activeGrappleTarget = null;
        _playerVel = const Offset(0, -340);
        _jumpsLeft = 2;
      } else {
        final Offset dir = toTarget / toTarget.distance;
        _playerVel = dir * 920.0;
        _playerPos += _playerVel * dt;
      }
      _updateScarfPhysics();
      return;
    }

    if (_dashTimer > 0) {
      _dashTimer -= dt;
      _playerVel = Offset(_facing * 780.0, 0);
      _spawnParticles(_playerPos, const Color(0xFFD4AF37), 2, speed: 60);
    } else {
      double targetVx = 0;
      if (_moveLeft) {
        targetVx = -310.0;
        _facing = -1;
      } else if (_moveRight) {
        targetVx = 310.0;
        _facing = 1;
      }
      if (targetVx != 0 && _onGround) {
        _walkCycle += dt * 14.0;
      } else {
        _walkCycle = 0.0;
      }
      final double accel = _onGround ? 18.0 : 12.0;
      final double vx = _playerVel.dx + (targetVx - _playerVel.dx) * min(1.0, accel * dt);
      double gravity = 1480.0;
      if (_onWall && _playerVel.dy > 0) gravity *= 0.32;
      if (!_jumpHeld && _playerVel.dy < -140 && !_isPlungeAttack) gravity *= 2.3;
      final double vy = min(880.0, _playerVel.dy + gravity * dt);
      _playerVel = Offset(vx, vy);
    }

    Offset nextPos = _playerPos + _playerVel * dt;
    _onGround = false;
    _onWall = false;
    _wallDir = 0;

    final List<Rect> solidWalls = [
      for (final bw in _breakableWalls)
        if (!bw.destroyed) bw.rect,
      for (final g in _gates)
        if (g.openProgress < 0.85) g.currentRect,
    ];

    final Rect pRectX = Rect.fromCenter(
        center: Offset(nextPos.dx, _playerPos.dy), width: _playerSize.width, height: _playerSize.height);
    for (final wRect in solidWalls) {
      if (pRectX.overlaps(wRect)) {
        if (_playerVel.dx > 0) {
          nextPos = Offset(wRect.left - _playerSize.width / 2, nextPos.dy);
          _wallDir = 1;
        } else if (_playerVel.dx < 0) {
          nextPos = Offset(wRect.right + _playerSize.width / 2, nextPos.dy);
          _wallDir = -1;
        }
        _playerVel = Offset(0, _playerVel.dy);
        _onWall = true;
      }
    }

    for (final pb in _pushBlocks) {
      if (pRectX.overlaps(pb.rect)) {
        if (_playerVel.dx > 0) {
          pb.rect = pb.rect.shift(Offset(140 * dt, 0));
          nextPos = Offset(pb.rect.left - _playerSize.width / 2, nextPos.dy);
        } else if (_playerVel.dx < 0) {
          pb.rect = pb.rect.shift(Offset(-140 * dt, 0));
          nextPos = Offset(pb.rect.right + _playerSize.width / 2, nextPos.dy);
        }
      }
    }

    Rect pRectY = Rect.fromCenter(center: nextPos, width: _playerSize.width, height: _playerSize.height);
    for (final plat in _platforms) {
      if (!plat.isActiveIn(_era)) continue;
      if (pRectY.overlaps(plat.rect)) {
        if (plat.isHazard) {
          if (_isPlungeAttack) {
            _playerVel = const Offset(0, -580);
            _jumpsLeft = 2;
            _isPlungeAttack = false;
            _shake = 8.0;
            _spawnParticles(Offset(nextPos.dx, plat.rect.top), Colors.white, 12);
          } else {
            _damagePlayer(1, Offset(nextPos.dx, plat.rect.top));
            nextPos = Offset(max(120.0, nextPos.dx - 160), groundY - 60);
            _playerVel = Offset.zero;
          }
          break;
        }
        if (_playerVel.dy >= 0 && (_playerPos.dy + _playerSize.height / 2) <= plat.rect.top + 22) {
          nextPos = Offset(nextPos.dx, plat.rect.top - _playerSize.height / 2);
          _playerVel = Offset(_playerVel.dx, 0);
          _onGround = true;
          _isPlungeAttack = false;
          _jumpsLeft = 2;
        }
      }
    }

    for (final pb in _pushBlocks) {
      if (pRectY.overlaps(pb.rect) && _playerVel.dy >= 0 && (_playerPos.dy + _playerSize.height / 2) <= pb.rect.top + 18) {
        nextPos = Offset(nextPos.dx, pb.rect.top - _playerSize.height / 2);
        _playerVel = Offset(_playerVel.dx, 0);
        _onGround = true;
        _jumpsLeft = 2;
      }
    }

    if (nextPos.dy > groundY + 190) {
      _damagePlayer(1, nextPos);
      nextPos = Offset(kZones[_currentZoneIdx].beaconPos.dx, groundY - 40);
      _playerVel = Offset.zero;
    }

    if (nextPos.dx >= zoneW - 24 && _currentZoneIdx < kZones.length - 1) {
      _loadZone(_currentZoneIdx + 1, spawnX: 70);
      return;
    } else if (nextPos.dx <= 24 && _currentZoneIdx > 0) {
      final int prev = _currentZoneIdx - 1;
      _loadZone(prev, spawnX: kZones[prev].width - 90);
      return;
    }

    _playerPos = Offset(nextPos.dx.clamp(24.0, zoneW - 24.0), nextPos.dy);
    _updateScarfPhysics();
  }

  void _updateScarfPhysics() {
    final Offset anchor = _playerPos + Offset(-_facing * 8.0, -14.0);
    _scarfNodes[0] = anchor;
    for (int i = 1; i < _scarfNodes.length; i++) {
      final Offset prev = _scarfNodes[i - 1];
      final Offset wind = Offset(
        -_facing * 9.5 + sin(_worldTime * 7 + i) * 2.5,
        2.0 + cos(_worldTime * 5 + i) * 2.0,
      );
      final Offset desired = prev + wind;
      _scarfNodes[i] = Offset(
        _scarfNodes[i].dx + (desired.dx - _scarfNodes[i].dx) * 0.38,
        _scarfNodes[i].dy + (desired.dy - _scarfNodes[i].dy) * 0.38,
      );
    }
  }

  void _updatePushBlocksAndPlates(double dt) {
    for (final pl in _plates) {
      pl.isPressed = false;
      for (final pb in _pushBlocks) {
        if (pb.rect.overlaps(pl.rect.inflate(12))) pl.isPressed = true;
      }
      final Rect pRect = Rect.fromCenter(center: _playerPos, width: _playerSize.width, height: _playerSize.height);
      if (pRect.overlaps(pl.rect.inflate(8))) pl.isPressed = true;
      for (final g in _gates) {
        if (g.id == pl.targetGateId) g.isOpen = pl.isPressed;
      }
    }
    for (final g in _gates) {
      final double target = g.isOpen ? 1.0 : 0.0;
      g.openProgress += (target - g.openProgress) * min(1.0, dt * 5.0);
    }
  }

  int get _swordDamage {
    int base = 1 + _mightLvl;
    if (_weaponTier == WeaponTier.starlightEdge) base += 2;
    if (_weaponTier == WeaponTier.chronosSunCleaver) base += 5;
    if (_comboStep == 2) base += 2;
    return base;
  }

  void _triggerSwordAttack() {
    if (_showRpgModal || _activeDialogueList != null) return;
    if (_slashTimer > 0) return;
    _hitEnemiesInSwing.clear();
    if (!_onGround && _aimDown) {
      _isPlungeAttack = true;
      _slashTimer = 0.24;
      _playerVel = Offset(_playerVel.dx, 640);
      return;
    }
    _isPlungeAttack = false;
    _slashTimer = 0.18;
    _comboStep = (_comboStep + 1) % 3;
    _comboResetTimer = 0.9;
    _playerVel = Offset(_facing * (_comboStep == 2 ? 240.0 : 120.0), _playerVel.dy);
  }

  void _triggerParryOrDash() {
    if (_showRpgModal || _activeDialogueList != null) return;
    if (_parryCooldown <= 0) {
      _parryTimer = 0.36;
      _parryCooldown = 0.65;
      _spawnParticles(_playerPos, const Color(0xFFD4AF37), 10, speed: 120);
    }
    if (_dashCooldown <= 0 && (_moveLeft || _moveRight)) {
      _dashTimer = 0.16;
      _dashCooldown = 0.55;
    }
  }

  void _triggerJump() {
    if (_showRpgModal || _activeDialogueList != null) return;
    if (_onWall) {
      _playerVel = Offset(-_wallDir * 410.0, -560.0);
      _jumpsLeft = 1;
    } else if (_jumpsLeft > 0) {
      _jumpsLeft--;
      _playerVel = Offset(_playerVel.dx, -550.0);
      _onGround = false;
    }
    _spawnParticles(_playerPos + const Offset(0, 22), Colors.white70, 6);
  }

  void _triggerActiveSkill() {
    if (_showRpgModal || _activeDialogueList != null) return;
    switch (_activeSkill) {
      case AstralSkill.starBolt:
        if (_energy < 18) return;
        _energy -= 18;
        _shake = 5.0;
        _projectiles.add(ProjectileEntity(
          pos: _playerPos + Offset(_facing * 26.0, -6),
          vel: Offset(_facing * 760.0, 0),
          radius: 12,
          fromPlayer: true,
          color: const Color(0xFF38BDF8),
          damage: 3 + _astralLvl * 2,
        ));
        break;
      case AstralSkill.chronoBomb:
        if (_energy < 24) return;
        _energy -= 24;
        _bombs.add(BombEntity(
          pos: _playerPos + Offset(_facing * 18.0, -14),
          vel: Offset(_facing * 320.0, -380.0),
        ));
        break;
      case AstralSkill.tetherHook:
        GrappleRing? best;
        double bestDist = 520.0;
        for (final gr in _grappleRings) {
          final double d = (gr.pos - _playerPos).distance;
          if (d < bestDist) {
            bestDist = d;
            best = gr;
          }
        }
        if (best != null) {
          _activeGrappleTarget = best.pos;
          _grappleTimer = 0.55;
          _shake = 4.0;
        }
        break;
      case AstralSkill.timeFold:
        _era = _era == EraState.present ? EraState.past : EraState.present;
        _eraWaveRadius = 12.0;
        _shake = 14.0;
        _spawnParticles(
          _playerPos,
          _era == EraState.past ? const Color(0xFFD4AF37) : const Color(0xFFEF4444),
          28,
          speed: 280,
        );
        break;
    }
  }

  void _updateSlashCombat(double dt) {
    if (_slashTimer <= 0) return;
    _slashTimer -= dt;
    final Rect slashBox = _isPlungeAttack
        ? Rect.fromCenter(center: _playerPos + const Offset(0, 42), width: 74, height: 64)
        : Rect.fromCenter(
            center: _playerPos + Offset(_facing * 46.0, -4),
            width: _comboStep == 2 ? 96 : 82,
            height: _comboStep == 2 ? 74 : 58,
          );

    for (final cr in _crystals) {
      if (!cr.broken && slashBox.overlaps(Rect.fromCenter(center: cr.pos, width: 36, height: 46))) {
        cr.hp--;
        _spawnParticles(cr.pos, const Color(0xFF38BDF8), 10);
        if (cr.hp <= 0) {
          cr.broken = true;
          _dropLoot(cr.pos, count: 4);
        }
      }
    }

    for (final e in _enemies) {
      if (_hitEnemiesInSwing.contains(e.id)) continue;
      if (slashBox.overlaps(e.bounds)) {
        _hitEnemiesInSwing.add(e.id);
        if (e.kind == EnemyKind.chronoSentinel && e.stunTimer <= 0 && e.facing != _facing && !_isPlungeAttack) {
          _shake = 6.0;
          _playerVel = Offset(-_facing * 260.0, -120);
          _spawnParticles(e.pos, const Color(0xFFD4AF37), 12);
          continue;
        }
        _applyDamageToEnemy(e, _swordDamage);
        if (_isPlungeAttack) {
          _playerVel = Offset(_playerVel.dx, -560);
          _jumpsLeft = 2;
          _isPlungeAttack = false;
        }
      }
    }
  }

  void _applyDamageToEnemy(EnemyUnit e, int dmg) {
    int finalDmg = dmg;
    if (e.kind == EnemyKind.archonVaelenBoss && _era == EraState.past) {
      finalDmg = (dmg * 1.5).round();
    }
    e.hp -= finalDmg;
    e.flashTimer = 0.15;
    _shake = 9.0;
    _energy = min(_maxEnergy, _energy + 10);
    if (_elementalCore == ElementalCore.solarFire) {
      e.burnTimer = 3.0;
      _spawnParticles(e.pos, const Color(0xFFFF6D00), 14);
    } else if (_elementalCore == ElementalCore.frostSlow) {
      e.slowTimer = 3.5;
      _spawnParticles(e.pos, const Color(0xFF00E5FF), 14);
    } else if (_elementalCore == ElementalCore.stormChain) {
      _spawnParticles(e.pos, const Color(0xFFFFEA00), 16);
      for (final other in _enemies) {
        if (other.id != e.id && (other.pos - e.pos).distance < 220) {
          other.hp -= max(1, finalDmg ~/ 2);
          other.flashTimer = 0.12;
        }
      }
    } else if (_elementalCore == ElementalCore.voidLeech) {
      if (_rng.nextDouble() < 0.35 && _hp < _maxHp) _hp++;
      _spawnParticles(e.pos, const Color(0xFFD500F9), 14);
    } else {
      _spawnParticles(e.pos, Colors.white, 12);
    }
  }

  void _updateBombsAndProjectiles(double dt) {
    for (int i = _bombs.length - 1; i >= 0; i--) {
      final b = _bombs[i];
      b.fuse -= dt;
      b.vel = Offset(b.vel.dx * 0.98, b.vel.dy + 1100 * dt);
      b.pos += b.vel * dt;
      if (b.pos.dy > groundY - 12) {
        b.pos = Offset(b.pos.dx, groundY - 12);
        b.vel = Offset(b.vel.dx * 0.6, -b.vel.dy * 0.45);
      }
      if (b.fuse <= 0) {
        _shake = 15.0;
        _spawnParticles(b.pos, const Color(0xFFFF9100), 34, speed: 340);
        final Rect blast = Rect.fromCircle(center: b.pos, radius: 135);
        for (final bw in _breakableWalls) {
          if (!bw.destroyed && blast.overlaps(bw.rect)) {
            bw.destroyed = true;
            _spawnParticles(bw.rect.center, const Color(0xFF94A3B8), 28);
          }
        }
        for (final e in _enemies) {
          if (blast.overlaps(e.bounds)) {
            e.stunTimer = 2.0;
            _applyDamageToEnemy(e, 6 + _astralLvl * 2);
          }
        }
        _bombs.removeAt(i);
      }
    }

    final Rect playerRect = Rect.fromCenter(center: _playerPos, width: _playerSize.width, height: _playerSize.height);
    for (int i = _projectiles.length - 1; i >= 0; i--) {
      final pr = _projectiles[i];
      pr.life -= dt;
      pr.pos += pr.vel * dt;
      if (!pr.fromPlayer) {
        if (_parryTimer > 0 && (pr.pos - _playerPos).distance < 62) {
          pr.fromPlayer = true;
          pr.isDeflected = true;
          pr.vel = -pr.vel * 2.2;
          pr.color = const Color(0xFFD4AF37);
          pr.damage = 8 + _mightLvl * 2;
          _shake = 12.0;
          _spawnParticles(pr.pos, const Color(0xFFD4AF37), 22, speed: 240);
          continue;
        }
        if (playerRect.overlaps(Rect.fromCircle(center: pr.pos, radius: pr.radius))) {
          _damagePlayer(pr.damage, pr.pos);
          _projectiles.removeAt(i);
          continue;
        }
      } else {
        for (final e in _enemies) {
          if (e.bounds.overlaps(Rect.fromCircle(center: pr.pos, radius: pr.radius))) {
            _applyDamageToEnemy(e, pr.damage);
            pr.life = 0;
            break;
          }
        }
      }
      if (pr.life <= 0) _projectiles.removeAt(i);
    }
  }

  void _updateEnemies(double dt) {
    final Rect playerRect = Rect.fromCenter(
        center: _playerPos, width: _playerSize.width * 0.8, height: _playerSize.height * 0.85);
    for (int i = _enemies.length - 1; i >= 0; i--) {
      final e = _enemies[i];
      if (e.flashTimer > 0) e.flashTimer -= dt;
      if (e.stunTimer > 0) e.stunTimer -= dt;
      if (e.slowTimer > 0) e.slowTimer -= dt;
      if (e.burnTimer > 0) {
        e.burnTimer -= dt;
        if (_rng.nextDouble() < 0.08) e.hp -= 1;
      }
      if (e.hp <= 0) {
        _shake = (e.kind == EnemyKind.automatonBoss || e.kind == EnemyKind.archonVaelenBoss) ? 24.0 : 10.0;
        _spawnParticles(e.pos, const Color(0xFFFF8F00), 32, speed: 300);
        _gainXpAndLoot(e);
        if (e.kind == EnemyKind.automatonBoss) _wardenDefeated = true;
        if (e.kind == EnemyKind.archonVaelenBoss) {
          _vaelenDefeated = true;
          _loadZone(5, spawnX: _playerPos.dx);
          return;
        }
        _enemies.removeAt(i);
        continue;
      }
      if (e.stunTimer > 0) continue;
      final double speedMult = e.slowTimer > 0 ? 0.45 : 1.0;
      e.aiTimer += dt * speedMult;

      switch (e.kind) {
        case EnemyKind.ashStalker:
        case EnemyKind.chronoSentinel:
          final double spd = (e.kind == EnemyKind.ashStalker ? 105.0 : 75.0) * speedMult;
          e.pos = Offset(e.pos.dx + e.facing * spd * dt, e.pos.dy);
          if (e.pos.dx <= e.minX) e.facing = 1;
          if (e.pos.dx >= e.maxX) e.facing = -1;
          break;
        case EnemyKind.astralWeaver:
          e.facing = _playerPos.dx >= e.pos.dx ? 1 : -1;
          if (e.aiTimer >= 2.1 && (_playerPos - e.pos).distance < 680) {
            e.aiTimer = 0;
            final Offset dir = (_playerPos - e.pos) / max(1.0, (_playerPos - e.pos).distance);
            _projectiles.add(ProjectileEntity(
              pos: e.pos + const Offset(0, -10),
              vel: dir * 320.0,
              radius: 11,
              fromPlayer: false,
              color: const Color(0xFFFF5252),
            ));
          }
          break;
        case EnemyKind.wingedDrake:
          e.pos = Offset(
            e.pos.dx + e.facing * 125.0 * speedMult * dt,
            e.pos.dy + sin(e.aiTimer * 3.5) * 65.0 * dt,
          );
          if (e.pos.dx <= e.minX) e.facing = 1;
          if (e.pos.dx >= e.maxX) e.facing = -1;
          break;
        case EnemyKind.automatonBoss:
        case EnemyKind.archonVaelenBoss:
          e.facing = _playerPos.dx >= e.pos.dx ? 1 : -1;
          e.pos = Offset((e.pos.dx + e.facing * 95.0 * speedMult * dt).clamp(e.minX, e.maxX), e.pos.dy);
          if (e.aiTimer >= 1.75 && (_playerPos - e.pos).distance < 850) {
            e.aiTimer = 0;
            final Offset dir = (_playerPos - e.pos) / max(1.0, (_playerPos - e.pos).distance);
            for (int s = -1; s <= 1; s++) {
              final double angle = atan2(dir.dy, dir.dx) + s * 0.18;
              _projectiles.add(ProjectileEntity(
                pos: e.pos + Offset(e.facing * 30.0, -18),
                vel: Offset(cos(angle) * 370.0, sin(angle) * 370.0),
                radius: 13,
                fromPlayer: false,
                color: e.kind == EnemyKind.archonVaelenBoss ? const Color(0xFFFFD740) : const Color(0xFFFF6E40),
              ));
            }
          }
          break;
      }

      if (_invulnTimer <= 0 && _dashTimer <= 0 && playerRect.overlaps(e.bounds)) {
        if (_parryTimer > 0) {
          e.stunTimer = 1.8;
          _shake = 10.0;
          _spawnParticles(e.pos, const Color(0xFFD4AF37), 18);
        } else {
          _damagePlayer(1, e.pos);
        }
      }
    }
  }

  void _gainXpAndLoot(EnemyUnit e) {
    final bool isBoss = e.kind == EnemyKind.automatonBoss || e.kind == EnemyKind.archonVaelenBoss;
    _xp += isBoss ? 120 : 30;
    while (_xp >= _xpToNext) {
      _xp -= _xpToNext;
      _level++;
      _skillPoints++;
      _xpToNext = (_xpToNext * 1.35).round();
      _hp = _maxHp;
      _spawnParticles(_playerPos, const Color(0xFFD4AF37), 30, speed: 260);
    }
    _dropLoot(e.pos, count: isBoss ? 12 : 3);
  }

  void _dropLoot(Offset origin, {required int count}) {
    for (int i = 0; i < count; i++) {
      _lootOrbs.add(LootOrb(
        pos: origin,
        vel: Offset((_rng.nextDouble() - 0.5) * 260, -180 - _rng.nextDouble() * 200),
        oreValue: 3 + _rng.nextInt(4),
        isHealth: i == 0 && _rng.nextDouble() < 0.35,
      ));
    }
  }

  void _updateLootAndParticles(double dt) {
    for (int i = _lootOrbs.length - 1; i >= 0; i--) {
      final orb = _lootOrbs[i];
      orb.life -= dt;
      orb.vel = Offset(orb.vel.dx * 0.95, orb.vel.dy + 980 * dt);
      orb.pos += orb.vel * dt;
      if (orb.pos.dy > groundY - 10) {
        orb.pos = Offset(orb.pos.dx, groundY - 10);
        orb.vel = Offset(orb.vel.dx * 0.7, -orb.vel.dy * 0.4);
      }
      if ((orb.pos - _playerPos).distance < 48) {
        if (orb.isHealth) {
          _hp = min(_maxHp, _hp + 1);
        } else {
          _starlightOre += orb.oreValue;
        }
        _spawnParticles(orb.pos, const Color(0xFFD4AF37), 6);
        _lootOrbs.removeAt(i);
        continue;
      }
      if (orb.life <= 0) _lootOrbs.removeAt(i);
    }
    for (int i = _particles.length - 1; i >= 0; i--) {
      final pt = _particles[i];
      pt.life -= dt;
      if (pt.gravity) pt.vel = Offset(pt.vel.dx * 0.96, pt.vel.dy + 650 * dt);
      pt.pos += pt.vel * dt;
      if (pt.life <= 0) _particles.removeAt(i);
    }
  }

  void _damagePlayer(int dmg, Offset src) {
    if (_invulnTimer > 0) return;
    _hp = max(0, _hp - dmg);
    _invulnTimer = 1.25;
    _shake = 15.0;
    final double dir = _playerPos.dx >= src.dx ? 1.0 : -1.0;
    _playerVel = Offset(dir * 300, -340);
    _spawnParticles(_playerPos, const Color(0xFFEF4444), 20);
    if (_hp <= 0) {
      _hp = _maxHp;
      _loadZone(_currentZoneIdx, spawnX: kZones[_currentZoneIdx].beaconPos.dx);
    }
  }

  void _spawnParticles(Offset pos, Color color, int count, {double speed = 190}) {
    for (int i = 0; i < count; i++) {
      final double a = _rng.nextDouble() * pi * 2;
      final double s = 40 + _rng.nextDouble() * speed;
      _particles.add(VisualParticle(
        pos: pos,
        vel: Offset(cos(a) * s, sin(a) * s - 40),
        color: color,
        size: 2.5 + _rng.nextDouble() * 4.5,
        life: 0.25 + _rng.nextDouble() * 0.35,
      ));
    }
  }

  // ================================================================
  // INTERACTION
  // ================================================================
  NpcEntity? get _nearbyNpc {
    for (final n in _npcs) {
      if ((n.pos - _playerPos).distance < 95) return n;
    }
    return null;
  }

  TreasureChest? get _nearbyChest {
    for (final c in _chests) {
      if (c.onlyInPast && _era != EraState.past) continue;
      if (!c.opened && !_openedChestIds.contains(c.id) && (c.pos - _playerPos).distance < 80) {
        return c;
      }
    }
    return null;
  }

  bool get _nearBeacon => (kZones[_currentZoneIdx].beaconPos - _playerPos).distance < 90;

  void _handleContextInteract() {
    if (_showRpgModal) return;
    final npc = _nearbyNpc;
    if (npc != null) {
      _startDialogue(npc.lines, openForgeAfter: npc.opensForge);
      return;
    }
    final chest = _nearbyChest;
    if (chest != null) {
      setState(() {
        chest.opened = true;
        _openedChestIds.add(chest.id);
        _starlightOre += chest.oreReward;
      });
      _shake = 8.0;
      _spawnParticles(chest.pos, const Color(0xFFD4AF37), 28, speed: 250);
      return;
    }
    if (_nearBeacon) {
      setState(() {
        _hp = _maxHp;
        _energy = _maxEnergy;
        _rpgTabIndex = 2;
        _showRpgModal = true;
      });
    }
  }

  void _startDialogue(List<DialogueLine> lines, {bool openForgeAfter = false}) {
    setState(() {
      _activeDialogueList = lines;
      _dialogueIndex = 0;
      _openForgeAfterDialogue = openForgeAfter;
    });
  }

  void _advanceDialogue() {
    if (_activeDialogueList == null) return;
    if (_dialogueIndex + 1 < _activeDialogueList!.length) {
      setState(() => _dialogueIndex++);
    } else {
      setState(() {
        _activeDialogueList = null;
        if (_openForgeAfterDialogue) {
          _openForgeAfterDialogue = false;
          _showRpgModal = true;
        }
      });
    }
  }

  // ================================================================
  // BUILD
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final bool isAr = widget.lang == GameLang.ar;
    final ZoneData zone = kZones[_currentZoneIdx];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Size screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          final double targetCamX =
              (_playerPos.dx - screenSize.width * 0.42).clamp(0.0, max(0.0, zone.width - screenSize.width));
          final double targetCamY = (_playerPos.dy - screenSize.height * 0.60).clamp(-140.0, 90.0);
          final Offset shakeOffset = _shake > 0
              ? Offset((_rng.nextDouble() - 0.5) * _shake * 1.8, (_rng.nextDouble() - 0.5) * _shake * 1.8)
              : Offset.zero;
          _camera = Offset(
                _camera.dx + (targetCamX - _camera.dx) * 0.16,
                _camera.dy + (targetCamY - _camera.dy) * 0.16,
              ) +
              shakeOffset;

          final bool canInteract = _nearbyNpc != null || _nearbyChest != null || _nearBeacon;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: SolthariaWorld25DPainter(
                    camera: _camera,
                    worldTime: _worldTime,
                    zone: zone,
                    era: _era,
                    eraWaveRadius: _eraWaveRadius,
                    playerPos: _playerPos,
                    playerSize: _playerSize,
                    facing: _facing,
                    walkCycle: _walkCycle,
                    scarfNodes: _scarfNodes,
                    weaponTier: _weaponTier,
                    slashTimer: _slashTimer,
                    comboStep: _comboStep,
                    isPlunge: _isPlungeAttack,
                    parryTimer: _parryTimer,
                    invulnTimer: _invulnTimer,
                    activeGrapple: _activeGrappleTarget,
                    platforms: _platforms,
                    breakableWalls: _breakableWalls,
                    pushBlocks: _pushBlocks,
                    plates: _plates,
                    gates: _gates,
                    grappleRings: _grappleRings,
                    chests: _chests,
                    openedChestIds: _openedChestIds,
                    crystals: _crystals,
                    npcs: _npcs,
                    enemies: _enemies,
                    projectiles: _projectiles,
                    bombs: _bombs,
                    lootOrbs: _lootOrbs,
                    particles: _particles,
                  ),
                ),
              ),
              Positioned(top: 10, left: 10, right: 10, child: _buildTopHud(isAr, zone)),
              if (_zoneBannerTimer > 0)
                Positioned(
                  top: 82,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xCC060A14),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFD4AF37)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isAr ? zone.titleAr : zone.titleEn,
                                style: const TextStyle(
                                    color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(isAr ? zone.subAr : zone.subEn,
                                style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(left: 14, bottom: 14, child: _buildLeftDpad()),
              Positioned(right: 14, bottom: 14, child: _buildRightActionCluster(isAr, canInteract)),
              if (_activeDialogueList != null) _buildDialogueOverlay(isAr),
              if (_showRpgModal) _buildRpgModal(isAr),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopHud(bool isAr, ZoneData zone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xD9070B16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onExitToMenu,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back, color: Color(0xB3FFFFFF), size: 20),
            ),
          ),
          const SizedBox(width: 6),
          Row(
            children: List.generate(_maxHp, (i) {
              final bool full = i < _hp;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 11,
                height: 16,
                decoration: BoxDecoration(
                  color: full ? const Color(0xFFEF4444) : const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                ),
              );
            }),
          ),
          const SizedBox(width: 6),
          Container(
            width: 54,
            height: 8,
            decoration: BoxDecoration(color: const Color(0x22FFFFFF), borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (_energy / _maxEnergy).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFF38BDF8), borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('Lv.$_level',
              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(width: 6),
          const Icon(Icons.star, color: Color(0xFFD4AF37), size: 13),
          Text('$_starlightOre',
              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11)),
          const Spacer(),
          InkWell(
            onTap: () {
              setState(() {
                _activeSkill = AstralSkill.values[(_activeSkill.index + 1) % AstralSkill.values.length];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF38BDF8)),
              ),
              child: Text(_skillLabel(isAr, _activeSkill),
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              _activeSkill = AstralSkill.timeFold;
              _triggerActiveSkill();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _era == EraState.past ? const Color(0xFFD4AF37) : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _era == EraState.past ? (isAr ? 'الماضي' : 'Past') : (isAr ? 'الحاضر' : 'Present'),
                style: TextStyle(
                  color: _era == EraState.past ? Colors.black : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => setState(() => _showRpgModal = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: const Icon(Icons.map, color: Color(0xFFD4AF37), size: 14),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onToggleLang,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.language, color: Color(0xB3FFFFFF), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _skillLabel(bool isAr, AstralSkill sk) {
    switch (sk) {
      case AstralSkill.starBolt:
        return isAr ? '⚡ نجوم' : '⚡ Star';
      case AstralSkill.chronoBomb:
        return isAr ? '💣 قنبلة' : '💣 Bomb';
      case AstralSkill.tetherHook:
        return isAr ? '🪝 خطاف' : '🪝 Hook';
      case AstralSkill.timeFold:
        return isAr ? '⏳ طيّ' : '⏳ Fold';
    }
  }

  Widget _buildLeftDpad() {
    return SizedBox(
      width: 152,
      height: 108,
      child: Stack(
        children: [
          Positioned(left: 0, bottom: 12, child: _holdPadBtn(Icons.arrow_back, _moveLeft, (v) {
            setState(() => _moveLeft = v);
          })),
          Positioned(right: 0, bottom: 12, child: _holdPadBtn(Icons.arrow_forward, _moveRight, (v) {
            setState(() => _moveRight = v);
          })),
          Positioned(left: 50, bottom: 0, child: _holdPadBtn(Icons.keyboard_arrow_down, _aimDown, (v) {
            setState(() => _aimDown = v);
          }, size: 46)),
        ],
      ),
    );
  }

  Widget _holdPadBtn(IconData icon, bool active, ValueChanged<bool> onChanged, {double size = 54}) {
    return Listener(
      onPointerDown: (_) => onChanged(true),
      onPointerUp: (_) => onChanged(false),
      onPointerCancel: (_) => onChanged(false),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active ? const Color(0x40FFFFFF) : const Color(0x8C000000),
          shape: BoxShape.circle,
          border: Border.all(color: active ? const Color(0xFFD4AF37) : const Color(0x4DFFFFFF), width: 1.8),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.55),
      ),
    );
  }

  Widget _buildRightActionCluster(bool isAr, bool canInteract) {
    return SizedBox(
      width: 210,
      height: 145,
      child: Stack(
        children: [
          if (canInteract)
            Positioned(
              left: 20,
              top: 0,
              child: GestureDetector(
                onTap: _handleContextInteract,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Color(0x88D4AF37), blurRadius: 12)],
                  ),
                  child: Text(isAr ? 'تفاعل' : 'INTERACT',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ),
            ),
          Positioned(
            left: 10,
            bottom: 22,
            child: _circleActionBtn(
              isAr ? 'سيف' : 'BLADE',
              const Color(0xFFE2E8F0),
              _triggerSwordAttack,
            ),
          ),
          Positioned(
            right: 66,
            bottom: 0,
            child: Listener(
              onPointerDown: (_) {
                _jumpHeld = true;
                _triggerJump();
              },
              onPointerUp: (_) => setState(() => _jumpHeld = false),
              onPointerCancel: (_) => setState(() => _jumpHeld = false),
              child: _circleActionVisual(isAr ? 'قفز' : 'JUMP', const Color(0xFFD4AF37)),
            ),
          ),
          Positioned(
            left: 72,
            top: 6,
            child: _circleActionBtn(isAr ? 'مهارة' : 'SKILL', const Color(0xFF38BDF8), _triggerActiveSkill),
          ),
          Positioned(
            right: 0,
            bottom: 44,
            child: _circleActionBtn(isAr ? 'صد' : 'PARRY', const Color(0xFFFFB300), _triggerParryOrDash),
          ),
        ],
      ),
    );
  }

  Widget _circleActionBtn(String title, Color color, VoidCallback onTap) {
    return Listener(
      onPointerDown: (_) => onTap(),
      child: _circleActionVisual(title, color),
    );
  }

  Widget _circleActionVisual(String title, Color color) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xB3070B16),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8)],
      ),
      child: Center(
        child: Text(title,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
      ),
    );
  }

  // ================================================================
  // DIALOGUE OVERLAY
  // ================================================================
  Widget _buildDialogueOverlay(bool isAr) {
    final DialogueLine line = _activeDialogueList![_dialogueIndex];
    return Positioned(
      bottom: 26,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: _advanceDialogue,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xF2080D1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            boxShadow: const [BoxShadow(color: Color(0xCC000000), blurRadius: 20)],
          ),
          child: Row(
            children: [
              SizedBox(width: 66, height: 66, child: CustomPaint(painter: CharacterPortraitPainter(kind: line.speaker))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isAr ? line.speakerAr : line.speakerEn,
                        style: const TextStyle(
                            color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(isAr ? line.textAr : line.textEn,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 5),
                    Text(isAr ? 'اضغط للمتابعة ▸' : 'TAP TO CONTINUE ▸',
                        style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // RPG SANCTUARY MODAL
  // ================================================================
  Widget _buildRpgModal(bool isAr) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xE604080F),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield, color: Color(0xFFD4AF37), size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr ? 'ملاذ الرماد — الحدادة والمهارات والخريطة' : 'Cinderhaven — Forge, Skills & Map',
                        style: const TextStyle(
                            color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Text('Lv.$_level',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 10),
                    Text('✦$_starlightOre',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFFFFFFF)),
                      onPressed: () => setState(() => _showRpgModal = false),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  children: [
                    _tabBtn(isAr ? 'الحدادة' : 'Forge', 0),
                    const SizedBox(width: 6),
                    _tabBtn(isAr ? 'المهارات' : 'Skills', 1),
                    const SizedBox(width: 6),
                    _tabBtn(isAr ? 'الخريطة' : 'Map', 2),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: _rpgTabIndex == 0
                      ? _buildForgeTab(isAr)
                      : _rpgTabIndex == 1
                          ? _buildSkillsTab(isAr)
                          : _buildMapTab(isAr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final bool sel = _rpgTabIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _rpgTabIndex = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFFD4AF37) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: sel ? Colors.black : const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgeTab(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _forgeCard(
          isAr ? 'تطوير السلاح' : 'Weapon Evolution',
          _weaponTierLabel(isAr),
          isAr ? 'السيف الحالي: ${_weaponTierLabel(isAr)}' : 'Current: ${_weaponTierLabel(isAr)}',
          _nextWeaponCost(),
          _weaponTier != WeaponTier.chronosSunCleaver
              ? () {
                  if (_starlightOre >= _nextWeaponCost()) {
                    setState(() {
                      _starlightOre -= _nextWeaponCost();
                      _weaponTier = WeaponTier.values[_weaponTier.index + 1];
                    });
                  }
                }
              : null,
          isAr ? 'ترقية' : 'UPGRADE',
        ),
        const SizedBox(height: 10),
        _forgeCard(
          isAr ? 'النوى العنصرية' : 'Elemental Cores',
          _coreLabel(isAr, _elementalCore),
          isAr ? 'اختر نواة لدمج تأثيرها مع سيفك' : 'Pick a core to fuse with your blade',
          30,
          () {
            if (_starlightOre >= 30) {
              setState(() {
                _starlightOre -= 30;
                _elementalCore = ElementalCore.values[(_elementalCore.index + 1) % ElementalCore.values.length];
              });
            }
          },
          isAr ? 'نواة تالية (30)' : 'NEXT CORE (30)',
        ),
      ],
    );
  }

  String _weaponTierLabel(bool isAr) {
    switch (_weaponTier) {
      case WeaponTier.rustyBlade:
        return isAr ? 'السيف الصدئ' : 'Rusty Greatsword';
      case WeaponTier.starlightEdge:
        return isAr ? 'حد النجوم' : 'Starlight Edge';
      case WeaponTier.chronosSunCleaver:
        return isAr ? 'شمس الكرونوس' : 'Chronos Sun-Cleaver';
    }
  }

  int _nextWeaponCost() {
    switch (_weaponTier) {
      case WeaponTier.rustyBlade:
        return 40;
      case WeaponTier.starlightEdge:
        return 80;
      case WeaponTier.chronosSunCleaver:
        return 0;
    }
  }

  String _coreLabel(bool isAr, ElementalCore c) {
    switch (c) {
      case ElementalCore.none:
        return isAr ? 'بدون نواة' : 'No Core';
      case ElementalCore.solarFire:
        return isAr ? 'النار الشمسية' : 'Solar Fire';
      case ElementalCore.frostSlow:
        return isAr ? 'الصقيع' : 'Frost Slow';
      case ElementalCore.stormChain:
        return isAr ? 'البرق المتسلسل' : 'Storm Chain';
      case ElementalCore.voidLeech:
        return isAr ? 'امتصاص الفراغ' : 'Void Leech';
    }
  }

  Widget _forgeCard(String title, String current, String desc, int cost, VoidCallback? onTap, String button) {
    final bool canAfford = onTap != null && _starlightOre >= cost;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x88D4AF37)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upgrade, color: Color(0xFFD4AF37), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(current, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(desc, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11.5)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: canAfford ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: canAfford ? const Color(0xFFD4AF37) : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(button,
                    style: TextStyle(
                      color: canAfford ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1628),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x88D4AF37)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'نقاط المهارات المتاحة: $_skillPoints' : 'Available Skill Points: $_skillPoints',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _statCard(
          isAr ? 'الحيوية — Vitality' : 'Vitality',
          'Lv.$_vitalityLvl',
          isAr ? 'زيادة الحد الأقصى للصحة' : 'Increase Max Health',
          () {
            if (_skillPoints > 0) {
              setState(() {
                _skillPoints--;
                _vitalityLvl++;
                _hp = _maxHp;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        _statCard(
          isAr ? 'القوة — Might' : 'Might',
          'Lv.$_mightLvl',
          isAr ? 'زيادة ضرر السيف والكومبو' : 'Increase Sword & Combo Damage',
          () {
            if (_skillPoints > 0) {
              setState(() {
                _skillPoints--;
                _mightLvl++;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        _statCard(
          isAr ? 'القوة النجمية — Astral' : 'Astral Power',
          'Lv.$_astralLvl',
          isAr ? 'زيادة الطاقة القصوى وضرر المهارات' : 'Increase Max Energy & Skill Damage',
          () {
            if (_skillPoints > 0) {
              setState(() {
                _skillPoints--;
                _astralLvl++;
                _energy = _maxEnergy;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _statCard(String title, String level, String desc, VoidCallback onUpgrade) {
    final bool canUp = _skillPoints > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x88D4AF37)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
                Text(level,
                    style: const TextStyle(
                        color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
                Text(desc, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: canUp ? onUpgrade : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: canUp ? const Color(0xFFD4AF37) : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('+1',
                  style: TextStyle(
                      color: canUp ? Colors.black : Colors.white70, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: kZones.map((z) {
        final bool unlocked = z.index <= _maxZoneReached;
        final bool current = z.index == _currentZoneIdx;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: current ? const Color(0x33D4AF37) : const Color(0xFF0E1628),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: current ? const Color(0xFFD4AF37) : const Color(0x55D4AF37)),
          ),
          child: Row(
            children: [
              Icon(
                unlocked ? Icons.star : Icons.star_border,
                color: unlocked ? const Color(0xFFD4AF37) : const Color(0x44FFFFFF),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? z.titleAr : z.titleEn,
                      style: TextStyle(
                        color: unlocked ? const Color(0xFFD4AF37) : const Color(0x55FFFFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      isAr ? z.subAr : z.subEn,
                      style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (unlocked && !current)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _loadZone(z.index, spawnX: z.beaconPos.dx);
                      _showRpgModal = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(isAr ? 'انتقال' : 'TRAVEL',
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ================================================================
// WORLD PAINTER — 2.5D RENDERING
// ================================================================
class SolthariaWorld25DPainter extends CustomPainter {
  final Offset camera;
  final double worldTime;
  final ZoneData zone;
  final EraState era;
  final double eraWaveRadius;
  final Offset playerPos;
  final Size playerSize;
  final int facing;
  final double walkCycle;
  final List<Offset> scarfNodes;
  final WeaponTier weaponTier;
  final double slashTimer;
  final int comboStep;
  final bool isPlunge;
  final double parryTimer;
  final double invulnTimer;
  final Offset? activeGrapple;
  final List<Platform25D> platforms;
  final List<BreakableWall> breakableWalls;
  final List<PushBlock> pushBlocks;
  final List<PressurePlate> plates;
  final List<GateDoor> gates;
  final List<GrappleRing> grappleRings;
  final List<TreasureChest> chests;
  final Set<String> openedChestIds;
  final List<BreakableCrystal> crystals;
  final List<NpcEntity> npcs;
  final List<EnemyUnit> enemies;
  final List<ProjectileEntity> projectiles;
  final List<BombEntity> bombs;
  final List<LootOrb> lootOrbs;
  final List<VisualParticle> particles;

  SolthariaWorld25DPainter({
    required this.camera,
    required this.worldTime,
    required this.zone,
    required this.era,
    required this.eraWaveRadius,
    required this.playerPos,
    required this.playerSize,
    required this.facing,
    required this.walkCycle,
    required this.scarfNodes,
    required this.weaponTier,
    required this.slashTimer,
    required this.comboStep,
    required this.isPlunge,
    required this.parryTimer,
    required this.invulnTimer,
    required this.activeGrapple,
    required this.platforms,
    required this.breakableWalls,
    required this.pushBlocks,
    required this.plates,
    required this.gates,
    required this.grappleRings,
    required this.chests,
    required this.openedChestIds,
    required this.crystals,
    required this.npcs,
    required this.enemies,
    required this.projectiles,
    required this.bombs,
    required this.lootOrbs,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawParallax(canvas, size);
    canvas.save();
    canvas.translate(-camera.dx, -camera.dy);
    _drawPlatforms(canvas);
    _drawBreakableWalls(canvas);
    _drawPushBlocksAndPlates(canvas);
    _drawGates(canvas);
    _drawGrappleRings(canvas);
    _drawChests(canvas);
    _drawCrystals(canvas);
    _drawNpcs(canvas);
    _drawEnemies(canvas);
    _drawProjectilesAndBombs(canvas);
    _drawLootOrbs(canvas);
    _drawPlayer(canvas);
    _drawParticles(canvas);
    if (activeGrapple != null) _drawGrappleChain(canvas);
    canvas.restore();
    _drawEraWave(canvas, size);
    _drawVignette(canvas, size);
  }

  Color _skyColor(double t) {
    if (era == EraState.past) {
      return Color.lerp(const Color(0xFF0F1833), const Color(0xFF2A4570), t)!;
    }
    return Color.lerp(const Color(0xFF1A0F0F), const Color(0xFF2D1815), t)!;
  }

  void _drawSky(Canvas canvas, Size size) {
    final Rect screen = Offset.zero & size;
    final Paint sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _skyColor(0.0),
          _skyColor(0.5),
          era == EraState.past ? const Color(0xFF0F1D33) : const Color(0xFF0A0709),
        ],
      ).createShader(screen);
    canvas.drawRect(screen, sky);

    final Offset sunCenter = Offset(size.width * 0.75, size.height * 0.22);
    final Color sunColor = era == EraState.past ? const Color(0xFFD4AF37) : const Color(0xFFFF6B4A);
    canvas.drawCircle(
      sunCenter,
      90,
      Paint()
        ..color = sunColor.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
    for (int i = 0; i < 3; i++) {
      final double r = 55.0 + i * 22.0 + sin(worldTime + i) * 4;
      canvas.drawCircle(
        sunCenter,
        r,
        Paint()
          ..color = sunColor.withOpacity(0.55 - i * 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawParallax(Canvas canvas, Size size) {
    final Random rng = Random(42);
    final Paint starPaint = Paint()..color = const Color(0x99FFFFFF);
    for (int i = 0; i < 40; i++) {
      final double sx = (rng.nextDouble() * size.width * 2 - camera.dx * 0.05) % (size.width * 2);
      final double sy = rng.nextDouble() * size.height * 0.55;
      final double twinkle = 0.4 + 0.6 * (0.5 + 0.5 * sin(worldTime * 2 + i));
      canvas.drawCircle(Offset(sx, sy), 1.2 + rng.nextDouble() * 1.2,
          starPaint..color = Color.fromARGB((twinkle * 200).round(), 255, 255, 255));
    }

    final double cf = -camera.dx * 0.18;
    final Paint citadelPaint = Paint()
      ..color = era == EraState.past ? const Color(0x55335588) : const Color(0x44202A38);
    for (int i = 0; i < 5; i++) {
      final double cx = (i * 320.0 + cf + 200) % (size.width + 400) - 200;
      final Path p = Path()
        ..moveTo(cx, size.height * 0.62)
        ..lineTo(cx + 40, size.height * 0.40)
        ..lineTo(cx + 70, size.height * 0.48)
        ..lineTo(cx + 110, size.height * 0.30)
        ..lineTo(cx + 150, size.height * 0.48)
        ..lineTo(cx + 180, size.height * 0.40)
        ..lineTo(cx + 220, size.height * 0.62)
        ..close();
      canvas.drawPath(p, citadelPaint);
    }

    final double rf = -camera.dx * 0.35;
    final Paint ruinPaint = Paint()
      ..color = era == EraState.past ? const Color(0x77436699) : const Color(0x663A2A24);
    for (int i = 0; i < 6; i++) {
      final double rx = (i * 420.0 + rf + 100) % (size.width + 500) - 200;
      canvas.drawRect(Rect.fromLTWH(rx, size.height * 0.66, 70, size.height * 0.34), ruinPaint);
      canvas.drawRect(Rect.fromLTWH(rx + 90, size.height * 0.72, 50, size.height * 0.28), ruinPaint);
      final Path arch = Path()
        ..moveTo(rx + 20, size.height * 0.66)
        ..lineTo(rx + 20, size.height * 0.55)
        ..quadraticBezierTo(rx + 55, size.height * 0.45, rx + 90, size.height * 0.55)
        ..lineTo(rx + 90, size.height * 0.66)
        ..close();
      canvas.drawPath(arch, ruinPaint);
    }

    final Paint mistPaint = Paint()
      ..color = era == EraState.past ? const Color(0x22FFE082) : const Color(0x22FF8A65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (int i = 0; i < 15; i++) {
      final double mx = ((i * 137.0 + worldTime * 40) % (size.width + 200)) - 100;
      final double my = ((i * 71.0 + worldTime * 20) % (size.height + 100)) - 50;
      canvas.drawCircle(Offset(mx, my), 30 + rng.nextDouble() * 40, mistPaint);
    }
  }

  void _drawPlatforms(Canvas canvas) {
    for (final p in platforms) {
      if (!p.isActiveIn(era)) continue;
      if (p.isHazard) {
        _drawSpikes(canvas, p.rect);
        continue;
      }
      _drawPlatform(canvas, p);
    }
  }

  void _drawPlatform(Canvas canvas, Platform25D p) {
    final Rect r = p.rect;
    final bool past = era == EraState.past;
    final Color top = past ? const Color(0xFFD4AF37) : const Color(0xFF4A3A2A);
    final Color body = past ? const Color(0xFFB08A1C) : const Color(0xFF2D221A);
    final Color shadow = past ? const Color(0xFF5A4416) : const Color(0xFF140E08);

    canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width, 5), Paint()..color = top);
    final double bevelH = min(r.height * 0.45, 42);
    canvas.drawRect(Rect.fromLTWH(r.left, r.top + 5, r.width, bevelH), Paint()..color = body);

    if (r.height > bevelH + 5) {
      canvas.drawRect(Rect.fromLTWH(r.left + 3, r.top + 5 + bevelH, r.width, r.height - bevelH - 5),
          Paint()..color = shadow);
    }

    final Paint rune = Paint()..color = past ? const Color(0xFFFFE082) : const Color(0xFFFF7A45);
    final int runeCount = (r.width / 90).round();
    for (int i = 0; i < runeCount; i++) {
      final double rx = r.left + 40 + i * 90.0;
      if (rx > r.right - 20) break;
      canvas.drawCircle(Offset(rx, r.top + bevelH * 0.55), 2.5, rune);
      canvas.drawCircle(Offset(rx, r.top + bevelH * 0.55), 5, rune..color = rune.color.withOpacity(0.25));
    }

    final Random crackRng = Random(r.left.toInt() ^ r.top.toInt());
    final Paint crackPaint = Paint()
      ..color = shadow.withOpacity(0.85)
      ..strokeWidth = 1.0;
    final int crackCount = (r.width / 140).round();
    for (int i = 0; i < crackCount; i++) {
      final double cx = r.left + crackRng.nextDouble() * r.width;
      final double cy = r.top + 8;
      final Path crack = Path()..moveTo(cx, cy);
      double cxx = cx, cyy = cy;
      for (int s = 0; s < 4; s++) {
        cxx += (crackRng.nextDouble() - 0.5) * 12;
        cyy += 4 + crackRng.nextDouble() * 5;
        crack.lineTo(cxx, cyy);
      }
      canvas.drawPath(crack, crackPaint);
    }

    if (p.hasGrass) {
      final Paint grassPaint = Paint()
        ..color = past ? const Color(0xFF6FA544) : const Color(0xFF4A5A32)
        ..style = PaintingStyle.fill;
      final int gCount = (r.width / 18).round();
      for (int i = 0; i < gCount; i++) {
        final double gx = r.left + 8 + i * 18.0;
        final double wave = sin(worldTime * 2 + gx * 0.05) * 3;
        final Path g = Path()
          ..moveTo(gx, r.top)
          ..lineTo(gx + wave - 2, r.top - 8)
          ..lineTo(gx + 3, r.top)
          ..close();
        canvas.drawPath(g, grassPaint);
      }
    }
  }

  void _drawSpikes(Canvas canvas, Rect r) {
    final Paint spikePaint = Paint()..color = const Color(0xFF9B1C1C);
    final int count = (r.width / 20).round();
    for (int i = 0; i < count; i++) {
      final double sx = r.left + i * 20.0;
      final Path sp = Path()
        ..moveTo(sx, r.top + r.height)
        ..lineTo(sx + 10, r.top)
        ..lineTo(sx + 20, r.top + r.height)
        ..close();
      canvas.drawPath(sp, spikePaint);
      canvas.drawCircle(Offset(sx + 10, r.top + 4), 2, Paint()..color = const Color(0xFFFF5252));
    }
  }

  void _drawBreakableWalls(Canvas canvas) {
    for (final bw in breakableWalls) {
      if (bw.destroyed) continue;
      final Rect r = bw.rect;
      canvas.drawRect(r, Paint()..color = const Color(0xFF3D2E22));
      final Paint crack = Paint()
        ..color = const Color(0xFF1A0F08)
        ..strokeWidth = 2;
      canvas.drawLine(r.topLeft + const Offset(8, 20), r.topLeft + const Offset(30, 60), crack);
      canvas.drawLine(r.topLeft + const Offset(30, 60), r.topLeft + const Offset(14, 100), crack);
      canvas.drawLine(r.topLeft + const Offset(20, 40), r.topLeft + const Offset(36, 80), crack);
      canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width, 3), Paint()..color = const Color(0xFF8B6E52));
    }
  }

  void _drawPushBlocksAndPlates(Canvas canvas) {
    for (final pl in plates) {
      final Rect r = pl.rect;
      canvas.drawRect(r, Paint()..color = pl.isPressed ? const Color(0xFFFFE082) : const Color(0xFF4A3826));
      canvas.drawRect(r, Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      if (pl.isPressed) {
        canvas.drawCircle(r.center, 5, Paint()..color = const Color(0xFFFFEB3B));
      }
    }
    for (final pb in pushBlocks) {
      final Rect r = pb.rect;
      canvas.drawRect(r, Paint()..color = const Color(0xFF5A4430));
      canvas.drawRect(Rect.fromLTWH(r.left + 4, r.top + 4, r.width - 8, r.height - 8),
          Paint()..color = const Color(0xFF3D2A1A));
      canvas.drawCircle(r.center, 6, Paint()..color = const Color(0xFFD4AF37));
      canvas.drawCircle(r.center, 3, Paint()..color = const Color(0xFFFFE082));
    }
  }

  void _drawGates(Canvas canvas) {
    for (final g in gates) {
      final Rect r = g.currentRect;
      canvas.drawRect(r, Paint()..color = const Color(0xFF3D3D3D));
      canvas.drawRect(r, Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      for (int i = 0; i < 4; i++) {
        final double gy = r.top + i * (r.height / 4) + 10;
        canvas.drawLine(Offset(r.left + 4, gy), Offset(r.right - 4, gy),
            Paint()..color = const Color(0xFF5A5A5A));
      }
    }
  }

  void _drawGrappleRings(Canvas canvas) {
    for (final gr in grappleRings) {
      final Offset c = gr.pos;
      final double glow = 0.6 + 0.4 * sin(worldTime * 3);
      canvas.drawCircle(c, 16, Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.25 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(c, 12, Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
      canvas.drawCircle(c, 4, Paint()..color = const Color(0xFFFFEB3B));
    }
  }

  void _drawChests(Canvas canvas) {
    for (final c in chests) {
      if (c.onlyInPast && era != EraState.past) continue;
      final bool opened = c.opened || openedChestIds.contains(c.id);
      final Rect r = Rect.fromCenter(center: c.pos, width: 44, height: 32);
      canvas.drawRect(r.translate(0, 4), Paint()..color = const Color(0xFF221509));
      canvas.drawRect(r, Paint()..color = opened ? const Color(0xFF5A4020) : const Color(0xFF8B6234));
      canvas.drawRect(r.translate(0, -6), Paint()..color = opened ? const Color(0xFF3A2810) : const Color(0xFFD4AF37));
      if (opened) {
        canvas.drawRect(Rect.fromLTWH(r.left, r.top + 8, r.width, 4),
            Paint()..color = const Color(0xFFFFE082));
      } else {
        canvas.drawCircle(Offset(r.center.dx, r.top - 6), 4, Paint()..color = const Color(0xFFFFEB3B));
        canvas.drawCircle(Offset(r.center.dx, r.top - 6), 8, Paint()
          ..color = const Color(0xFFFFEB3B).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      }
    }
  }

  void _drawCrystals(Canvas canvas) {
    for (final cr in crystals) {
      if (cr.broken) continue;
      final Offset c = cr.pos;
      final Path p = Path()
        ..moveTo(c.dx - 14, c.dy + 22)
        ..lineTo(c.dx - 8, c.dy - 8)
        ..lineTo(c.dx, c.dy - 22)
        ..lineTo(c.dx + 8, c.dy - 8)
        ..lineTo(c.dx + 14, c.dy + 22)
        ..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFF38BDF8));
      canvas.drawPath(p, Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2);
      canvas.drawCircle(c, 30, Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    }
  }

  void _drawNpcs(Canvas canvas) {
    for (final npc in npcs) {
      final Offset c = npc.pos;
      switch (npc.portrait) {
        case PortraitKind.kaelis:
          canvas.drawRect(Rect.fromCenter(center: c.translate(0, -30), width: 50, height: 70),
              Paint()..color = const Color(0xFF4A4A4A));
          canvas.drawRect(Rect.fromCenter(center: c.translate(0, -55), width: 40, height: 20),
              Paint()..color = const Color(0xFF8B4513));
          canvas.drawCircle(c.translate(0, -30), 8, Paint()..color = const Color(0xFFFF7A00));
          for (int i = 0; i < 4; i++) {
            final double a = -pi / 2 + i * pi / 2 + 0.4;
            canvas.drawLine(
              c.translate(0, -35),
              c.translate(cos(a) * 30, -35 + sin(a) * 30),
              Paint()
                ..color = const Color(0xFF3D3D3D)
                ..strokeWidth = 4,
            );
          }
          break;
        case PortraitKind.nyxia:
          final Path hood = Path()
            ..moveTo(c.dx, c.dy - 70)
            ..lineTo(c.dx + 26, c.dy)
            ..lineTo(c.dx - 26, c.dy)
            ..close();
          canvas.drawPath(hood, Paint()..color = const Color(0xFF5C2E8B));
          canvas.drawCircle(c.translate(0, -40), 14, Paint()..color = const Color(0xFFEAD1FF));
          break;
        case PortraitKind.lyra:
          canvas.drawRect(Rect.fromCenter(center: c.translate(0, -30), width: 26, height: 60),
              Paint()..color = const Color(0xFFF7E7C1));
          canvas.drawCircle(c.translate(0, -55), 12, Paint()..color = const Color(0xFFF7E7C1));
          canvas.drawCircle(c.translate(0, -55), 15, Paint()
            ..color = const Color(0xFFD4AF37).withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
          break;
        default:
          break;
      }
      canvas.drawCircle(c.translate(0, -40), 55, Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }
  }

  void _drawEnemies(Canvas canvas) {
    for (final e in enemies) {
      final Rect r = e.bounds;
      final bool flashing = e.flashTimer > 0;
      Color base;
      switch (e.kind) {
        case EnemyKind.ashStalker: base = const Color(0xFF7A3A20); break;
        case EnemyKind.chronoSentinel: base = const Color(0xFF3A6EA5); break;
        case EnemyKind.astralWeaver: base = const Color(0xFF8B3F9B); break;
        case EnemyKind.wingedDrake: base = const Color(0xFF9B1C1C); break;
        case EnemyKind.automatonBoss: base = const Color(0xFF5A3A1A); break;
        case EnemyKind.archonVaelenBoss: base = const Color(0xFFB8860B); break;
      }
      final Color fill = flashing ? Colors.white : base;
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.2)),
        Paint()..color = fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(r.left + 4, r.bottom - 4, r.width - 8, 4),
        Paint()..color = const Color(0x55000000),
      );
      final double eyeY = r.top + r.height * 0.32;
      final Color eyeCol = e.kind == EnemyKind.automatonBoss || e.kind == EnemyKind.archonVaelenBoss
          ? const Color(0xFFFFD54F)
          : const Color(0xFFFF5252);
      canvas.drawCircle(Offset(r.center.dx - r.width * 0.18, eyeY), 3, Paint()..color = eyeCol);
      canvas.drawCircle(Offset(r.center.dx + r.width * 0.18, eyeY), 3, Paint()..color = eyeCol);

      final double hpFrac = e.hp / e.maxHp;
      final Rect hpBg = Rect.fromLTWH(r.left, r.top - 10, r.width, 4);
      canvas.drawRect(hpBg, Paint()..color = const Color(0xCC000000));
      canvas.drawRect(
        Rect.fromLTWH(hpBg.left, hpBg.top, hpBg.width * hpFrac.clamp(0.0, 1.0), hpBg.height),
        Paint()..color = e.kind == EnemyKind.automatonBoss || e.kind == EnemyKind.archonVaelenBoss
            ? const Color(0xFFD4AF37)
            : const Color(0xFFEF4444),
      );

      if (e.kind == EnemyKind.chronoSentinel && e.stunTimer <= 0) {
        final double shieldX = r.center.dx + e.facing * r.width * 0.55;
        canvas.drawCircle(Offset(shieldX, r.center.dy), 12, Paint()
          ..color = const Color(0xFFD4AF37)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
      }
    }
  }

  void _drawProjectilesAndBombs(Canvas canvas) {
    for (final p in projectiles) {
      canvas.drawCircle(p.pos, p.radius * 1.6, Paint()
        ..color = p.color.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(p.pos, p.radius, Paint()..color = p.color);
      canvas.drawCircle(p.pos, p.radius * 0.5, Paint()..color = const Color(0xFFFFFFFF));
    }
    for (final b in bombs) {
      canvas.drawCircle(b.pos, 22, Paint()
        ..color = const Color(0xFFFF9100).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawCircle(b.pos, 12, Paint()..color = const Color(0xFF8B4513));
      final double pulse = 0.5 + 0.5 * sin(worldTime * 20);
      canvas.drawCircle(b.pos, 6, Paint()..color = Color.lerp(const Color(0xFFFFEB3B), const Color(0xFFFF1744), pulse)!);
    }
  }

  void _drawLootOrbs(Canvas canvas) {
    for (final o in lootOrbs) {
      final Color c = o.isHealth ? const Color(0xFFEF4444) : const Color(0xFFD4AF37);
      canvas.drawCircle(o.pos, 12, Paint()
        ..color = c.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(o.pos, 6, Paint()..color = c);
      canvas.drawCircle(o.pos, 2, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final double a = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(p.pos, p.size * a, Paint()..color = p.color.withOpacity(a));
    }
  }

  void _drawGrappleChain(Canvas canvas) {
    if (activeGrapple == null) return;
    final Offset start = playerPos + Offset(facing * 8.0, -8);
    final Offset end = activeGrapple!;
    final Paint chain = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 3;
    canvas.drawLine(start, end, chain);
    final Offset mid = Offset.lerp(start, end, 0.5)!;
    canvas.drawCircle(mid, 5, Paint()
      ..color = const Color(0xFFFFEB3B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  void _drawPlayer(Canvas canvas) {
    if (invulnTimer > 0 && ((invulnTimer * 30).round() % 2 == 0)) return;

    final Offset pos = playerPos;
    final bool past = era == EraState.past;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + playerSize.height / 2), width: 30, height: 6),
      Paint()..color = const Color(0x55000000),
    );

    final Color auraColor = past ? const Color(0xFFD4AF37) : const Color(0xFF38BDF8);
    canvas.drawCircle(pos, 44, Paint()
      ..color = auraColor.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));

    final Path scarf = Path()..moveTo(scarfNodes[0].dx, scarfNodes[0].dy);
    for (int i = 1; i < scarfNodes.length; i++) {
      scarf.lineTo(scarfNodes[i].dx, scarfNodes[i].dy);
    }
    canvas.drawPath(
      scarf,
      Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      scarf,
      Paint()
        ..color = const Color(0xFFFF5252)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final double astroAngle = worldTime * 1.6;
    for (int i = 0; i < 2; i++) {
      canvas.save();
      canvas.rotate(astroAngle + i * pi / 2);
      canvas.drawCircle(Offset.zero, 14 + i * 4, Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFFFFEB3B));

    final double legSwing = sin(walkCycle) * 6;
    final Paint legPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(-8 + legSwing, 12, 6, 14), legPaint);
    canvas.drawRect(Rect.fromLTWH(2 - legSwing, 12, 6, 14), legPaint);

    final RRect torso = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -4), width: 22, height: 28),
      const Radius.circular(5),
    );
    final Paint torsoPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF334155), Color(0xFF1E293B)],
      ).createShader(torso.outerRect);
    canvas.drawRRect(torso, torsoPaint);
    canvas.drawCircle(const Offset(0, -6), 3, Paint()..color = const Color(0xFFDC2626));

    canvas.drawCircle(const Offset(0, -24), 9, Paint()..color = const Color(0xFF2D3A56));
    canvas.drawCircle(Offset(facing * 3, -26), 1.8, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(Offset(facing * -2, -26), 1.8, Paint()..color = const Color(0xFF38BDF8));

    Color bladeColor;
    switch (weaponTier) {
      case WeaponTier.rustyBlade: bladeColor = const Color(0xFF9E9E9E); break;
      case WeaponTier.starlightEdge: bladeColor = const Color(0xFF38BDF8); break;
      case WeaponTier.chronosSunCleaver: bladeColor = const Color(0xFFFFD54F); break;
    }

    if (slashTimer > 0) {
      final double progress = 1.0 - (slashTimer / 0.18).clamp(0.0, 1.0);
      if (isPlunge) {
        canvas.drawLine(
          Offset(facing * 4, 0),
          Offset(facing * 4, 50),
          Paint()
            ..color = bladeColor
            ..strokeWidth = 5,
        );
        canvas.drawCircle(Offset(facing * 4, 50), 20, Paint()
          ..color = bladeColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      } else {
        final double arcStart = -pi / 2 + facing * (progress - 0.5) * 2.5;
        final double arcEnd = arcStart + facing * 1.5;
        final Rect arcRect = Rect.fromCircle(center: Offset.zero, radius: 40);
        canvas.drawArc(
          arcRect,
          arcStart,
          arcEnd - arcStart,
          false,
          Paint()
            ..color = bladeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawArc(
          arcRect.inflate(3),
          arcStart,
          arcEnd - arcStart,
          false,
          Paint()
            ..color = bladeColor.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawLine(
          Offset(facing * 8, -8),
          Offset(facing * 30, -24),
          Paint()
            ..color = bladeColor
            ..strokeWidth = 4,
        );
      }
    } else {
      canvas.drawLine(
        Offset(facing * 8, 2),
        Offset(facing * 20, -22),
        Paint()
          ..color = bladeColor
          ..strokeWidth = 4,
      );
      canvas.drawCircle(Offset(facing * 20, -22), 3, Paint()..color = const Color(0xFFD4AF37));
    }

    if (parryTimer > 0) {
      final double alpha = (parryTimer / 0.36).clamp(0.0, 1.0);
      canvas.drawCircle(Offset.zero, 34, Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(alpha * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4);
      canvas.drawCircle(Offset.zero, 34, Paint()
        ..color = const Color(0xFFFFEB3B).withOpacity(alpha * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }

    canvas.restore();
  }

  void _drawEraWave(Canvas canvas, Size size) {
    if (eraWaveRadius <= 0) return;
    final Offset center = playerPos - camera;
    final Color col = era == EraState.past ? const Color(0xFFD4AF37) : const Color(0xFFEF4444);
    canvas.drawCircle(center, eraWaveRadius, Paint()
      ..color = col.withOpacity((1.0 - eraWaveRadius / 2200.0).clamp(0.0, 1.0) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12);
    canvas.drawCircle(center, eraWaveRadius, Paint()
      ..color = col.withOpacity((1.0 - eraWaveRadius / 2200.0).clamp(0.0, 1.0) * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
  }

  void _drawVignette(Canvas canvas, Size size) {
    final Rect screen = Offset.zero & size;
    final Paint v = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x00000000), Color(0x66000000)],
        stops: [0.55, 1.0],
        radius: 0.9,
      ).createShader(screen);
    canvas.drawRect(screen, v);
  }

  @override
  bool shouldRepaint(covariant SolthariaWorld25DPainter oldDelegate) => true;
}
