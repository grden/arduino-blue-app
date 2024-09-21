import 'dart:async';

import 'package:ard_blue_app/widgets/sizedbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/provider/ble_provider.dart';
import '../utils/theme/color_manager.dart';
import '../utils/theme/text_manager.dart';
import '../widgets/service_tile.dart';
import '../widgets/characteristic_tile.dart';
import '../widgets/descriptor_tile.dart';
import '../utils/snackbar.dart';
import '../utils/extra.dart';

class DataScreen extends ConsumerStatefulWidget {
  final BluetoothDevice device;

  const DataScreen({super.key, required this.device});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  final Guid serviceUUID = Guid('180C');
  final Guid gpsUUID = Guid('2A56');
  final Guid tempUUID = Guid('2A6E');
  final Guid bpmUUID = Guid('2A37');

  final Map<Guid, StreamSubscription<List<int>>> _subscriptions = {};

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  // 생성자
  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });

    _mtuSubscription = widget.device.mtu.listen((value) {
      _mtuSize = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    _subscriptions.forEach((uuid, subscription) => subscription.cancel());
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC,
      child: Scaffold(
        backgroundColor: ColorManager.background,
        appBar: AppBar(
          foregroundColor: ColorManager.white,
          backgroundColor: ColorManager.background,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            widget.device.platformName,
            style: TextManager.main21,
          ),
          actions: [_buildConnectButton(context)],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRemoteId(context),
                const Height(16),
                Divider(
                  color: ColorManager.grey,
                  height: 1,
                  thickness: 0.2,
                ),
                const Height(8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildRssiTile(context),
                    const Width(8),
                    Text(
                      'Device is ${_connectionState.toString().split('.')[1]}.',
                      style: TextManager.main17,
                    ),
                    const Width(8),
                    _buildGetServices(context)
                  ],
                ),
                const Height(8),
                Divider(
                  color: ColorManager.grey,
                  height: 1,
                  thickness: 0.2,
                ),
                ..._buildServiceTiles(context, widget.device),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e),
            success: false);
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e),
          success: false);
    }
  }

  // Service 180C & notify하는 characteristic 찾고 subscribe & 변수 저장
  void findServiceAndCharacteristics() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }

    // discover services
    try {
      _services = await widget.device.discoverServices();
      Snackbar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Discover Services Error:", e),
          success: false);
    }

    for (BluetoothService s in _services) {
      for (BluetoothCharacteristic c in s.characteristics) {
        // discover characteristics that notify, then specific characteristics
        if (c.properties.notify) {
          if (c.uuid == gpsUUID) {
            listenToCharacteristic(c, 'gps');
          } else if (c.uuid == tempUUID) {
            listenToCharacteristic(c, 'temp');
          } else if (c.uuid == bpmUUID) {
            listenToCharacteristic(c, 'bpm');
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _isDiscoveringServices = false;
      });
    }
  }

  void listenToCharacteristic(BluetoothCharacteristic c, String cName) async {
    _subscriptions[c.uuid] = c.lastValueStream.listen((value) {
      String receivedString = String.fromCharCodes(value);
      print('Received from $cName: $receivedString');
      sendToFirestore(receivedString, cName);

      if (c.uuid == gpsUUID) {
        if (mounted) {
          ref.read(gpsProvider.notifier).setBLE(value);
        }
      } else if (c.uuid == tempUUID) {
        if (mounted) {
          ref.read(tempProvider.notifier).setBLE(value);
        }
      } else if (c.uuid == bpmUUID) {
        if (mounted) {
          ref.read(bpmProvider.notifier).setBLE(value);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.uuid == gpsUUID) {
        ref.invalidate(gpsProvider);
      } else if (c.uuid == tempUUID) {
        ref.invalidate(tempProvider);
      } else if (c.uuid == bpmUUID) {
        ref.invalidate(bpmProvider);
      }
    });

    try {
      await c.setNotifyValue(true);
    } catch (e) {
      print('Error setting notify value for characteristic ${c.uuid}: $e');
    }
  }

  Future<void> sendToFirestore(String received, String cName) async {
    // implement later
  }

  // Future onDiscoverServicesPressed() async {
  //   if (mounted) {
  //     setState(() {
  //       _isDiscoveringServices = true;
  //     });
  //   }
  //   try {
  //     _services = await widget.device.discoverServices();
  //     Snackbar.show(ABC.c, "Discover Services: Success", success: true);
  //   } catch (e) {
  //     Snackbar.show(ABC.c, prettyException("Discover Services Error:", e),
  //         success: false);
  //   }
  //   if (mounted) {
  //     setState(() {
  //       _isDiscoveringServices = false;
  //     });
  //   }
  // }

  // Future onRequestMtuPressed() async {
  //   try {
  //     await widget.device.requestMtu(223, predelay: 0);
  //     Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
  //   } catch (e) {
  //     Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e),
  //         success: false);
  //   }
  // }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => _buildCharacteristicTile(c))
                .toList(),
          ),
        )
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles:
          c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(),
    );
  }

  Widget _buildSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          color: ColorManager.white,
          strokeWidth: 2.0,
        ),
      ),
    );
  }

  Widget _buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        '${widget.device.remoteId}',
        style: TextManager.main15,
      ),
    );
  }

  Widget _buildRssiTile(BuildContext context) {
    return Column(
      children: [
        isConnected
            ? Icon(Icons.bluetooth_connected, color: ColorManager.white)
            : Icon(Icons.bluetooth_disabled, color: ColorManager.white),
        Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : '0'),
            style: TextManager.main13)
      ],
    );
  }

  Widget _buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      children: [
        TextButton(
          onPressed: findServiceAndCharacteristics,
          child: Text(
            "Get Services",
            style: TextManager.bold17,
          ),
        ),
        IconButton(
          icon: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ColorManager.grey),
            ),
          ),
          onPressed: null,
        )
      ],
    );
  }

  // Widget buildMtuTile(BuildContext context) {
  //   return ListTile(
  //       title: const Text('MTU Size'),
  //       subtitle: Text('$_mtuSize bytes'),
  //       trailing: IconButton(
  //         icon: const Icon(Icons.edit),
  //         onPressed: onRequestMtuPressed,
  //       ));
  // }

  Widget _buildConnectButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(children: [
        if (_isConnecting || _isDisconnecting) _buildSpinner(context),
        TextButton(
          onPressed: _isConnecting
              ? onCancelPressed
              : (isConnected ? onDisconnectPressed : onConnectPressed),
          style: TextButton.styleFrom(
            side: BorderSide(color: ColorManager.white, width: 1),
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(_isConnecting ? "취소" : (isConnected ? "연결 해제" : "연결"),
              style: TextManager.thick17),
        )
      ]),
    );
  }
}
