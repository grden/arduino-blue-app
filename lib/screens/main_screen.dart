import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:velocity_x/velocity_x.dart';

import '../utils/theme/color_manager.dart';
import '../utils/tab/tab_item.dart';
import '../utils/tab/tab_navigator.dart';
import '../utils/theme/text_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabItem _currentTab = TabItem.devices;
  List<TabItem> tabs = [TabItem.devices, TabItem.bluetooth];
  final List<GlobalKey<NavigatorState>> navigatorKeys = [];

  int get _currentIndex => tabs.indexOf(_currentTab);

  GlobalKey<NavigatorState> get _currentTabNavigationKey =>
      navigatorKeys[_currentIndex];

  @override
  void initState() {
    super.initState();
    initNavigatorKeys();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: ColorManager.background,
        body: SafeArea(
          // bottom: false,
          child: pages,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  IndexedStack get pages => IndexedStack(
      index: _currentIndex,
      children: tabs
          .mapIndexed((tab, index) => Offstage(
                offstage: _currentTab != tab,
                child: TabNavigator(
                  navigatorKey: navigatorKeys[index],
                  tabItem: tab,
                ),
              ))
          .toList());

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: ColorManager.background,
        border: Border(
          top: BorderSide(
            color: ColorManager.grey,
            width: 0.4,
          ),
        ),
      ),
      child: GNav(
          padding: const EdgeInsets.all(12),
          gap: 8,
          onTabChange: _handleOnTapNavigationBarItem,
          color: ColorManager.grey,
          activeColor: ColorManager.white,
          backgroundColor: ColorManager.background,
          tabBackgroundColor: ColorManager.button,
          iconSize: 24,
          textStyle: TextManager.main19,
          tabs: [
            GButton(
              icon: Icons.favorite,
              text: '상태 모니터',
              borderRadius: BorderRadius.circular(16),
            ),
            GButton(
              icon: Icons.watch,
              text: '기기 연결',
              borderRadius: BorderRadius.circular(16),
            )
          ]),
    );
  }

  List<BottomNavigationBarItem> navigationBarItems(BuildContext context) {
    return tabs
        .mapIndexed(
          (tab, index) => tab.toNavigationBarItem(
            context,
            isActivated: _currentIndex == index,
          ),
        )
        .toList();
  }

  void _changeTab(int index) {
    setState(() {
      _currentTab = tabs[index];
    });
  }

  BottomNavigationBarItem bottomItem(bool activate, IconData iconData,
      IconData inActivateIconData, String label) {
    return BottomNavigationBarItem(
        icon: Icon(
          key: ValueKey(label),
          activate ? iconData : inActivateIconData,
          color: activate ? ColorManager.white : ColorManager.grey,
        ),
        label: label);
  }

  void _handleOnTapNavigationBarItem(int index) {
    final oldTab = _currentTab;
    final targetTab = tabs[index];
    if (oldTab == targetTab) {
      final navigationKey = _currentTabNavigationKey;
      popAllHistory(navigationKey);
    }
    _changeTab(index);
  }

  void popAllHistory(GlobalKey<NavigatorState> navigationKey) {
    final bool canPop = navigationKey.currentState?.canPop() == true;
    if (canPop) {
      while (navigationKey.currentState?.canPop() == true) {
        navigationKey.currentState!.pop();
      }
    }
  }

  void initNavigatorKeys() {
    for (final _ in tabs) {
      navigatorKeys.add(GlobalKey<NavigatorState>());
    }
  }
}
