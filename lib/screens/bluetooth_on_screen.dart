import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/snackbar.dart';
import '../utils/extra.dart';
import '../utils/theme/color_manager.dart';
import '../utils/theme/text_manager.dart';
import '../widgets/scan_result_tile.dart';
import '../widgets/system_device_tile.dart';
import 'data_screen.dart';

class BluetoothOnScreen extends StatefulWidget {
  const BluetoothOnScreen({super.key});

  @override
  State<BluetoothOnScreen> createState() => _BluetoothOnScreenState();
}

class _BluetoothOnScreenState extends State<BluetoothOnScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        backgroundColor: ColorManager.background,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          color: ColorManager.background,
          onRefresh: onRefresh,
          child: _isScanning == false
              ? Center(
                  child:
                      Text('스캔하여 연결 가능한 시계를 확인하세요', style: TextManager.main17))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    children: [
                      ..._buildSystemDeviceTiles(context),
                      if (_systemDevices.isNotEmpty)
                        Divider(
                          color: ColorManager.grey,
                          height: 1,
                          thickness: 0.2,
                        ),
                      ..._buildScanResultTiles(context),
                    ],
                  ),
                ),
        ),
        floatingActionButton: _buildScanButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: ColorManager.background,
      leading: Icon(
        Icons.watch,
        color: ColorManager.white,
      ),
      centerTitle: false,
      titleSpacing: 0,
      title: Text(
        '기기 연결',
        style: TextManager.main21,
      ),
    );
  }

  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e),
          success: false);
    }
    try {
      await FlutterBluePlus.startScan(
          withServices: [Guid("180C")], timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
          success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e),
          success: false);
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DataScreen(device: device),
        settings: const RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(
          withServices: [Guid("180C")], timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton.extended(
        onPressed: onStopPressed,
        backgroundColor: ColorManager.button,
        label: Text(
          "스캔 중지",
          style: TextManager.second19,
        ),
        icon: Icon(
          Icons.stop,
          color: ColorManager.grey,
        ),
      );
    } else {
      return FloatingActionButton.extended(
          onPressed: onScanPressed,
          backgroundColor: ColorManager.button,
          label: Text(
            "스캔 시작",
            style: TextManager.main19,
          ),
          icon: Icon(
            Icons.play_arrow,
            color: ColorManager.white,
          ));
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DataScreen(device: d),
                settings: const RouteSettings(name: '/DeviceScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }
}
