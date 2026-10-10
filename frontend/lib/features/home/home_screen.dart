import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../auth/domain/manager.dart';
import '../bills/presentation/bills_screen.dart';
import '../ledger/presentation/ledger_screen.dart';
import '../notifications/presentation/notifications_screen.dart';
import '../payments/presentation/payments_screen.dart';
import '../properties/presentation/properties_screen.dart';
import '../reports/presentation/reports_screen.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';

/// App shell. Phones get a bottom NavigationBar with the five daily areas;
/// the rest (bills, reports, notifications) live in the menu drawer and behind
/// the bell, so every area is at most two taps away (NFR-08). Wider screens
/// get a NavigationRail.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.manager});

  final Manager manager;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _wideBreakpoint = 600.0;
  int _index = 0;

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      (Icons.dashboard_outlined, Icons.dashboard, l10n.tabDashboard),
      (Icons.apartment_outlined, Icons.apartment, l10n.tabProperties),
      (Icons.payments_outlined, Icons.payments, l10n.tabPayments),
      (Icons.account_balance_outlined, Icons.account_balance, l10n.tabLedger),
      (Icons.person_outline, Icons.person, l10n.tabProfile),
    ];
    // IndexedStack keeps each tab's state (scroll position, etc.) when switching.
    final body = IndexedStack(
      index: _index,
      children: [
        DashboardTab(manager: widget.manager),
        const PropertiesScreen(),
        const PaymentsScreen(),
        const LedgerScreen(),
        ProfileTab(manager: widget.manager),
      ],
    );
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: Text(destinations[_index].$3),
        actions: [
          IconButton(
            tooltip: l10n.notifications,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _push(const NotificationsScreen()),
          ),
          const SizedBox(width: Spacing.xs),
        ],
      ),
      drawer: _MenuDrawer(
        manager: widget.manager,
        onOpen: _push,
        billsLabel: l10n.tabBills,
        reportsLabel: l10n.tabReports,
        notificationsLabel: l10n.tabNotifications,
      ),
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

class _MenuDrawer extends StatelessWidget {
  const _MenuDrawer({
    required this.manager,
    required this.onOpen,
    required this.billsLabel,
    required this.reportsLabel,
    required this.notificationsLabel,
  });

  final Manager manager;
  final void Function(Widget screen) onOpen;
  final String billsLabel;
  final String reportsLabel;
  final String notificationsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    void open(Widget screen) {
      Navigator.of(context).pop(); // close the drawer first
      onOpen(screen);
    }

    return Drawer(
      backgroundColor: scheme.surfaceContainerLowest,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.field),
                    ),
                    child: SizedBox.square(
                      dimension: 44,
                      child: Icon(Icons.home_outlined, color: scheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HausMaster',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          manager.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(billsLabel),
              onTap: () => open(const BillsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: Text(reportsLabel),
              onTap: () => open(const ReportsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(notificationsLabel),
              onTap: () => open(const NotificationsScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
