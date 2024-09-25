import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/theme/color_manager.dart';
import '../utils/theme/text_manager.dart';

class SystemDeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onConnect;

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onConnect,
    super.key,
  });

  @override
  State<SystemDeviceTile> createState() => _SystemDeviceTileState();
}

class _SystemDeviceTileState extends State<SystemDeviceTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      contentPadding: EdgeInsets.zero,
      child: ListTile(
        title: Text(widget.device.platformName, style: TextManager.main17),
        subtitle: Text(
          widget.device.remoteId.str,
          style: TextManager.second15,
        ),
        trailing: TextButton(
          style: TextButton.styleFrom(
            backgroundColor:
                isConnected ? ColorManager.white : Colors.transparent,
            side: BorderSide(color: ColorManager.white, width: 1),
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isConnected ? widget.onOpen : widget.onConnect,
          child: isConnected
              ? Text('상세', style: TextManager.inverse17)
              : Text('연결', style: TextManager.thick17),
        ),
      ),
    );
  }
}
