import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/dummy_data.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _searchQuery = '';
  String _selectedRoleFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    // We can filter dummyUsers based on query and role filter
    final filteredUsers = dummyUsers.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesRole = _selectedRoleFilter == 'Semua' || user.roles.contains(_selectedRoleFilter);

      return matchesSearch && matchesRole;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter & Search Controls
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama, username, atau email...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      fillColor: AppColors.background,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Role Filter Dropdown
                Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRoleFilter,
                      icon: const Icon(Icons.filter_list, color: AppColors.primary),
                      style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedRoleFilter = val;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua Role')),
                        DropdownMenuItem(value: 'Admin', child: Text('Role: Admin')),
                        DropdownMenuItem(value: 'Buyer', child: Text('Role: Buyer')),
                        DropdownMenuItem(value: 'Seller', child: Text('Role: Seller')),
                        DropdownMenuItem(value: 'Driver', child: Text('Role: Driver')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Main Table Card
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Container(
                      color: AppColors.tertiary.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Nama Pengguna', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Username / Email', style: AppTextStyles.label)),
                          Expanded(flex: 3, child: Text('Hak Akses (Roles)', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Role Aktif', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Status', style: AppTextStyles.label)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Table Body
                    Expanded(
                      child: filteredUsers.isEmpty
                          ? const Center(
                              child: EmptyState(
                                title: 'Pengguna Tidak Ditemukan',
                                message: 'Tidak ada pengguna yang cocok dengan kriteria pencarian dan filter Anda.',
                                icon: Icons.people_outline,
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredUsers.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Row(
                                    children: [
                                      // User Name & Initials
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: AppColors.primary.withOpacity(0.1),
                                              foregroundColor: AppColors.primary,
                                              radius: 18,
                                              child: Text(user.name.substring(0, 1).toUpperCase()),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                user.name,
                                                style: AppTextStyles.label.copyWith(fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Username / Email
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('@${user.username}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                            Text(user.email, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                                          ],
                                        ),
                                      ),

                                      // Roles Chips
                                      Expanded(
                                        flex: 3,
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: user.roles.map((r) {
                                            Color chipColor = AppColors.neutral.withOpacity(0.1);
                                            Color textColor = AppColors.neutral;
                                            if (r == 'Admin') {
                                              chipColor = AppColors.secondary.withOpacity(0.15);
                                              textColor = AppColors.secondaryDark;
                                            } else if (r == 'Seller') {
                                              chipColor = Colors.purple.withOpacity(0.1);
                                              textColor = Colors.purple;
                                            } else if (r == 'Driver') {
                                              chipColor = Colors.blue.withOpacity(0.1);
                                              textColor = Colors.blue;
                                            } else if (r == 'Buyer') {
                                              chipColor = AppColors.primary.withOpacity(0.15);
                                              textColor = AppColors.primary;
                                            }
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: chipColor,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                r,
                                                style: AppTextStyles.label.copyWith(fontSize: 11, color: textColor),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),

                                      // Active Role
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          user.activeRole,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),

                                      // Status (Active default since it's mock)
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Aktif', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
