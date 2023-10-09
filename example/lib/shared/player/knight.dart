import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/enemy_sprite_sheet.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'knight_controller.dart';

enum PlayerAttackType {
  attackMelee,
  attackRange,
}

class Knight extends SimplePlayer
    with
        Lighting,
        BlockMovementCollision,
        UseStateController<KnightController> {
  double angleRadAttack = 0.0;
  Rect? rectDirectionAttack;
  Sprite? spriteDirectionAttack;
  bool showBgRangeAttack = false;

  BarLifeController? barLifeController;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2.all(DungeonMap.tileSize),
          position: position,
          speed: DungeonMap.tileSize * 1.5,
          life: 200,
        ) {
    setupMovementByJoystick(
      intencityEnabled: true,
    );
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width * 1.5,
        color: Colors.transparent,
      ),
    );
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (hasGameRef && gameRef.sceneBuilderStatus.isRunning) {
      return;
    }
    super.onJoystickChangeDirectional(event);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (hasGameRef && gameRef.sceneBuilderStatus.isRunning || isDead) {
      return;
    }
    if (hasController) {
      controller.handleJoystickAction(event);
    }
    super.onJoystickAction(event);
  }

  @override
  void die() {
    barLifeController?.life = 0.0;
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: position,
        size: Vector2.all(DungeonMap.tileSize),
      ),
    );
    super.die();
  }

  void execMeleeAttack(double attack) {
    simpleAttackMelee(
      damage: attack,
      animationRight: CommonSpriteSheet.whiteAttackEffectRight,
      size: Vector2.all(DungeonMap.tileSize),
    );
  }

  void execRangeAttack(double angle, double damage) {
    simpleAttackRangeByAngle(
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
      animation: CommonSpriteSheet.fireBallRight,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      angle: angle,
      size: Vector2.all(width * 0.7),
      damage: damage,
      speed: speed * 3,
      collision: RectangleHitbox(
        size: Vector2(width / 3, width / 3),
        position: Vector2(width * 0.1, 0),
      ),
      lightingConfig: LightingConfig(
        radius: width / 2,
        blurBorder: width,
        color: Colors.orange.withOpacity(0.3),
      ),
    );
  }

  @override
  void update(double dt) {
    barLifeController?.life = life;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    _drawDirectionAttack(canvas);
    super.render(canvas);
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, identify) {
    if (hasController) {
      controller.onReceiveDamage(damage);
    }
    super.receiveDamage(attacker, damage, identify);
  }

  void execShowEmote() {
    if (hasGameRef) {
      add(
        AnimatedGameObject(
          position: Vector2(width / 4, 0),
          animation: CommonSpriteSheet.emote,
          size: Vector2.all(width / 2),
          loop: false,
        ),
      );
    }
  }

  void execShowTalk(GameComponent first) {
    double lastZoom = gameRef.camera.zoom;
    gameRef.camera.moveToTargetAnimated(
      effectController: EffectController(duration: 1),
      target: first,
      zoom: 2,
      onComplete: () {
        TalkDialog.show(
          gameRef.context,
          [
            Say(
              text: [
                const TextSpan(
                  text: 'Look at this! It seems that',
                ),
                const TextSpan(
                  text: ' I\'m not alone ',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(
                  text: 'here...',
                ),
              ],
              person: SizedBox(
                width: 100,
                height: 100,
                child: PlayerSpriteSheet.idleRight.asWidget(),
              ),
            ),
            Say(
              text: [
                const TextSpan(
                  text: 'Lok Tar Ogr!',
                ),
                const TextSpan(
                  text: ' Lok Tar Ogr! ',
                  style: TextStyle(color: Colors.green),
                ),
                const TextSpan(
                  text: ' Lok Tar Ogr! ',
                ),
                const TextSpan(
                  text: 'Lok Tar Ogr!',
                  style: TextStyle(color: Colors.green),
                ),
              ],
              person: SizedBox(
                width: 100,
                height: 100,
                child: EnemySpriteSheet.idleLeft.asWidget(),
              ),
              personSayDirection: PersonSayDirection.RIGHT,
            ),
          ],
          onClose: () {
            // ignore: avoid_print
            print('close talk');

            if (!isDead) {
              gameRef.camera.moveToPlayerAnimated(
                effectController: EffectController(duration: 1),
                zoom: lastZoom,
              );
            }
          },
          onFinish: () {
            // ignore: avoid_print
            print('finish talk');
          },
          logicalKeyboardKeysToNext: [
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.enter
          ],
        );
      },
    );
  }

  void _drawDirectionAttack(Canvas c) {
    if (showBgRangeAttack) {
      double radius = height;
      rectDirectionAttack = Rect.fromLTWH(
        -radius / 2,
        -radius / 2,
        radius * 2,
        radius * 2,
      );

      if (rectDirectionAttack != null && spriteDirectionAttack != null) {
        renderSpriteByRadAngle(
          c,
          angleRadAttack,
          rectDirectionAttack!,
          spriteDirectionAttack!,
        );
      }
    }
  }

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: size / 2,
        position: size / 4,
      ),
    );
    spriteDirectionAttack = await Sprite.load('direction_attack.png');
    return super.onLoad();
  }

  @override
  void onMount() {
    barLifeController = BonfireInjector().get<BarLifeController>();
    barLifeController?.configure(maxLife: maxLife, maxStamina: 100);
    super.onMount();
  }

  void execEnableBGRangeAttack(bool enabled, double angle) {
    showBgRangeAttack = enabled;
    angleRadAttack = angle;
  }

  void execShowDamage(double damage) {
    showDamage(
      damage,
      config: TextStyle(
        fontSize: width / 3,
        color: Colors.red,
      ),
    );
  }

  void updateStamina(double stamina) {
    barLifeController?.stamina = stamina;
  }
}
