import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dummy/app_state.dart';
import 'driver_find_jobs_page.dart';
import 'driver_active_job_page.dart';
import 'driver_job_history_page.dart';
import 'driver_profile_page.dart';

class DriverMainNavigationShell extends StatefulWidget {
  final int initialTab;

  const DriverMainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<DriverMainNavigationShell> createState() => _DriverMainNavigationShellState();
}

class _DriverMainNavigationShellState extends State<DriverMainNavigationShell> {
  late int _currentIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pages = [
      const DriverFindJobsPage(),
      const DriverActiveJobPage(),
      const DriverJobHistoryPage(),
      const DriverProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final driverId = appState.currentUser?.id ?? '';

    // Calculate active job count (0 or 1)
    final activeJobCount = appState.orders.where(
      (o) => o.assignedDriverId == driverId && o.status == 'Sedang Dikirim'
    ).length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.neutral,
          selectedLabelStyle: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.primary),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.neutral),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search, color: AppColors.primary),
              label: 'Cari Job',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: activeJobCount > 0 ? Text(activeJobCount.toString()) : null,
                isLabelVisible: activeJobCount > 0,
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.local_shipping_outlined),
              ),
              activeIcon: Badge(
                label: activeJobCount > 0 ? Text(activeJobCount.toString()) : null,
                isLabelVisible: activeJobCount > 0,
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.local_shipping, color: AppColors.primary),
              ),
              label: 'Job Aktif',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history, color: AppColors.primary),
              label: 'Riwayat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
