import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';

class SpendingReportPage extends StatelessWidget {
  const SpendingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Calculate sum of active/placed orders
    final totalSpent = appState.orders.fold(0, (sum, order) => sum + order.finalTotal);
    final formattedTotalSpent = totalSpent
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    // Aggregate monthly spending (historical mock points + live June orders)
    // Assume current year is 2026
    int juneSpent = totalSpent; // Live orders sum
    final List<MonthlySpending> monthlyData = [
      MonthlySpending(month: 'Jan', amount: 1500000),
      MonthlySpending(month: 'Feb', amount: 800000),
      MonthlySpending(month: 'Mar', amount: 2400000),
      MonthlySpending(month: 'Apr', amount: 1800000),
      MonthlySpending(month: 'Mei', amount: 3200000),
      MonthlySpending(month: 'Jun', amount: juneSpent),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Laporan Pengeluaran',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Spending Summary Box
              AppCard(
                color: AppColors.primary,
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL PENGELUARAN (SEMUA WAKTU)',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rp$formattedTotalSpent',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Akumulasi dari ${appState.orders.length} pesanan aktif.',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // spending chart card
              Text(
                'Grafik Pengeluaran Bulanan (2026)',
                style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: SpendingChartPainter(monthlyData),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pembelian Kelautan (Rp)',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Transaction List Header
              Text(
                'Transaksi Pembelian',
                style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // List of orders representing transactions
              appState.orders.isEmpty
                  ? const EmptyState(
                      title: 'Tidak Ada Transaksi',
                      message: 'Selesaikan transaksi di checkout untuk mencatat pengeluaran Anda.',
                      icon: Icons.bar_chart_outlined,
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appState.orders.length,
                      itemBuilder: (context, index) {
                        final order = appState.orders[index];
                        final formattedPrice = order.finalTotal
                            .toString()
                            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

                        // Timestamp format
                        // In dummy, order has statusTimeline. For simplicity get first
                        final date = order.statusTimeline.isNotEmpty
                            ? order.statusTimeline.first.timestamp
                            : DateTime.now();

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: AppCard(
                            padding: const EdgeInsets.all(14),
                            onTap: () {
                              context.push('/order/${order.id}');
                            },
                            child: Row(
                              children: [
                                // Left Icon container
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Middle Store & Items summary
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.storeName,
                                        style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${date.day}/${date.month}/${date.year}  •  ${order.items.length} item',
                                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right price
                                Text(
                                  'Rp$formattedPrice',
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 14,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class MonthlySpending {
  final String month;
  final int amount;

  MonthlySpending({required this.month, required this.amount});
}

/// Custom line chart painter simulating modern statistics layout
class SpendingChartPainter extends CustomPainter {
  final List<MonthlySpending> data;

  SpendingChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintGradient = Paint()
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = AppColors.border.withOpacity(0.7)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Padding inside canvas
    const double paddingLeft = 48.0;
    const double paddingRight = 16.0;
    const double paddingTop = 16.0;
    const double paddingBottom = 24.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    // Find max value for Y-scaling
    int maxAmount = 1000000;
    for (var d in data) {
      if (d.amount > maxAmount) {
        maxAmount = d.amount;
      }
    }
    // Round max Y up to look clean
    maxAmount = ((maxAmount / 1000000).ceil() * 1000000);

    // Draw horizontal grid lines (Y-axis lines)
    const int gridRows = 4;
    for (int i = 0; i <= gridRows; i++) {
      final double y = paddingTop + chartHeight - (chartHeight / gridRows * i);
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(paddingLeft + chartWidth, y),
        paintGrid,
      );

      // Y-axis label text
      final int amountLabel = (maxAmount / gridRows * i).round();
      String labelText;
      if (amountLabel >= 1000000) {
        labelText = '${(amountLabel / 1000000).toStringAsFixed(1)}Jt';
      } else {
        labelText = '${(amountLabel / 1000).round()}rb';
      }

      textPainter.text = TextSpan(
        text: labelText,
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: AppColors.neutral),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Coordinates points list
    final List<Offset> points = [];
    final double stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final double x = paddingLeft + (stepX * i);
      // Math: Y grows downwards in Flutter coordinates
      final double percentY = d.amount / maxAmount;
      final double y = paddingTop + chartHeight - (chartHeight * percentY);
      points.add(Offset(x, y));

      // Draw X-axis label (months)
      textPainter.text = TextSpan(
        text: d.month,
        style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.textPrimary),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, paddingTop + chartHeight + 6),
      );
    }

    // Draw the spending line pathway
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      // Draw standard smooth curves using cubic Beziers
      final pPrev = points[i - 1];
      final pCurr = points[i];
      final controlPoint1 = Offset(pPrev.dx + (pCurr.dx - pPrev.dx) / 2, pPrev.dy);
      final controlPoint2 = Offset(pPrev.dx + (pCurr.dx - pPrev.dx) / 2, pCurr.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, pCurr.dx, pCurr.dy);
    }
    canvas.drawPath(path, paintLine);

    // Draw gradient overlay underneath the curve
    final gradientPath = Path.from(path);
    gradientPath.lineTo(points.last.dx, paddingTop + chartHeight);
    gradientPath.lineTo(points.first.dx, paddingTop + chartHeight);
    gradientPath.close();

    final gradient = LinearGradient(
      colors: [AppColors.secondary.withOpacity(0.3), AppColors.secondary.withOpacity(0.0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    paintGradient.shader = gradient.createShader(
      Rect.fromLTRB(paddingLeft, paddingTop, paddingLeft + chartWidth, paddingTop + chartHeight),
    );
    canvas.drawPath(gradientPath, paintGradient);

    // Draw coordinate circle dots
    final paintDots = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final paintDotsBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var pt in points) {
      canvas.drawCircle(pt, 5.0, paintDots);
      canvas.drawCircle(pt, 5.0, paintDotsBorder);
    }
  }

  @override
  bool shouldRepaint(covariant SpendingChartPainter oldDelegate) => true;
}
