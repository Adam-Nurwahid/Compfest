import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';
import '../bloc/seller_bloc.dart';
import '../bloc/seller_event.dart';
import '../bloc/seller_state.dart';
import 'seller_widgets.dart';

class SellerStorePage extends StatefulWidget {
  const SellerStorePage({super.key});

  @override
  State<SellerStorePage> createState() => _SellerStorePageState();
}

class _SellerStorePageState extends State<SellerStorePage> {
  bool _isEditing = false;
  bool _isCreating = false;

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedLogoUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=100&auto=format&fit=crop';

  final List<Map<String, String>> _mockLogos = [
    {
      'name': 'Diving Blue',
      'url': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=100&auto=format&fit=crop',
    },
    {
      'name': 'Sailing Wind',
      'url': 'https://images.unsplash.com/photo-1505244208262-19137ac24634?w=100&auto=format&fit=crop',
    },
    {
      'name': 'Fishing Rod',
      'url': 'https://images.unsplash.com/photo-1517462964-21fdcec3f25b?w=100&auto=format&fit=crop',
    },
    {
      'name': 'Ocean Coral',
      'url': 'https://images.unsplash.com/photo-1546026423-cc4642628d2b?w=100&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.currentUser != null) {
        context.read<SellerBloc>().add(LoadStore(appState.currentUser!.id));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initForm(Store? store) {
    if (store != null) {
      _nameController.text = store.name;
      _locationController.text = store.location;
      _descriptionController.text = store.description;
      _selectedLogoUrl = store.logoUrl;
    } else {
      _nameController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _selectedLogoUrl = _mockLogos.first['url']!;
    }
  }

  void _saveStore(AppState appState, Store? currentStore) {
    final storeName = _nameController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (storeName.isEmpty || location.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: const Duration(seconds: 2), 
          content: Text('Semua kolom formulir harus diisi!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (storeName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: const Duration(seconds: 2), 
          content: Text('Nama Toko minimal 3 karakter!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.read<SellerBloc>().add(
      SaveStore(
        sellerId: appState.currentUser!.id,
        storeId: currentStore?.id,
        name: storeName,
        location: location,
        description: description,
        logoUrl: _selectedLogoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return BlocConsumer<SellerBloc, SellerState>(
      listener: (context, state) {
        if (state is StoreSavedState) {
          // Sync with AppState to update local store cache
          appState.updateStore(state.store);
          if (appState.currentUserStore == null) {
            appState.createStore(state.store);
            appState.addRoleLocallyAndSwitch('Seller');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(duration: const Duration(seconds: 2), 
              content: Text('Toko berhasil disimpan!'),
              backgroundColor: AppColors.primary,
            ),
          );
          setState(() {
            _isEditing = false;
            _isCreating = false;
          });
        }
        if (state is StoreError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(duration: const Duration(seconds: 2), 
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        if (state is StoreLoaded) {
          final store = state.store;
          if (store != null) {
            final existing = appState.currentUserStore;
            if (existing == null) {
              appState.createStore(store);
            } else {
              appState.updateStore(store);
            }
          }
        }
      },
      builder: (context, state) {
        Store? currentStore;
        if (state is StoreLoaded) {
          currentStore = state.store;
        } else if (state is StoreSavedState) {
          currentStore = state.store;
        } else {
          currentStore = appState.currentUserStore;
        }

        final isFormActive = _isCreating || _isEditing || currentStore == null;
        final isLoading = state is StoreLoading;

        if (isFormActive) {
          if (_nameController.text.isEmpty && !_isCreating && !_isEditing && currentStore == null) {
            _isCreating = true;
            _initForm(null);
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: SellerAppBar(
              title: currentStore == null ? 'Buat Toko Baru' : 'Edit Toko',
              store: currentStore,
            ),
            body: SafeArea(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStore == null
                                ? 'Lengkapi info di bawah untuk membuat Toko kelautan Anda.'
                                : 'Perbarui info profil toko kelautan Anda.',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 24),

                          // Store Name
                          AppTextField(
                            label: 'Nama Toko',
                            hintText: 'contoh: Blue Water Tackle',
                            controller: _nameController,
                          ),
                          const SizedBox(height: 20),

                          // Location
                          AppTextField(
                            label: 'Lokasi Toko (Kota)',
                            hintText: 'contoh: Jakarta Utara, Bali, dsb.',
                            controller: _locationController,
                          ),
                          const SizedBox(height: 20),

                          // Description
                          AppTextField(
                            label: 'Deskripsi Toko',
                            hintText: 'Jelaskan produk dan layanan kelautan unggulan Anda...',
                            controller: _descriptionController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),

                          // Logo Selector (Dummy Image Picker)
                          Text(
                            'Pilih Logo Toko (Demo)',
                            style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _mockLogos.length,
                              itemBuilder: (context, index) {
                                final logo = _mockLogos[index];
                                final isSelected = _selectedLogoUrl == logo['url'];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedLogoUrl = logo['url']!;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: Image.network(
                                        logo['url']!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Submit Actions
                          AppButton(
                            text: currentStore == null ? 'Buat Toko Sekarang' : 'Simpan Perubahan',
                            onPressed: () => _saveStore(appState, currentStore),
                          ),
                          const SizedBox(height: 12),
                          if (currentStore != null)
                            AppButton(
                              text: 'Batal',
                              styleType: ButtonStyleType.outlined,
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _isCreating = false;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
            ),
          );
        }

    final store = currentStore;
    final productsCount = dummyProducts.where((p) => p.storeId == store.id).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SellerAppBar(
        title: 'Profil Toko Saya',
        store: store,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              _initForm(currentStore);
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              AppCard(
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        store.logoUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.tertiary.withOpacity(0.3),
                          child: const Icon(Icons.broken_image_outlined, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: AppTextStyles.label.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.neutral),
                              const SizedBox(width: 4),
                              Text(
                                store.location,
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${store.rating}',
                                style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$productsCount Produk Aktif',
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description Section
              Text(
                'Deskripsi Toko',
                style: AppTextStyles.label.copyWith(fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    store.description,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action button to edit
              AppButton(
                text: 'Edit Informasi Toko',
                icon: Icons.edit_outlined,
                onPressed: () {
                  _initForm(currentStore);
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
