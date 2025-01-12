import 'package:bonfire/bonfire.dart';
import 'package:bonfire/tiled/builder/tiled_world_builder.dart';
import 'package:flutter/widgets.dart';

class WorldMapByTiled extends WorldMap {
  late TiledWorldBuilder _builder;
  WorldMapByTiled(
    TiledReader reader, {
    Vector2? forceTileSize,
    ValueChanged<Object>? onError,
    double tileSizeToUpdate = 0,
    Map<String, ObjectBuilder>? objectsBuilder,
  }) : super(const []) {
    this.tileSizeToUpdate = tileSizeToUpdate;
    _builder = TiledWorldBuilder(
      reader,
      forceTileSize: forceTileSize,
      onError: onError,
      tileSizeToUpdate: tileSizeToUpdate,
      objectsBuilder: objectsBuilder,
    );
  }

  @override
  Future<void>? onLoad() async {
    final map = await _builder.build();
    tiles = map.map.tiles;
    gameRef.addAll(map.components ?? []);
    return super.onLoad();
  }
}
