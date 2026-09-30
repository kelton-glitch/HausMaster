import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../auth/domain/manager.dart';
import 'tabs/dashboard_tab.dart';
import '../properties/presentation/properties_screen.dart';
import 'tabs/profile_tab.dart';
import 'tabs/rent_tab.dart';

/// App shell. Phones get a bottom NavigationBar; wider screens (tablets,
/// landscape) get a NavigationRail. Every primary area is one tap away (NFR-08).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.manager});

  final Manager manager;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _wideBreakpoint = 600.0;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      (Icons.home_outlined, Icons.home, l10n.tabDashboard),
      (Icons.apartment_outlined, Icons.apartment, l10n.tabProperties),
      (Icons.receipt_long_outlined, Icons.receipt_long, l10n.tabRent),
      (Icons.person_outline, Icons.person, l10n.tabProfile),
    ];
    // IndexedStack keeps each tab's state (scroll position, etc.) when switching.
    final body = IndexedStack(
      index: _index,
      children: [
        DashboardTab(manager: widget.manager),
        const PropertiesScreen(),
        const RentTab(),
        ProfileTab(manager: widget.manager),
      ],
    );
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Scaffold(
      appBar: AppBar(title: Text(destinations[_index].$3)),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2),
                        label: Text(d.$3),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.$1),
                    selectedIcon: Icon(d.$2),
                    label: d.$3,
                  ),
              ],
            ),
    );
  }
}
