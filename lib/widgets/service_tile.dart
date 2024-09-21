import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/theme/color_manager.dart';
import '../utils/theme/text_manager.dart';
import "characteristic_tile.dart";

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {super.key, required this.service, required this.characteristicTiles});

  @override
  Widget build(BuildContext context) {
    return characteristicTiles.isNotEmpty
        ? ListTileTheme(
            contentPadding: EdgeInsets.zero,
            child: ExpansionTile(
              iconColor: ColorManager.white,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service', style: TextManager.main17),
                  buildUuid(context),
                ],
              ),
              children: characteristicTiles,
            ),
          )
        : ListTileTheme(
            contentPadding: EdgeInsets.zero,
            child: ListTile(
              title: Text('Service', style: TextManager.main17),
              subtitle: buildUuid(context),
            ),
          );
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${service.uuid.str.toUpperCase()}';
    return Text(uuid, style: TextManager.main15);
  }
}
