import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/application_statuses/application_statuses_screen.dart';
import '../../features/applications/applications_screen.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/career_tips/career_tips_screen.dart';
import '../../features/cities/cities_screen.dart';
import '../../features/companies/companies_screen.dart';
import '../../features/countries/countries_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/employment_types/employment_types_screen.dart';
import '../../features/industries/industries_screen.dart';
import '../../features/job_posts/job_posts_screen.dart';
import '../../features/skills/skills_screen.dart';
import '../../features/talent_pool/talent_pool_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final int pageIndex;
  const _NavItem(this.label, this.icon, this.pageIndex);
}

class _NavGroup {
  final String? groupLabel;
  final List<_NavItem> items;
  const _NavGroup({this.groupLabel, required this.items});
}

const _pages = [
  DashboardScreen(),
  AnalyticsScreen(),
  JobPostsScreen(),
  ApplicationsScreen(),
  TalentPoolScreen(),
  CompaniesScreen(),
  IndustriesScreen(),
  EmploymentTypesScreen(),
  SkillsScreen(),
  CountriesScreen(),
  CitiesScreen(),
  ApplicationStatusesScreen(),
  CareerTipsScreen(),
];

const _navGroups = [
  _NavGroup(
    items: [
      _NavItem('Dashboard', Icons.dashboard_outlined, 0),
      _NavItem('Analytics', Icons.bar_chart_outlined, 1),
      _NavItem('Job Posts', Icons.work_outline, 2),
      _NavItem('Candidates', Icons.person_outline, 3),
      _NavItem('Talent Pool', Icons.people_outline, 4),
    ],
  ),
  _NavGroup(
    groupLabel: 'REFERENCE DATA',
    items: [
      _NavItem('Companies', Icons.apartment_outlined, 5),
      _NavItem('Industries', Icons.business_center_outlined, 6),
      _NavItem('Employment Types', Icons.work_history_outlined, 7),
      _NavItem('Skills', Icons.psychology_outlined, 8),
      _NavItem('Countries', Icons.public_outlined, 9),
      _NavItem('Cities', Icons.location_city_outlined, 10),
      _NavItem('Application Statuses', Icons.flag_outlined, 11),
    ],
  ),
  _NavGroup(
    groupLabel: 'CONTENT',
    items: [_NavItem('Career Tips', Icons.lightbulb_outline, 12)],
  ),
];

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedPageIndex = 0;

  Future<void> _confirmLogout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
      isDanger: false,
    );
    if (confirmed && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      body: Row(
        children: [
          _AdminSidebar(
            selectedPageIndex: _selectedPageIndex,
            userEmail: user?.email ?? '',
            onItemSelected: (index) =>
                setState(() => _selectedPageIndex = index),
            onLogout: _confirmLogout,
          ),
          Expanded(
            child: IndexedStack(index: _selectedPageIndex, children: _pages),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final int selectedPageIndex;
  final String userEmail;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const _AdminSidebar({
    required this.selectedPageIndex,
    required this.userEmail,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarHeader(email: userEmail),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final group in _navGroups) ...[
                  if (group.groupLabel != null)
                    _SidebarGroupLabel(label: group.groupLabel!),
                  for (final item in group.items)
                    _SidebarItem(
                      item: item,
                      isSelected: selectedPageIndex == item.pageIndex,
                      onTap: () => onItemSelected(item.pageIndex),
                    ),
                ],
              ],
            ),
          ),
          _SidebarFooter(onLogout: onLogout),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String email;
  const _SidebarHeader({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x33FFFFFF))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.tealMain,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HireMatch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFF99C2C2),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroupLabel extends StatelessWidget {
  final String label;
  const _SidebarGroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.sidebarGroupLabel,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    final hovered = _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.tealMain
                : hovered
                ? AppColors.sidebarHover
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: selected ? Colors.white : const Color(0xFFB0D0D0),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFB0D0D0),
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final VoidCallback onLogout;
  const _SidebarFooter({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
      ),
      child: _SidebarItem(
        item: const _NavItem('Logout', Icons.logout_outlined, -1),
        isSelected: false,
        onTap: onLogout,
      ),
    );
  }
}
