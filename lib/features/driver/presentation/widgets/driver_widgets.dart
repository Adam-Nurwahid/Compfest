import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';

/// 1. DriverAppBar
class DriverAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSwitch;

  const DriverAppBar({
    super.key,
    required this.title,
    this.showSwitch = true,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isOnline = appState.isDriverOnline;
    final driverName = appState.currentUser?.name ?? 'Kurir SEAPEDIA';

    return AppBar(
      backgroundColor: const Color(0xFF1E293B), // Premium Dark Slate
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DRV MODE',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 9,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Text(
            driverName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        if (showSwitch) ...[
          Row(
            children: [
              Text(
                isOnline ? 'Online' : 'Offline',
                style: AppTextStyles.label.copyWith(
                  fontSize: 12,
                  color: isOnline ? Colors.tealAccent : Colors.white60,
                ),
              ),
              const SizedBox(width: 4),
              Switch(
                value: isOnline,
                onChanged: (val) {
                  appState.toggleDriverOnline();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? 'Status: ONLINE. Siap menerima order!' : 'Status: OFFLINE.'),
                      backgroundColor: val ? AppColors.primary : AppColors.neutral,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                activeColor: Colors.tealAccent,
                activeTrackColor: Colors.teal.withOpacity(0.4),
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.white24,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFF334155),
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 2. JobCard
class JobCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final earning = appState.calculateDriverEarning(order);

    final formattedEarning = earning
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final formattedDeliveryFee = order.deliveryFee
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    Color badgeBg;
    Color badgeText;
    switch (order.deliveryMethod.toLowerCase()) {
      case 'instant':
        badgeBg = const Color(0xFFFFEBE3);
        badgeText = const Color(0xFFE04A1B);
        break;
      case 'next day':
        badgeBg = const Color(0xFFE2F0FD);
        badgeText = const Color(0xFF0F62AC);
        break;
      default:
        badgeBg = const Color(0xFFECEFF1);
        badgeText = const Color(0xFF37474F);
    }

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      color: Colors.white,
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.deliveryMethod,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 18),
                        Container(
                          width: 2,
                          height: 24,
                          color: AppColors.border,
                        ),
                        const Icon(Icons.location_on, color: AppColors.secondary, size: 18),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AMBIL (PICKUP)',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 10,
                              color: AppColors.neutral,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            order.pickupAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'KIRIM (DROPOFF)',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 10,
                              color: AppColors.neutral,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            order.dropoffAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ongkir: Rp$formattedDeliveryFee',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Estimasi Penghasilan Bersih',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rp$formattedEarning',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 18,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. ActiveJobCard
class ActiveJobCard extends StatelessWidget {
  final Order order;
  final VoidCallback onComplete;

  const ActiveJobCard({
    super.key,
    required this.order,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final earning = appState.calculateDriverEarning(order);

    final formattedEarning = earning
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return AppCard(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AKTIF: ${order.id}',
                style: AppTextStyles.label.copyWith(
                  fontSize: 14,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.deliveryMethod,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPainter(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.navigation, color: AppColors.primary, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        'Navigasi Peta Rute Logistik',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 18),
                  Container(
                    width: 2,
                    height: 50,
                    color: AppColors.border,
                  ),
                  const Icon(Icons.location_on, color: AppColors.secondary, size: 18),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALAMAT PENJEMPUTAN (PICKUP)',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                        color: AppColors.neutral,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      order.pickupAddress,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'ALAMAT PENGIRIMAN (DROPOFF)',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                        color: AppColors.neutral,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      order.dropoffAddress,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.tertiary,
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.address.receiverName,
                      style: AppTextStyles.label.copyWith(fontSize: 13),
                    ),
                    Text(
                      order.address.phoneNumber,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.teal),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      content: Text('Menghubungi nomor ${order.address.phoneNumber}...'),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimasi Penghasilan:',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Rp$formattedEarning',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 20,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          AppButton(
            text: 'Konfirmasi Selesai Kirim',
            icon: Icons.check_circle_outline,
            styleType: ButtonStyleType.primary,
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}

/// 4. EarningSummaryCard
class EarningSummaryCard extends StatelessWidget {
  final List<Order> completedJobs;

  const EarningSummaryCard({
    super.key,
    required this.completedJobs,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    int totalEarning = 0;
    for (var order in completedJobs) {
      totalEarning += appState.calculateDriverEarning(order);
    }

    final formattedTotal = totalEarning
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final List<int> dailyEarnings = [
      35000,
      48000,
      20000,
      55000,
      totalEarning > 100000 ? 95000 : 0,
      totalEarning > 0 ? totalEarning : 15000,
      28000
    ];
    final List<String> days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    final maxEarning = dailyEarnings.reduce((curr, next) => curr > next ? curr : next);

    return AppCard(
      color: const Color(0xFF1E293B), // Dark Operational Surface
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PENGHASILAN DRIVER',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp$formattedTotal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.tealAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${completedJobs.length} Jobs',
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white24, height: 32),

          const Text(
            'Statistik Mingguan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (idx) {
              final val = dailyEarnings[idx];
              final day = days[idx];

              final height = maxEarning > 0 ? (val / maxEarning) * 80.0 : 0.0;
              final bool isToday = idx == 5;

              return Column(
                children: [
                  Text(
                    val > 0 ? '${(val / 1000).round()}k' : '-',
                    style: TextStyle(
                      color: isToday ? AppColors.secondary : Colors.white60,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 14,
                    // Perbaikan: Gunakan presisi double (5.0) untuk menghindari num type promotion error
                    height: height < 5.0 ? 5.0 : height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isToday
                            ? [AppColors.secondary, AppColors.secondaryDark]
                            : [AppColors.primaryLight, AppColors.primary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isToday
                          ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day,
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white60,
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Simple painter to simulate map vectors
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.3), paint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    dotPaint.color = AppColors.primary.withOpacity(0.6);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.28), 6, dotPaint);

    dotPaint.color = AppColors.secondary.withOpacity(0.6);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}