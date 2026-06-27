import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';

class AdminPromosPage extends StatefulWidget {
  const AdminPromosPage({super.key});

  @override
  State<AdminPromosPage> createState() => _AdminPromosPageState();
}

class _AdminPromosPageState extends State<AdminPromosPage> {
  String _searchQuery = '';
  String _statusFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final promos = appState.promos;

    // Filter promos
    final filteredPromos = promos.where((p) {
      final matchesSearch = p.code.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final isExpired = p.expiryDate.isBefore(DateTime.now());
      final isActive = !isExpired;

      bool matchesStatus = true;
      if (_statusFilter == 'Aktif') {
        matchesStatus = isActive;
      } else if (_statusFilter == 'Expired') {
        matchesStatus = isExpired;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action & Filter Bar
          Row(
            children: [
              // Search
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari kode promo...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      fillColor: AppColors.background,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              ),
              const SizedBox(width: 16),

              // Filter Dropdown
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
                    value: _statusFilter,
                    icon: const Icon(Icons.filter_list, color: AppColors.primary),
                    style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _statusFilter = val;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua Status')),
                      DropdownMenuItem(value: 'Aktif', child: Text('Status: Aktif')),
                      DropdownMenuItem(value: 'Expired', child: Text('Status: Expired')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Add/Generate Button
              ElevatedButton.icon(
                onPressed: () => _showGeneratePromoDialog(context, appState),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Buat Promo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Promos Table
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      color: AppColors.tertiary.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text('Kode Promo / Aturan', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Nominal Potongan', style: AppTextStyles.label)),
                          Expanded(flex: 3, child: Text('Tanggal Kedaluwarsa', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Status', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Aksi', style: AppTextStyles.label)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Body List
                    Expanded(
                      child: filteredPromos.isEmpty
                          ? const Center(
                              child: EmptyState(
                                title: 'Promo Tidak Ditemukan',
                                message: 'Belum ada program promo atau tidak ada yang sesuai dengan pencarian Anda.',
                                icon: Icons.campaign_outlined,
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredPromos.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final p = filteredPromos[index];
                                final isExpired = p.expiryDate.isBefore(DateTime.now());

                                String statusStr = 'Aktif';
                                Color statusColor = Colors.green;
                                if (isExpired) {
                                  statusStr = 'Expired';
                                  statusColor = AppColors.danger;
                                }

                                final discountStr = p.isPercentage
                                    ? '${p.discountAmount}%'
                                    : 'Rp${p.discountAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

                                final expiryStr = DateFormat('dd MMM yyyy, HH:mm').format(p.expiryDate);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Row(
                                    children: [
                                      // Code
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          p.code,
                                          style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.primary),
                                        ),
                                      ),

                                      // Discount Amount
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          discountStr,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),

                                      // Expiry
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          expiryStr,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isExpired ? AppColors.danger : AppColors.textPrimary,
                                            fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),

                                      // Status Badge
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              statusStr,
                                              style: AppTextStyles.label.copyWith(fontSize: 11, color: statusColor),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Detail Action
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton(
                                            onPressed: () => _showPromoDetailDialog(context, p),
                                            child: const Text('Detail'),
                                          ),
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

  void _showPromoDetailDialog(BuildContext context, Promo promo) {
    showDialog(
      context: context,
      builder: (context) {
        final isExpired = promo.expiryDate.isBefore(DateTime.now());
        final discountStr = promo.isPercentage
            ? '${promo.discountAmount}%'
            : 'Rp${promo.discountAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Detail Promo: ${promo.code}', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Kode Promo:', promo.code),
              _buildDetailRow('Tipe Potongan:', promo.isPercentage ? 'Persentase (%)' : 'Nominal Tetap (Rp)'),
              _buildDetailRow('Jumlah Diskon:', discountStr),
              _buildDetailRow('Tanggal Kedaluwarsa:', DateFormat('dd MMMM yyyy, HH:mm').format(promo.expiryDate)),
              _buildDetailRow('Status:', isExpired ? 'Kedaluwarsa (Expired)' : 'Aktif'),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.neutral),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showGeneratePromoDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final discountController = TextEditingController();
    
    bool isPercentage = false;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 14));
    TimeOfDay selectedTime = const TimeOfDay(hour: 23, minute: 59);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Generate Promo Baru'),
              content: SizedBox(
                width: 450,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Code
                        TextFormField(
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Kode Promo',
                            hintText: 'CONTOH: SHIPFREE',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Kode wajib diisi';
                            if (val.trim().length < 3) return 'Minimal 3 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Discount Type Toggle
                        Row(
                          children: [
                            const Text('Tipe Diskon:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            ChoiceChip(
                              label: const Text('Rupiah (Rp)'),
                              selected: !isPercentage,
                              onSelected: (selected) {
                                if (selected) setStateDialog(() => isPercentage = false);
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Persentase (%)'),
                              selected: isPercentage,
                              onSelected: (selected) {
                                if (selected) setStateDialog(() => isPercentage = true);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Discount Amount
                        TextFormField(
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isPercentage ? 'Nominal Potongan (%)' : 'Nominal Potongan (Rp)',
                            hintText: isPercentage ? 'Contoh: 10' : 'Contoh: 20000',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Nominal wajib diisi';
                            final numVal = int.tryParse(val.trim());
                            if (numVal == null || numVal <= 0) return 'Masukkan angka positif';
                            if (isPercentage && numVal > 100) return 'Maksimal persentase 100%';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Expiry Date picker
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Kedaluwarsa (Expiry):', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            DateFormat('dd MMMM yyyy').format(selectedDate) + ' pukul ${selectedTime.format(context)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.calendar_month, color: AppColors.primary),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setStateDialog(() => selectedDate = picked);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.access_time, color: AppColors.primary),
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (picked != null) {
                                    setStateDialog(() => selectedTime = picked);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final expiryDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final newPromo = Promo(
                        code: codeController.text.trim().toUpperCase(),
                        discountAmount: int.parse(discountController.text.trim()),
                        isPercentage: isPercentage,
                        expiryDate: expiryDateTime,
                      );

                      appState.addPromo(newPromo);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(duration: const Duration(seconds: 2), content: Text('Promo ${newPromo.code} berhasil dibuat!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
