import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/theme/color_manager.dart';
import '../utils/theme/text_manager.dart';
import 'sizedbox.dart';

class ScanResultTile extends StatefulWidget {
  const ScanResultTile({super.key, required this.result, this.onTap});

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
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

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data.map((val) => getNiceHexArray(val)).join(', ').toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries
        .map((v) => '${v.key}: ${getNiceHexArray(v.value)}')
        .join(', ')
        .toUpperCase();
  }

  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData;
    return ListTileTheme(
      contentPadding: EdgeInsets.zero,
      child: ExpansionTile(
        title: _buildTitle(context),
        leading: Text(
          widget.result.rssi.toString(),
          style: TextManager.main15,
        ),
        trailing: _buildConnectButton(context),
        children: [
          if (adv.advName.isNotEmpty)
            _buildAdvRow(context, 'Name', adv.advName),
          if (adv.txPowerLevel != null)
            _buildAdvRow(context, 'Tx Power Level', '${adv.txPowerLevel}'),
          if ((adv.appearance ?? 0) > 0)
            _buildAdvRow(context, 'Appearance',
                '0x${adv.appearance!.toRadixString(16)}'),
          if (adv.msd.isNotEmpty)
            _buildAdvRow(
                context, 'Manufacturer Data', getNiceManufacturerData(adv.msd)),
          if (adv.serviceUuids.isNotEmpty)
            _buildAdvRow(context, 'Service UUIDs',
                getNiceServiceUuids(adv.serviceUuids)),
          if (adv.serviceData.isNotEmpty)
            _buildAdvRow(
                context, 'Service Data', getNiceServiceData(adv.serviceData)),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.result.device.platformName,
            overflow: TextOverflow.ellipsis,
            style: TextManager.main17,
          ),
          Text(
            widget.result.device.remoteId.str,
            style: TextManager.second15,
          )
        ],
      );
    } else {
      return Text(
        widget.result.device.remoteId.str,
        style: TextManager.second15,
      );
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isConnected ? ColorManager.white : Colors.transparent,
        side: BorderSide(color: ColorManager.white, width: 1),
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed:
          (widget.result.advertisementData.connectable) ? widget.onTap : null,
      child: isConnected
          ? Text('상세', style: TextManager.inverse17)
          : Text('연결', style: TextManager.thick17),
    );
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextManager.main13),
          const Width(8),
          Expanded(
            child: Text(
              value,
              style: TextManager.second13,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
