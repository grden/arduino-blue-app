import '../../screens/bluetooth_screen.dart';
import '../../screens/monitor_screen.dart';
import '../theme/color_manager.dart';

import 'package:flutter/material.dart';

enum TabItem {
  devices(Icons.watch, '기기', MonitorScreen(),
      inActiveIcon: Icons.watch_outlined),
  bluetooth(Icons.bluetooth_audio, '연결', BluetoothScreen(),
      inActiveIcon: Icons.bluetooth);

  final IconData activeIcon;
  final IconData inActiveIcon;
  final String tabName;
  final Widget firstPage;

  const TabItem(this.activeIcon, this.tabName, this.firstPage,
      {IconData? inActiveIcon})
      : inActiveIcon = inActiveIcon ?? activeIcon;

  BottomNavigationBarItem toNavigationBarItem(BuildContext context,
      {required bool isActivated}) {
    return BottomNavigationBarItem(
      icon: Icon(
        key: ValueKey(tabName),
        isActivated ? activeIcon : inActiveIcon,
        color: isActivated ? ColorManager.white : ColorManager.grey,
      ),
    );
  }
}
