import 'package:compfest/data/dummy/app_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

/// 1. AppButton
/// Custom button with primary, secondary, outline, and loading state.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonStyleType styleType;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.styleType = ButtonStyleType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle;
    Color textColor;

    switch (styleType) {
      case ButtonStyleType.primary:
        buttonStyle = AppButtonStyles.primary;
        textColor = Colors.white;
        break;
      case ButtonStyleType.secondary:
        buttonStyle = AppButtonStyles.secondary;
        textColor = AppColors.textPrimary;
        break;
      case ButtonStyleType.inverted:
        buttonStyle = AppButtonStyles.inverted;
        textColor = Colors.white;
        break;
      case ButtonStyleType.outlined:
        buttonStyle = AppButtonStyles.outlined;
        textColor = AppColors.textPrimary;
        break;
    }

    // Disable styling if onPressed is null or isLoading
    final isButtonEnabled = onPressed != null && !isLoading;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                styleType == ButtonStyleType.outlined || styleType == ButtonStyleType.secondary
                    ? AppColors.primary
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTextStyles.label.copyWith(color: isButtonEnabled ? textColor : AppColors.neutral.withOpacity(0.6)),
        ),
      ],
    );

    Widget btn;
    if (styleType == ButtonStyleType.outlined) {
      btn = OutlinedButton(
        style: buttonStyle,
        onPressed: isButtonEnabled ? onPressed : null,
        child: buttonContent,
      );
    } else {
      btn = ElevatedButton(
        style: buttonStyle,
        onPressed: isButtonEnabled ? onPressed : null,
        child: buttonContent,
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: btn,
      );
    }
    return btn;
  }
}

enum ButtonStyleType { primary, secondary, inverted, outlined }

/// 2. AppTextField
/// Input field with labels, error text, prefix/suffix icons.
class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// 3. AppCard
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius ?? 16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius ?? 16),
        child: content,
      );
    }
    return content;
  }
}

/// 4. RatingStars
/// Simple star display, also interactive for feedback forms.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final void Function(double)? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18.0,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double starValue = index + 1.0;
        IconData iconData;
        Color color;

        if (rating >= starValue) {
          iconData = Icons.star_rounded;
          color = Colors.amber;
        } else if (rating >= starValue - 0.5) {
          iconData = Icons.star_half_rounded;
          color = Colors.amber;
        } else {
          iconData = Icons.star_border_rounded;
          color = AppColors.neutral.withOpacity(0.4);
        }

        Widget star = Icon(iconData, size: size, color: color);

        if (interactive && onRatingChanged != null) {
          return GestureDetector(
            onTap: () => onRatingChanged!(starValue),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: star,
            ),
          );
        }

        return star;
      }),
    );
  }
}

/// 5. StatusBadge
/// Visual colored status badge for orders.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Sedang Dikemas':
        bgColor = AppColors.tertiary;
        textColor = AppColors.primary;
        break;
      case 'Menunggu Pengirim':
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        break;
      case 'Sedang Dikirim':
        bgColor = const Color(0xFFCCE5FF);
        textColor = const Color(0xFF004085);
        break;
      case 'Pesanan Selesai':
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        break;
      case 'Dikembalikan':
        bgColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        break;
      default:
        bgColor = AppColors.border;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: AppTextStyles.label.copyWith(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }
}

/// 6. CustomAppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPress;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
        onPressed: onBackPress ?? () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
            try {
              final appState = Provider.of<AppState>(context, listen: false);
              final role = appState.activeRole.toLowerCase();
              if (role == 'seller') {
                context.go('/seller/dashboard');
              } else if (role == 'driver') {
                context.go('/driver/find-jobs');
              } else if (role == 'admin') {
                context.go('/admin/dashboard');
              } else {
                context.go('/landing');
              }
            } catch (_) {
              context.go('/landing');
            }
          }
        },
      )
          : null,
      title: Text(
        title,
        style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.border,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 7. EmptyState
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 32),
            AppButton(
              text: buttonText!,
              onPressed: onButtonPressed,
              isFullWidth: false,
              styleType: ButtonStyleType.primary,
            ),
          ],
        ],
      ),
    ),
  );
}
}

/// 8. OrderStatusTimeline
class OrderStatusTimeline extends StatelessWidget {
  final List<dynamic> milestones; // list of OrderMilestone
  final String currentStatus;

  const OrderStatusTimeline({
    super.key,
    required this.milestones,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Standard ordered lifecycle status list
    final List<String> orderedStatuses = [
      'Sedang Dikemas',
      'Menunggu Pengirim',
      'Sedang Dikirim',
      'Pesanan Selesai'
    ];

    // Check if status is "Dikembalikan" (refund)
    final bool isRefunded = currentStatus == 'Dikembalikan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline Pengiriman',
          style: AppTextStyles.label.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),
        if (isRefunded) ...[
          // For refunded, show a custom step indicating return
          _buildTimelineNode(
            title: 'Dikembalikan',
            description: 'Pesanan dibatalkan/dikembalikan ke penjual dan saldo direfund.',
            timestamp: milestones.isNotEmpty ? milestones.last.timestamp : DateTime.now(),
            isActive: true,
            isLast: true,
            isError: true,
          ),
        ] else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderedStatuses.length,
            itemBuilder: (context, index) {
              final status = orderedStatuses[index];

              // Check if this status is achieved in milestones
              final milestoneIndex = milestones.indexWhere((m) => m.status == status);
              final isAchieved = milestoneIndex != -1;
              final timestamp = isAchieved ? milestones[milestoneIndex].timestamp : null;
              final description = isAchieved
                  ? milestones[milestoneIndex].description
                  : _getDefaultDescription(status);

              // Decide if it's the current/active point in execution
              final isCurrent = currentStatus == status;
              final isActive = isAchieved || orderedStatuses.indexOf(currentStatus) >= index;

              return _buildTimelineNode(
                title: status,
                description: description,
                timestamp: timestamp,
                isActive: isActive,
                isCurrent: isCurrent,
                isLast: index == orderedStatuses.length - 1,
              );
            },
          ),
        ]
      ],
    );
  }

  String _getDefaultDescription(String status) {
    switch (status) {
      case 'Sedang Dikemas':
        return 'Penjual sedang mengemas barang pesanan Anda.';
      case 'Menunggu Pengirim':
        return 'Kurir akan mengambil paket dari penjual.';
      case 'Sedang Dikirim':
        return 'Paket sedang dibawa kurir menuju alamat Anda.';
      case 'Pesanan Selesai':
        return 'Paket tiba di tujuan dan diterima pembeli.';
      default:
        return '';
    }
  }

  Widget _buildTimelineNode({
    required String title,
    required String description,
    required DateTime? timestamp,
    required bool isActive,
    bool isCurrent = false,
    required bool isLast,
    bool isError = false,
  }) {
    Color nodeColor = AppColors.neutral.withOpacity(0.3);
    if (isActive) nodeColor = AppColors.primary;
    if (isCurrent) nodeColor = AppColors.secondary;
    if (isError) nodeColor = AppColors.danger;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator line + circle
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isCurrent || isError ? nodeColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: nodeColor,
                    width: isCurrent || isError ? 1.0 : 3.0,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.label.copyWith(
                          color: isActive ? AppColors.textPrimary : AppColors.neutral.withOpacity(0.6),
                          fontSize: 15,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      if (timestamp != null)
                        Text(
                          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} - ${timestamp.day}/${timestamp.month}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                            color: AppColors.neutral.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: isActive ? AppColors.textPrimary.withOpacity(0.8) : AppColors.neutral.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer Skeleton Placeholder for image/text loadings
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8.0,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: const [
                Color(0xFFEBEBEB),
                Color(0xFFF4F4F4),
                Color(0xFFEBEBEB),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(_animation.value - 1, -0.3),
              end: Alignment(_animation.value + 1, 0.3),
            ),
          ),
        );
      },
    );
  }
}
