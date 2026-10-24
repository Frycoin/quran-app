import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HollowKnightMetroidvaniaApp());
}

// ==========================================
// 1. التطبيق الرئيسي
// ==========================================
class HollowKnightMetroidvaniaApp extends StatelessWidget {
  const HollowKnightMetroidvaniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hallownest Echoes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05070B),
      ),
      home: const GameScreen(),
    );
  }
}

// ==========================================
// 2. هياكل البيانات والكائنات الفيزيائية
// ==========================================
enum SlashDir { left, right, up, down }
enum EnemyType { crawler, flyinghusks, falseGuardBoss }

class PlatformRect {
  final Rect rect;
  final bool isHazard;
  const PlatformRect(this.rect, {this.isHazard = false});
}

class GhostAfterImage {
  Offset pos;
  int facing;
  double alpha;
  bool isShadeDash;

  GhostAfterImage({
    required this.pos,
    required this.facing,
    this.alpha = 0.75,
    this.isShadeDash = false,
  });
}

class GameParticle {
  Offset pos;
  Offset vel;
  Color color;
  double size;
  double life;
  double maxLife;
  bool gravityAffected;

  GameParticle({
    required this.pos,
    required this.vel,
    required this.color,
    required this.size,
    required this.life,
    this.gravityAffected = true,
  }) : maxLife = life;
}

class AmbientSpore {
  Offset pos;
  double radius;
  double speedY;
  double phase;
  Color color;

  AmbientSpore({
    required this.pos,
    required this.radius,
    required this.speedY,
    required this.phase,
    required this.color,
  });
}

class SoulSpellProjectile {
  Offset pos;
  Offset vel;
  double radius;
  double life;
  Set<int> hitEnemyIds = {};

  SoulSpellProjectile({
    required this.pos,
    required this.vel,
    this.radius = 22.0,
    this.life = 1.6,
  });
}

class EnemyEntity {
  final int id;
  final EnemyType type;
  Offset pos;
  Offset vel;
  Size size;
  int hp;
  int maxHp;
  double patrolMinX;
  double patrolMaxX;
  int facing;
  double flashTimer = 0.0;
  double aiTimer = 0.0;
  int bossState = 0;
  bool onGround = false;

  EnemyEntity({
    required this.id,
    required this.type,
    required this.pos,
    required this.size,
    required this.hp,
    required this.patrolMinX,
    required this.patrolMaxX,
    this.facing = -1,
  })  : maxHp = hp,
        vel = Offset.zero;

  Rect get bounds => Rect.fromCenter(center: pos, width: size.width, height: size.height);
}

class ShockwaveHazard {
  Offset pos;
  double vx;
  double width;
  double height;
  double life;

  ShockwaveHazard({
    required this.pos,
    required this.vx,
    this.width = 28,
    this.height = 46,
    this.life = 1.8,
  });

  Rect get bounds => Rect.fromLTWH(pos.dx - width / 2, pos.dy - height, width, height);
}

// ==========================================
// 3. شاشة اللعبة والمحرك الفيزيائي
// ==========================================
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _gameTimer;
  final Random _rng = Random();

  static const double worldWidth = 2600.0;
  static const double groundY = 620.0;

  Offset _playerPos = const Offset(200, 520);
  Offset _playerVel = Offset.zero;
  final Size _playerSize = const Size(34, 48);
  int _facing = 1;
  bool _onGround = false;
  int _jumpsRemaining = 2;
  double _invulnTimer = 0.0;
  int _masks = 5;
  final int _maxMasks = 5;
  double _soul = 45.0;

  bool _moveLeft = false;
  bool _moveRight = false;
  bool _aimUp = false;
  bool _aimDown = false;
  bool _jumpHeld = false;

  double _dashTime = 0.0;
  double _dashCooldown = 0.0;

  double _slashTimer = 0.0;
  double _slashCooldown = 0.0;
  SlashDir _currentSlashDir = SlashDir.right;
  final Set<int> _slashedEnemiesInSwing = {};

  double _hitStopTimer = 0.0;
  double _screenShake = 0.0;
  Offset _cameraPos = Offset.zero;

  late List<PlatformRect> _platforms;
  final List<EnemyEntity> _enemies = [];
  final List<GhostAfterImage> _ghosts = [];
  final List<GameParticle> _particles = [];
  final List<AmbientSpore> _spores = [];
  final List<SoulSpellProjectile> _spells = [];
  final List<ShockwaveHazard> _shockwaves = [];

  int _enemyIdCounter = 1;
  bool _bossDefeated = false;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initWorld();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateGame(0.016);
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _initWorld() {
    _masks = _maxMasks;
    _soul = 45.0;
    _playerPos = const Offset(180, 520);
    _playerVel = Offset.zero;
    _bossDefeated = false;
    _isGameOver = false;
    _enemies.clear();
    _particles.clear();
    _ghosts.clear();
    _spells.clear();
    _shockwaves.clear();

    _platforms = [
      const PlatformRect(Rect.fromLTWH(0, groundY, worldWidth, 250)),
      const PlatformRect(Rect.fromLTWH(-60, -200, 60, 1000)),
      const PlatformRect(Rect.fromLTWH(worldWidth, -200, 60, 1000)),
      const PlatformRect(Rect.fromLTWH(320, 480, 180, 24)),
      const PlatformRect(Rect.fromLTWH(590, 370, 190, 24)),
      const PlatformRect(Rect.fromLTWH(880, 460, 210, 24)),
      const PlatformRect(Rect.fromLTWH(620, groundY - 18, 230, 18), isHazard: true),
      const PlatformRect(Rect.fromLTWH(1150, 390, 200, 24)),
      const PlatformRect(Rect.fromLTWH(1420, 490, 170, 24)),
      const PlatformRect(Rect.fromLTWH(1780, 450, 150, 22)),
      const PlatformRect(Rect.fromLTWH(2220, 450, 150, 22)),
    ];

    if (_spores.isEmpty) {
      for (int i = 0; i < 65; i++) {
        _spores.add(
          AmbientSpore(
            pos: Offset(_rng.nextDouble() * worldWidth, _rng.nextDouble() * groundY),
            radius: 1.5 + _rng.nextDouble() * 3.0,
            speedY: 10.0 + _rng.nextDouble() * 20.0,
            phase: _rng.nextDouble() * pi * 2,
            color: i % 3 == 0
                ? const Color(0xFF88D4FF)
                : (i % 4 == 0 ? const Color(0xFFFF9E44) : const Color(0xFFDCE8F2)),
          ),
        );
      }
    }

    _spawnEnemies();
  }

  void _spawnEnemies() {
    _enemies.add(EnemyEntity(
      id: _enemyIdCounter++,
      type: EnemyType.crawler,
      pos: const Offset(410, 458),
      size: const Size(38, 32),
      hp: 3,
      patrolMinX: 335,
      patrolMaxX: 485,
    ));

    _enemies.add(EnemyEntity(
      id: _enemyIdCounter++,
      type: EnemyType.crawler,
      pos: const Offset(980, 438),
      size: const Size(38, 32),
      hp: 3,
      patrolMinX: 895,
      patrolMaxX: 1070,
    ));

    _enemies.add(EnemyEntity(
      id: _enemyIdCounter++,
      type: EnemyType.crawler,
      pos: const Offset(1320, groundY - 20),
      size: const Size(42, 34),
      hp: 4,
      patrolMinX: 1120,
      patrolMaxX: 1550,
    ));

    _enemies.add(EnemyEntity(
      id: _enemyIdCounter++,
      type: EnemyType.flyinghusks,
      pos: const Offset(735, 500),
      size: const Size(40, 40),
      hp: 3,
      patrolMinX: 650,
      patrolMaxX: 820,
    ));

    _enemies.add(EnemyEntity(
      id: _enemyIdCounter++,
      type: EnemyType.flyinghusks,
      pos: const Offset(1250, 260),
      size: const Size(40, 40),
      hp: 3,
      patrolMinX: 1140,
      patrolMaxX: 1380,
    ));

    _enemies.add(EnemyEntity(
      id: _enemyIdCounter++,
      type: EnemyType.falseGuardBoss,
      pos: const Offset(2120, groundY - 58),
      size: const Size(86, 112),
      hp: 22,
      patrolMinX: 1700,
      patrolMaxX: 2480,
    ));
  }

  void _updateGame(double dt) {
    if (_isGameOver) return;

    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
      if (_screenShake > 0) {
        _screenShake = max(0, _screenShake - dt * 28);
      }
      setState(() {});
      return;
    }

    if (_invulnTimer > 0) _invulnTimer -= dt;
    if (_dashCooldown > 0) _dashCooldown -= dt;
    if (_slashCooldown > 0) _slashCooldown -= dt;
    if (_screenShake > 0) _screenShake = max(0, _screenShake - dt * 35);

    _updatePlayerPhysics(dt);
    _updateSlashCombat(dt);
    _updateSoulSpells(dt);
    _updateEnemies(dt);
    _updateShockwaves(dt);
    _updateParticlesAndGhosts(dt);

    setState(() {});
  }

  void _updatePlayerPhysics(double dt) {
    if (_dashTime > 0) {
      _dashTime -= dt;
      _playerVel = Offset(_facing * 790.0, 0);
      _ghosts.add(
        GhostAfterImage(
          pos: _playerPos,
          facing: _facing,
          alpha: 0.75,
          isShadeDash: true,
        ),
      );
    } else {
      double targetVx = 0;
      if (_moveLeft) {
        targetVx = -290.0;
        _facing = -1;
      } else if (_moveRight) {
        targetVx = 290.0;
        _facing = 1;
      }

      final double accel = _onGround ? 18.0 : 12.0;
      _playerVel = Offset(
        _playerVel.dx + (targetVx - _playerVel.dx) * min(1.0, accel * dt),
        _playerVel.dy,
      );

      double gravity = 1480.0;
      if (!_jumpHeld && _playerVel.dy < -120) {
        gravity *= 2.4;
      }
      final double newVy = min(860.0, _playerVel.dy + gravity * dt);
      _playerVel = Offset(_playerVel.dx, newVy);
    }

    Offset nextPos = _playerPos + _playerVel * dt;
    _onGround = false;

    Rect playerRect = Rect.fromCenter(
      center: Offset(nextPos.dx, _playerPos.dy),
      width: _playerSize.width,
      height: _playerSize.height,
    );

    for (final plat in _platforms) {
      if (plat.isHazard) continue;
      if (playerRect.overlaps(plat.rect)) {
        if (_playerVel.dx > 0) {
          nextPos = Offset(plat.rect.left - _playerSize.width / 2, nextPos.dy);
        } else if (_playerVel.dx < 0) {
          nextPos = Offset(plat.rect.right + _playerSize.width / 2, nextPos.dy);
        }
        _playerVel = Offset(0, _playerVel.dy);
      }
    }

    playerRect = Rect.fromCenter(
      center: Offset(nextPos.dx, nextPos.dy),
      width: _playerSize.width,
      height: _playerSize.height,
    );

    for (final plat in _platforms) {
      if (playerRect.overlaps(plat.rect)) {
        if (plat.isHazard) {
          _damagePlayer(1, Offset(nextPos.dx, plat.rect.top));
          _playerVel = const Offset(0, -480);
          break;
        }
        if (_playerVel.dy >= 0 && (_playerPos.dy + _playerSize.height / 2) <= plat.rect.top + 18) {
          nextPos = Offset(nextPos.dx, plat.rect.top - _playerSize.height / 2);
          _playerVel = Offset(_playerVel.dx, 0);
          _onGround = true;
          _jumpsRemaining = 2;
        } else if (_playerVel.dy < 0 &&
            (_playerPos.dy - _playerSize.height / 2) >= plat.rect.bottom - 18) {
          nextPos = Offset(nextPos.dx, plat.rect.bottom + _playerSize.height / 2);
          _playerVel = Offset(_playerVel.dx, 0);
        }
      }
    }

    _playerPos = nextPos;
  }

  void _triggerNailSlash() {
    if (_slashCooldown > 0) return;

    _slashTimer = 0.14;
    _slashCooldown = 0.25;
    _slashedEnemiesInSwing.clear();

    if (_aimDown && !_onGround) {
      _currentSlashDir = SlashDir.down;
    } else if (_aimUp) {
      _currentSlashDir = SlashDir.up;
    } else {
      _currentSlashDir = _facing == 1 ? SlashDir.right : SlashDir.left;
    }
  }

  Rect _getSlashHitbox() {
    switch (_currentSlashDir) {
      case SlashDir.right:
        return Rect.fromCenter(
          center: _playerPos + const Offset(48, 0),
          width: 78,
          height: 54,
        );
      case SlashDir.left:
        return Rect.fromCenter(
          center: _playerPos + const Offset(-48, 0),
          width: 78,
          height: 54,
        );
      case SlashDir.up:
        return Rect.fromCenter(
          center: _playerPos + const Offset(0, -52),
          width: 68,
          height: 70,
        );
      case SlashDir.down:
        return Rect.fromCenter(
          center: _playerPos + const Offset(0, 52),
          width: 72,
          height: 72,
        );
    }
  }

  void _updateSlashCombat(double dt) {
    if (_slashTimer <= 0) return;
    _slashTimer -= dt;

    final Rect hitbox = _getSlashHitbox();

    if (_currentSlashDir == SlashDir.down && _slashedEnemiesInSwing.isEmpty) {
      for (final plat in _platforms) {
        if (plat.isHazard && hitbox.overlaps(plat.rect)) {
          _slashedEnemiesInSwing.add(-999);
          _playerVel = Offset(_playerVel.dx, -540);
          _jumpsRemaining = 2;
          _dashCooldown = 0;
          _screenShake = 6.0;
          _spawnHitParticles(Offset(_playerPos.dx, plat.rect.top), const Color(0xFFFFFFFF), 12);
          break;
        }
      }
    }

    for (final enemy in _enemies) {
      if (_slashedEnemiesInSwing.contains(enemy.id)) continue;
      if (hitbox.overlaps(enemy.bounds)) {
        _slashedEnemiesInSwing.add(enemy.id);
        enemy.hp -= 1;
        enemy.flashTimer = 0.14;

        _soul = min(100.0, _soul + 14.0);
        _hitStopTimer = 0.045;
        _screenShake = 9.5;

        if (_currentSlashDir == SlashDir.down) {
          _playerVel = Offset(_playerVel.dx, -570.0);
          _jumpsRemaining = 2;
          _dashCooldown = 0.0;
        } else if (_currentSlashDir == SlashDir.right) {
          _playerVel = Offset(-190.0, _playerVel.dy);
          enemy.vel = Offset(enemy.type == EnemyType.falseGuardBoss ? 90 : 280, -90);
        } else if (_currentSlashDir == SlashDir.left) {
          _playerVel = Offset(190.0, _playerVel.dy);
          enemy.vel = Offset(enemy.type == EnemyType.falseGuardBoss ? -90 : -280, -90);
        } else if (_currentSlashDir == SlashDir.up) {
          _playerVel = Offset(_playerVel.dx, 140.0);
          enemy.vel = Offset(enemy.vel.dx, -220);
        }

        _spawnHitParticles(enemy.pos, const Color(0xFFFFFFFF), 14);
        _spawnHitParticles(enemy.pos, const Color(0xFFFF8C24), 12);
      }
    }
  }

  void _castSoulOrHeal() {
    if (_soul < 33.0) return;

    if (_masks < _maxMasks && _onGround && !_moveLeft && !_moveRight) {
      _soul -= 33.0;
      _masks = min(_maxMasks, _masks + 1);
      _screenShake = 6.0;
      _spawnHitParticles(_playerPos, const Color(0xFFFFFFFF), 28);
    } else {
      _soul -= 33.0;
      _screenShake = 11.0;
      _hitStopTimer = 0.03;
      _playerVel = Offset(-_facing * 240.0, 0);
      _spells.add(
        SoulSpellProjectile(
          pos: _playerPos + Offset(_facing * 28.0, 0),
          vel: Offset(_facing * 780.0, 0),
        ),
      );
      _spawnHitParticles(_playerPos + Offset(_facing * 25.0, 0), const Color(0xFFD8F4FF), 20);
    }
  }

  void _updateSoulSpells(double dt) {
    for (int i = _spells.length - 1; i >= 0; i--) {
      final spell = _spells[i];
      spell.life -= dt;
      spell.pos += spell.vel * dt;

      _particles.add(
        GameParticle(
          pos: spell.pos + Offset((_rng.nextDouble() - 0.5) * 12, (_rng.nextDouble() - 0.5) * 18),
          vel: Offset(-spell.vel.dx * 0.15, (_rng.nextDouble() - 0.5) * 60),
          color: const Color(0xFFE0F7FF),
          size: 4 + _rng.nextDouble() * 5,
          life: 0.25,
          gravityAffected: false,
        ),
      );

      final Rect spellBounds = Rect.fromCircle(center: spell.pos, radius: spell.radius);
      for (final enemy in _enemies) {
        if (!spell.hitEnemyIds.contains(enemy.id) && spellBounds.overlaps(enemy.bounds)) {
          spell.hitEnemyIds.add(enemy.id);
          enemy.hp -= 3;
          enemy.flashTimer = 0.2;
          enemy.vel = Offset(spell.vel.dx.sign * 260, -100);
          _hitStopTimer = 0.05;
          _screenShake = 12.0;
          _spawnHitParticles(enemy.pos, const Color(0xFFFFFFFF), 22);
        }
      }

      if (spell.life <= 0 || spell.pos.dx < 0 || spell.pos.dx > worldWidth) {
        _spells.removeAt(i);
      }
    }
  }

  void _updateEnemies(double dt) {
    for (int i = _enemies.length - 1; i >= 0; i--) {
      final e = _enemies[i];
      if (e.flashTimer > 0) e.flashTimer -= dt;

      if (e.hp <= 0) {
        _spawnHitParticles(e.pos, const Color(0xFFFF7A18), 32);
        _spawnHitParticles(e.pos, const Color(0xFFFFFFFF), 20);
        _screenShake = e.type == EnemyType.falseGuardBoss ? 22.0 : 10.0;
        if (e.type == EnemyType.falseGuardBoss) {
          _bossDefeated = true;
        }
        _enemies.removeAt(i);
        continue;
      }

      if (e.type == EnemyType.crawler) {
        e.vel = Offset(e.VelXWithPatrol(85.0), e.vel.dy);
        e.pos += e.vel * dt;
        e.vel = Offset(e.vel.dx * 0.9, 0);
        if (e.pos.dx <= e.patrolMinX) e.facing = 1;
        if (e.pos.dx >= e.patrolMaxX) e.facing = -1;
      } else if (e.type == EnemyType.flyinghusks) {
        e.aiTimer += dt * 2.5;
        e.pos = Offset(
          e.pos.dx + e.facing * 75.0 * dt + e.vel.dx * dt,
          e.pos.dy + sin(e.aiTimer) * 45.0 * dt,
        );
        e.vel = Offset(e.vel.dx * 0.88, 0);
        if (e.pos.dx <= e.patrolMinX) e.facing = 1;
        if (e.pos.dx >= e.patrolMaxX) e.facing = -1;
      } else if (e.type == EnemyType.falseGuardBoss) {
        _updateBossAI(e, dt);
      }

      if (_invulnTimer <= 0 && _dashTime <= 0) {
        final Rect pBounds = Rect.fromCenter(
          center: _playerPos,
          width: _playerSize.width * 0.8,
          height: _playerSize.height * 0.85,
        );
        if (pBounds.overlaps(e.bounds)) {
          _damagePlayer(1, e.pos);
        }
      }
    }
  }

  void _updateBossAI(EnemyEntity boss, double dt) {
    boss.aiTimer += dt;
    final double distToPlayer = (_playerPos.dx - boss.pos.dx).abs();

    boss.vel = Offset(boss.vel.dx * 0.9, boss.vel.dy + 1350.0 * dt);
    boss.pos += boss.vel * dt;

    if (boss.pos.dy >= groundY - boss.size.height / 2) {
      boss.pos = Offset(boss.pos.dx, groundY - boss.size.height / 2);
      if (!boss.onGround && boss.bossState == 2) {
        _screenShake = 18.0;
        _spawnHitParticles(
          Offset(boss.pos.dx, groundY),
          const Color(0xFFFF9233),
          35,
        );
        _shockwaves.add(ShockwaveHazard(pos: Offset(boss.pos.dx - 30, groundY), vx: -360));
        _shockwaves.add(ShockwaveHazard(pos: Offset(boss.pos.dx + 30, groundY), vx: 360));
        boss.bossState = 0;
        boss.aiTimer = 0;
      }
      boss.vel = Offset(boss.vel.dx, 0);
      boss.onGround = true;
    } else {
      boss.onGround = false;
    }

    boss.pos = Offset(boss.pos.dx.clamp(boss.patrolMinX, boss.patrolMaxX), boss.pos.dy);

    if (distToPlayer > 900) return;

    if (boss.bossState == 0) {
      boss.facing = _playerPos.dx >= boss.pos.dx ? 1 : -1;
      boss.pos = Offset(boss.pos.dx + boss.facing * 95.0 * dt, boss.pos.dy);

      if (boss.aiTimer > 1.8) {
        boss.bossState = 1;
        boss.aiTimer = 0;
      }
    } else if (boss.bossState == 1) {
      if (boss.aiTimer > 0.55) {
        boss.bossState = 2;
        boss.facing = _playerPos.dx >= boss.pos.dx ? 1 : -1;
        boss.vel = Offset(boss.facing * 340.0, -680.0);
        boss.onGround = false;
      }
    }
  }

  void _updateShockwaves(double dt) {
    for (int i = _shockwaves.length - 1; i >= 0; i--) {
      final sw = _shockwaves[i];
      sw.life -= dt;
      sw.pos = Offset(sw.pos.dx + sw.vx * dt, sw.pos.dy);

      final Rect pBounds = Rect.fromCenter(
        center: _playerPos,
        width: _playerSize.width * 0.8,
        height: _playerSize.height * 0.85,
      );

      if (_invulnTimer <= 0 && _dashTime <= 0 && pBounds.overlaps(sw.bounds)) {
        _damagePlayer(1, sw.pos);
      }

      if (sw.life <= 0) {
        _shockwaves.removeAt(i);
      }
    }
  }

  void _damagePlayer(int amount, Offset sourcePos) {
    if (_invulnTimer > 0) return;
    _masks = max(0, _masks - amount);
    _invulnTimer = 1.35;
    _hitStopTimer = 0.08;
    _screenShake = 16.0;

    final double dir = (_playerPos.dx >= sourcePos.dx) ? 1.0 : -1.0;
    _playerVel = Offset(dir * 320.0, -360.0);

    _spawnHitParticles(_playerPos, const Color(0xFFFFFFFF), 22);
    _spawnHitParticles(_playerPos, const Color(0xFF11131A), 18);

    if (_masks <= 0) {
      _isGameOver = true;
    }
  }

  void _spawnHitParticles(Offset origin, Color color, int count) {
    for (int i = 0; i < count; i++) {
      final double angle = _rng.nextDouble() * pi * 2;
      final double speed = 80.0 + _rng.nextDouble() * 380.0;
      _particles.add(
        GameParticle(
          pos: origin,
          vel: Offset(cos(angle) * speed, sin(angle) * speed - 60),
          color: color,
          size: 2.5 + _rng.nextDouble() * 5.0,
          life: 0.25 + _rng.nextDouble() * 0.35,
        ),
      );
    }
  }

  void _updateParticlesAndGhosts(double dt) {
    for (int i = _ghosts.length - 1; i >= 0; i--) {
      _ghosts[i].alpha -= dt * 3.8;
      if (_ghosts[i].alpha <= 0) _ghosts.removeAt(i);
    }

    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= dt;
      if (p.gravityAffected) {
        p.vel = Offset(p.vel.dx * 0.96, p.vel.dy + 680.0 * dt);
      }
      p.pos += p.vel * dt;
      if (p.life <= 0) _particles.removeAt(i);
    }

    for (final s in _spores) {
      s.phase += dt * 1.8;
      s.pos = Offset(
        s.pos.dx + sin(s.phase) * 14.0 * dt,
        s.pos.dy - s.speedY * dt,
      );
      if (s.pos.dy < 40) {
        s.pos = Offset(s.pos.dx, groundY - 10);
      }
    }
  }

  // ==========================================
  // 8. بناء الواجهة وأزرار اللمس
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Size screenSize = Size(constraints.maxWidth, constraints.maxHeight);

          final double targetCamX =
              (_playerPos.dx - screenSize.width * 0.42).clamp(0.0, max(0.0, worldWidth - screenSize.width));
          final double targetCamY =
              (_playerPos.dy - screenSize.height * 0.58).clamp(-120.0, 120.0);

          final Offset shakeOffset = _screenShake > 0
              ? Offset(
                  (_rng.nextDouble() - 0.5) * _screenShake * 2.2,
                  (_rng.nextDouble() - 0.5) * _screenShake * 2.2,
                )
              : Offset.zero;

          _cameraPos = Offset(
                _cameraPos.dx + (targetCamX - _cameraPos.dx) * 0.14,
                _cameraPos.dy + (targetCamY - _cameraPos.dy) * 0.14,
              ) +
              shakeOffset;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: HollowWorldPainter(
                    cameraPos: _cameraPos,
                    playerPos: _playerPos,
                    playerSize: _playerSize,
                    facing: _facing,
                    dashTime: _dashTime,
                    invulnTimer: _invulnTimer,
                    slashTimer: _slashTimer,
                    slashDir: _currentSlashDir,
                    slashHitbox: _getSlashHitbox(),
                    masks: _masks,
                    maxMasks: _maxMasks,
                    soul: _soul,
                    platforms: _platforms,
                    enemies: _enemies,
                    ghosts: _ghosts,
                    particles: _particles,
                    spores: _spores,
                    spells: _spells,
                    shockwaves: _shockwaves,
                    bossDefeated: _bossDefeated,
                  ),
                ),
              ),

              Positioned(
                top: 18,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'اضرب للأسفل في الهواء (↓ + سيف) للقفز الارتدادي Nail Pogo فوق الأشواك والأعداء',
                    style: TextStyle(color: Color(0xFFCFD8E3), fontSize: 11.5),
                  ),
                ),
              ),

              Positioned(
                left: 20,
                bottom: 22,
                child: _buildDirectionalPad(),
              ),
              Positioned(
                right: 22,
                bottom: 22,
                child: _buildActionButtons(),
              ),

              if (_isGameOver || _bossDefeated) _buildOverlayBanner(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDirectionalPad() {
    return SizedBox(
      width: 176,
      height: 156,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 48,
            child: _touchHoldButton(
              icon: Icons.keyboard_arrow_left_rounded,
              active: _moveLeft,
              onChanged: (v) => setState(() => _moveLeft = v),
            ),
          ),
          Positioned(
            right: 0,
            top: 48,
            child: _touchHoldButton(
              icon: Icons.keyboard_arrow_right_rounded,
              active: _moveRight,
              onChanged: (v) => setState(() => _moveRight = v),
            ),
          ),
          Positioned(
            left: 58,
            top: 0,
            child: _touchHoldButton(
              icon: Icons.keyboard_arrow_up_rounded,
              active: _aimUp,
              size: 52,
              onChanged: (v) => setState(() => _aimUp = v),
            ),
          ),
          Positioned(
            left: 58,
            bottom: 0,
            child: _touchHoldButton(
              icon: Icons.keyboard_arrow_down_rounded,
              active: _aimDown,
              size: 52,
              onChanged: (v) => setState(() => _aimDown = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: 190,
      height: 155,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 36,
            child: _actionCircleButton(
              label: 'X',
              subLabel: 'NAIL',
              color: const Color(0xFFE2EBF5),
              onTapDown: _triggerNailSlash,
            ),
          ),
          Positioned(
            right: 60,
            bottom: 0,
            child: Listener(
              onPointerDown: (_) {
                _jumpHeld = true;
                if (_jumpsRemaining > 0) {
                  _jumpsRemaining--;
                  _playerVel = Offset(_playerVel.dx, -540.0);
                  _onGround = false;
                  _spawnHitParticles(
                    _playerPos + const Offset(0, 22),
                    const Color(0xFFD6E4F0),
                    8,
                  );
                }
              },
              onPointerUp: (_) => _jumpHeld = false,
              onPointerCancel: (_) => _jumpHeld = false,
              child: _styledButtonVisual('A', 'JUMP', const Color(0xFF9AC5F4)),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 48,
            child: _actionCircleButton(
              label: 'RT',
              subLabel: 'DASH',
              color: const Color(0xFF8A99AD),
              onTapDown: () {
                if (_dashCooldown <= 0) {
                  _dashTime = 0.16;
                  _dashCooldown = 0.55;
                  _screenShake = 4.5;
                  _spawnHitParticles(_playerPos, const Color(0xFF1A1E29), 12);
                }
              },
            ),
          ),
          Positioned(
            left: 64,
            top: 0,
            child: _actionCircleButton(
              label: 'B',
              subLabel: 'SOUL',
              color: _soul >= 33 ? const Color(0xFFFFFFFF) : const Color(0xFF556070),
              onTapDown: _castSoulOrHeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _touchHoldButton({
    required IconData icon,
    required bool active,
    required ValueChanged<bool> onChanged,
    double size = 58,
  }) {
    return Listener(
      onPointerDown: (_) => onChanged(true),
      onPointerUp: (_) => onChanged(false),
      onPointerCancel: (_) => onChanged(false),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.28) : Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? Colors.white : Colors.white38,
            width: 1.8,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.62),
      ),
    );
  }

  Widget _actionCircleButton({
    required String label,
    required String subLabel,
    required Color color,
    required VoidCallback onTapDown,
  }) {
    return Listener(
      onPointerDown: (_) => onTapDown(),
      child: _styledButtonVisual(label, subLabel, color),
    );
  }

  Widget _styledButtonVisual(String label, String subLabel, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.52),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.85), width: 2.0),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subLabel,
            style: TextStyle(
              color: color.withOpacity(0.75),
              fontSize: 8.5,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayBanner() {
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF070A10).withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6E4F0), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isGameOver ? 'SHADE BROKEN' : 'SENTINEL VANQUISHED',
                style: TextStyle(
                  color: _isGameOver ? const Color(0xFFFF7A30) : const Color(0xFFE8F4FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isGameOver
                    ? 'لقد تحطم قناعك في أعماق الكهف المظلم'
                    : 'انتصرت على حارس الكهف العملاق وأتقنت فنون السيف والروح!',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6E4F0),
                  foregroundColor: const Color(0xFF070A10),
                ),
                onPressed: _initWorld,
                child: const Text(
                  'إعادة خوض الرحلة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on EnemyEntity {
  double VelXWithPatrol(double speed) => facing * speed + vel.dx;
}

// ==========================================
// 9. المحرك الرسومي المخصص
// ==========================================
class HollowWorldPainter extends CustomPainter {
  final Offset cameraPos;
  final Offset playerPos;
  final Size playerSize;
  final int facing;
  final double dashTime;
  final double invulnTimer;
  final double slashTimer;
  final SlashDir slashDir;
  final Rect slashHitbox;
  final int masks;
  final int maxMasks;
  final double soul;
  final List<PlatformRect> platforms;
  final List<EnemyEntity> enemies;
  final List<GhostAfterImage> ghosts;
  final List<GameParticle> particles;
  final List<AmbientSpore> spores;
  final List<SoulSpellProjectile> spells;
  final List<ShockwaveHazard> shockwaves;
  final bool bossDefeated;

  HollowWorldPainter({
    required this.cameraPos,
    required this.playerPos,
    required this.playerSize,
    required this.facing,
    required this.dashTime,
    required this.invulnTimer,
    required this.slashTimer,
    required this.slashDir,
    required this.slashHitbox,
    required this.masks,
    required this.maxMasks,
    required this.soul,
    required this.platforms,
    required this.enemies,
    required this.ghosts,
    required this.particles,
    required this.spores,
    required this.spells,
    required this.shockwaves,
    required this.bossDefeated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screenRect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF050811),
          Color(0xFF0B1324),
          Color(0xFF090D16),
        ],
      ).createShader(screenRect);
    canvas.drawRect(screenRect, bgPaint);

    _drawParallaxPillars(canvas, size, 0.25, const Color(0xFF0E1729), 140);
    _drawParallaxPillars(canvas, size, 0.5, const Color(0xFF131F36), 95);

    canvas.save();
    canvas.translate(-cameraPos.dx, -cameraPos.dy);

    for (final s in spores) {
      final Paint sporePaint = Paint()
        ..color = s.color.withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(s.pos, s.radius, sporePaint);
    }

    _drawPlatformsAndSpikes(canvas);

    for (final g in ghosts) {
      _drawKnightCharacter(
        canvas,
        g.pos,
        g.facing,
        opacity: g.alpha * 0.65,
        isShade: g.isShadeDash,
      );
    }

    for (final enemy in enemies) {
      _drawEnemy(canvas, enemy);
    }

    for (final sw in shockwaves) {
      final Paint swPaint = Paint()
        ..color = const Color(0xFFFF9233)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawOval(sw.bounds, swPaint);
      canvas.drawOval(sw.bounds.deflate(5), Paint()..color = Colors.white);
    }

    final bool blinkHide = invulnTimer > 0 && ((invulnTimer * 25).floor() % 2 == 0);
    if (!blinkHide) {
      _drawKnightCharacter(
        canvas,
        playerPos,
        facing,
        isShade: dashTime > 0,
      );
    }

    if (slashTimer > 0) {
      _drawNailSlashArc(canvas);
    }

    for (final spell in spells) {
      final Paint glow = Paint()
        ..color = const Color(0xFF88D4FF).withOpacity(0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(spell.pos, spell.radius * 1.35, glow);
      canvas.drawCircle(spell.pos, spell.radius * 0.85, Paint()..color = Colors.white);
    }

    for (final p in particles) {
      final double alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final Paint partPaint = Paint()
        ..color = p.color.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(p.pos, p.size * alpha, partPaint);
    }

    canvas.restore();

    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.65),
        ],
        stops: const [0.6, 1.0],
      ).createShader(screenRect);
    canvas.drawRect(screenRect, vignette);

    _drawHollowKnightHUD(canvas, size);
  }

  void _drawParallaxPillars(
    Canvas canvas,
    Size size,
    double factor,
    Color color,
    double width,
  ) {
    final Paint paint = Paint()..color = color;
    final double offset = -(cameraPos.dx * factor) % (width * 3.2);
    for (double x = offset - width; x < size.width + width; x += width * 3.2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), paint);
    }
  }

  void _drawPlatformsAndSpikes(Canvas canvas) {
    for (final plat in platforms) {
      if (plat.isHazard) {
        final Path spikePath = Path();
        const double spikeW = 18.0;
        for (double x = plat.rect.left; x < plat.rect.right; x += spikeW) {
          spikePath.moveTo(x, plat.rect.bottom);
          spikePath.lineTo(x + spikeW / 2, plat.rect.top - 8);
          spikePath.lineTo(x + spikeW, plat.rect.bottom);
        }
        spikePath.close();
        canvas.drawPath(spikePath, Paint()..color = const Color(0xFF9BA8B8));
        canvas.drawPath(
          spikePath,
          Paint()
            ..color = const Color(0xFFDCE6F2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      } else {
        final RRect rrect = RRect.fromRectAndRadius(plat.rect, const Radius.circular(6));
        canvas.drawRRect(rrect, Paint()..color = const Color(0xFF141B29));
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = const Color(0xFF334460)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }
  }

  void _drawKnightCharacter(
    Canvas canvas,
    Offset center,
    int dir, {
    double opacity = 1.0,
    bool isShade = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(dir.toDouble(), 1.0);

    final Paint cloakPaint = Paint()
      ..color = (isShade ? const Color(0xFF080A0F) : const Color(0xFF263142)).withOpacity(opacity);
    final Path cloak = Path()
      ..moveTo(-12, -4)
      ..lineTo(10, -4)
      ..lineTo(15, 23)
      ..lineTo(3, 18)
      ..lineTo(-5, 24)
      ..lineTo(-16, 21)
      ..close();
    canvas.drawPath(cloak, cloakPaint);

    final Paint headPaint = Paint()
      ..color = (isShade ? const Color(0xFF11131A) : const Color(0xFFF4F8FC)).withOpacity(opacity);
    final RRect head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -10), width: 24, height: 22),
      const Radius.circular(9),
    );
    canvas.drawRRect(head, headPaint);

    final Path horns = Path()
      ..moveTo(-9, -16)
      ..quadraticBezierTo(-17, -30, -7, -36)
      ..quadraticBezierTo(-10, -24, -4, -18)
      ..moveTo(9, -16)
      ..quadraticBezierTo(17, -30, 7, -36)
      ..quadraticBezierTo(10, -24, 4, -18)
      ..close();
    canvas.drawPath(horns, headPaint);

    final Paint eyePaint = Paint()
      ..color = (isShade ? const Color(0xFFE6F4FF) : const Color(0xFF090C12)).withOpacity(opacity);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(5, -9), width: 5.5, height: 8.5),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-2, -9), width: 4.5, height: 7.5),
      eyePaint,
    );

    canvas.restore();
  }

  void _drawNailSlashArc(Canvas canvas) {
    final Paint slashPaint = Paint()
      ..color = Colors.white.withOpacity((slashTimer / 0.14).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    double startAngle = -0.7;
    double sweepAngle = 1.4;

    if (slashDir == SlashDir.left) {
      startAngle = pi - 0.7;
    } else if (slashDir == SlashDir.up) {
      startAngle = -pi / 2 - 0.7;
    } else if (slashDir == SlashDir.down) {
      startAngle = pi / 2 - 0.7;
    }

    canvas.drawArc(slashHitbox, startAngle, sweepAngle, false, slashPaint);
  }

  void _drawEnemy(Canvas canvas, EnemyEntity e) {
    final bool isFlashing = e.flashTimer > 0;
    final Color bodyColor = isFlashing
        ? Colors.white
        : (e.type == EnemyType.falseGuardBoss
            ? const Color(0xFF283347)
            : const Color(0xFF323E52));

    final RRect bodyRect = RRect.fromRectAndRadius(
      e.bounds,
      Radius.circular(e.type == EnemyType.falseGuardBoss ? 18 : 12),
    );
    canvas.drawRRect(bodyRect, Paint()..color = bodyColor);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = const Color(0xFF6B7D99)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    if (e.type == EnemyType.flyinghusks) {
      final double wingOffset = sin(e.aiTimer * 6) * 8;
      final Paint wingPaint = Paint()..color = Colors.white.withOpacity(0.45);
      canvas.drawOval(
        Rect.fromCenter(
          center: e.pos + Offset(-16, -12 + wingOffset),
          width: 22,
          height: 10,
        ),
        wingPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: e.pos + Offset(16, -12 + wingOffset),
          width: 22,
          height: 10,
        ),
        wingPaint,
      );
    }

    if (e.type == EnemyType.falseGuardBoss) {
      final double maceX = e.pos.dx + e.facing * 52;
      final double maceY = e.bossState == 1 ? e.pos.dy - 45 : e.pos.dy + 12;
      canvas.drawLine(
        e.pos,
        Offset(maceX, maceY),
        Paint()
          ..color = const Color(0xFF8C9BB0)
          ..strokeWidth = 5,
      );
      canvas.drawCircle(
        Offset(maceX, maceY),
        20,
        Paint()..color = isFlashing ? Colors.white : const Color(0xFF1B2230),
      );
    }

    final Offset eyeCenter = e.pos + Offset(e.facing * (e.size.width * 0.22), -e.size.height * 0.15);
    canvas.drawCircle(
      eyeCenter,
      e.type == EnemyType.falseGuardBoss ? 9.0 : 5.0,
      Paint()
        ..color = const Color(0xFFFF881B)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      eyeCenter,
      e.type == EnemyType.falseGuardBoss ? 4.5 : 2.5,
      Paint()..color = const Color(0xFFFFE0B2),
    );
  }

  void _drawHollowKnightHUD(Canvas canvas, Size size) {
    const Offset vesselCenter = Offset(52, 48);
    const double vesselRadius = 28.0;

    canvas.drawCircle(
      vesselCenter,
      vesselRadius,
      Paint()..color = const Color(0xFF121722),
    );

    canvas.save();
    final Path clipCircle = Path()
      ..addOval(Rect.fromCircle(center: vesselCenter, radius: vesselRadius - 3));
    canvas.clipPath(clipCircle);

    final double fillHeight = (soul / 100.0) * (vesselRadius * 2);
    final Rect soulRect = Rect.fromLTWH(
      vesselCenter.dx - vesselRadius,
      vesselCenter.dy + vesselRadius - fillHeight,
      vesselRadius * 2,
      fillHeight,
    );
    canvas.drawRect(
      soulRect,
      Paint()
        ..color = soul >= 33 ? const Color(0xFFF2F9FF) : const Color(0xFF8CA0B8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.restore();

    canvas.drawCircle(
      vesselCenter,
      vesselRadius,
      Paint()
        ..color = const Color(0xFFD8E4F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2,
    );

    for (int i = 0; i < maxMasks; i++) {
      final Offset maskPos = Offset(102.0 + i * 32.0, 46.0);
      final bool isFull = i < masks;

      final RRect maskShape = RRect.fromRectAndRadius(
        Rect.fromCenter(center: maskPos, width: 22, height: 26),
        const Radius.circular(9),
      );

      if (isFull) {
        canvas.drawRRect(maskShape, Paint()..color = const Color(0xFFF2F7FC));
        canvas.drawOval(
          Rect.fromCenter(center: maskPos + const Offset(-4, 1), width: 4.5, height: 7),
          Paint()..color = const Color(0xFF0E131D),
        );
        canvas.drawOval(
          Rect.fromCenter(center: maskPos + const Offset(4, 1), width: 4.5, height: 7),
          Paint()..color = const Color(0xFF0E131D),
        );
      } else {
        canvas.drawRRect(
          maskShape,
          Paint()
            ..color = const Color(0xFF4A586E)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }

    for (final e in enemies) {
      if (e.type == EnemyType.falseGuardBoss && (playerPos.dx - e.pos.dx).abs() < 850) {
        final double barW = min(360.0, size.width * 0.45);
        final Rect bgBar = Rect.fromCenter(
          center: Offset(size.width / 2, 36),
          width: barW,
          height: 12,
        );
        final double hpRatio = (e.hp / e.maxHp).clamp(0.0, 1.0);
        final Rect fgBar = Rect.fromLTWH(bgBar.left, bgBar.top, barW * hpRatio, 12);

        canvas.drawRRect(
          RRect.fromRectAndRadius(bgBar, const Radius.circular(6)),
          Paint()..color = const Color(0xFF121824),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(fgBar, const Radius.circular(6)),
          Paint()..color = const Color(0xFFFF8424),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgBar, const Radius.circular(6)),
          Paint()
            ..color = const Color(0xFFDCE6F2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HollowWorldPainter oldDelegate) => true;
}
