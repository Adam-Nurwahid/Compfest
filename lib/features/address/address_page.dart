import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';
import '../../data/models/models.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDefaultAddress = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showAddressFormDialog(BuildContext context, AppState appState, {Address? editAddr}) {
    final isEdit = editAddr != null;

    if (isEdit) {
      _nameController.text = editAddr.receiverName;
      _phoneController.text = editAddr.phoneNumber;
      _addressController.text = editAddr.fullAddress;
      _isDefaultAddress = editAddr.isDefault;
    } else {
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _isDefaultAddress = appState.addresses.isEmpty; // Force default if it's the first address
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Ubah Alamat Kirim' : 'Tambah Alamat Baru',
                          style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nama Penerima',
                      hintText: 'contoh: Andi Kusuma',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.neutral),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'No. Telepon / HP',
                      hintText: 'contoh: 081234567890',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.neutral),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Alamat Lengkap',
                      hintText: 'Masukkan nama jalan, perumahan, nomor rumah, kecamatan, kota, kode pos...',
                      controller: _addressController,
                      maxLines: 3,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 36.0),
                        child: Icon(Icons.location_on_outlined, color: AppColors.neutral),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Default Switch (disabled if it's currently default and editing, or first item)
                    SwitchListTile(
                      title: Text(
                        'Jadikan Alamat Utama',
                        style: AppTextStyles.label.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Setiap pembelian akan dikirim ke alamat ini secara default.',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                      ),
                      value: _isDefaultAddress,
                      activeColor: AppColors.primary,
                      onChanged: (isEdit && editAddr.isDefault)
                          ? null
                          : (val) {
                              setStateSheet(() {
                                _isDefaultAddress = val;
                              });
                            },
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: isEdit ? 'Simpan Perubahan' : 'Simpan Alamat',
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final phone = _phoneController.text.trim();
                        final fullAddr = _addressController.text.trim();

                        if (name.isEmpty || phone.isEmpty || fullAddr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(duration: const Duration(seconds: 2), 
                              content: Text('Semua kolom formulir harus diisi!'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                          return;
                        }

                        if (isEdit) {
                          final updated = editAddr.copyWith(
                            receiverName: name,
                            phoneNumber: phone,
                            fullAddress: fullAddr,
                            isDefault: _isDefaultAddress,
                          );
                          appState.editAddress(updated);
                        } else {
                          final newAddr = Address(
                            id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                            receiverName: name,
                            phoneNumber: phone,
                            fullAddress: fullAddr,
                            isDefault: _isDefaultAddress,
                          );
                          appState.addAddress(newAddr);
                        }

                        Navigator.pop(context); // Close bottomsheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(duration: const Duration(seconds: 2), 
                            content: Text(
                              isEdit ? 'Alamat berhasil diubah.' : 'Alamat baru berhasil ditambahkan.',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Atur Alamat Kirim',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () => _showAddressFormDialog(context, appState),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: appState.addresses.isEmpty
                  ? EmptyState(
                      title: 'Alamat Masih Kosong',
                      message: 'Silakan tambahkan alamat pengiriman Anda untuk mempermudah transaksi.',
                      icon: Icons.map_outlined,
                      buttonText: 'Tambah Alamat',
                      onButtonPressed: () => _showAddressFormDialog(context, appState),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: appState.addresses.length,
                      itemBuilder: (context, index) {
                        final addr = appState.addresses[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: AppCard(
                            padding: const EdgeInsets.all(18),
                            color: addr.isDefault ? AppColors.tertiary.withOpacity(0.2) : AppColors.surface,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.receiverName,
                                      style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    if (addr.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Utama',
                                          style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.primary),
                                        ),
                                      ),
                                    const Spacer(),
                                    // Edit button
                                    IconButton(
                                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                                      onPressed: () => _showAddressFormDialog(context, appState, editAddr: addr),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(width: 12),
                                    // Delete button (hide if it is default)
                                    if (!addr.isDefault)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                        onPressed: () {
                                          appState.deleteAddress(addr.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(duration: const Duration(seconds: 2), content: Text('Alamat berhasil dihapus.')),
                                          );
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  addr.phoneNumber,
                                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.neutral),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  addr.fullAddress,
                                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                                ),
                                if (!addr.isDefault) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      textStyle: AppTextStyles.label.copyWith(fontSize: 11),
                                    ),
                                    onPressed: () {
                                      appState.setDefaultAddress(addr.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(duration: const Duration(seconds: 2), content: Text('Alamat utama berhasil diubah.')),
                                      );
                                    },
                                    child: const Text('Jadikan Utama'),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
