import 'dart:async';
import 'dart:math';

import 'package:ard_blue_app/widgets/sizedbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "../utils/snackbar.dart";

import '../utils/theme/color_manager.dart';
import '../utils/theme/text_manager.dart';
import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile(
      {super.key, required this.characteristic, required this.descriptorTiles});

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription =
        widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      contentPadding: EdgeInsets.zero,
      child: ExpansionTile(
        iconColor: ColorManager.white,
        title: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Characteristic', style: TextManager.second17),
              Row(
                children: [
                  _buildUuid(context),
                  const Width(8),
                  _buildValue(context),
                ],
              ),
            ],
          ),
          subtitle: _buildButtonRow(context),
          contentPadding: const EdgeInsets.all(0.0),
        ),
        children: widget.descriptorTiles,
      ),
    );
  }

  Future onReadPressed() async {
    try {
      await c.read();
      Snackbar.show(ABC.c, "Read: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
  }

  Future onWritePressed() async {
    try {
      await c.write(_getRandomBytes(),
          withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e),
          success: false);
    }
  }

  Widget _buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
    return Flexible(
      child: Text(uuid,
          style: TextManager.second15, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildValue(BuildContext context) {
    String data = _value.toString();
    return Text(data, style: TextManager.second15);
  }

  Widget _buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Read", style: TextManager.bold15),
        onPressed: () async {
          await onReadPressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget _buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write",
            style: TextManager.bold15),
        onPressed: () async {
          await onWritePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget _buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe",
            style: TextManager.bold15),
        onPressed: () async {
          await onSubscribePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget _buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (read) _buildReadButton(context),
        if (write) _buildWriteButton(context),
        if (notify || indicate) _buildSubscribeButton(context),
      ],
    );
  }
}
