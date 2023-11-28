import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 19/10/21
class MyPlayer extends SimplePlayer with BlockMovementCollisionV2 {
  MyPlayer(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2.all(32),
          position: position,
          life: 200,
        );

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(radius: width / 2),
    );
    return super.onLoad();
  }
}
