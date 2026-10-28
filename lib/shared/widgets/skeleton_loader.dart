import 'package:flutter/material.dart';

/// Wrapper widget yang memberikan animasi pulsing/shimmer halus
/// pada komponen skeleton di dalamnya.
class SkeletonShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder garis/persegi panjang untuk teks atau baris data.
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLine({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Placeholder lingkaran untuk avatar, icon, atau badge bulat.
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Placeholder kotak/kontainer dengan border radius kustom.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Card container untuk membungkus skeleton item.
class SkeletonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SkeletonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Skeleton lengkap khusus tampilan Dashboard / ChildListScreen.
/// Memberikan preview tata letak yang identik sebelum data Firestore selesai dimuat.
class DashboardSkeletonLoader extends StatelessWidget {
  const DashboardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = 600.0;
          final horizontalPadding = constraints.maxWidth > maxWidth
              ? (constraints.maxWidth - maxWidth) / 2
              : 20.0;

          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Skeleton
                const SkeletonLine(width: 130, height: 24),
                const SizedBox(height: 8),
                const SkeletonLine(width: 220, height: 16),
                const SizedBox(height: 24),

                // Child Card Skeleton
                SkeletonCard(
                  child: Row(
                    children: [
                      const SkeletonCircle(size: 56),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLine(width: 120, height: 20),
                            SizedBox(height: 8),
                            SkeletonLine(width: 160, height: 14),
                            SizedBox(height: 8),
                            SkeletonLine(width: 80, height: 24, borderRadius: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Growth Stats Skeleton (3 Tiles)
                Row(
                  children: const [
                    Expanded(
                      child: SkeletonCard(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            SkeletonCircle(size: 24),
                            SizedBox(height: 8),
                            SkeletonLine(width: 48, height: 18),
                            SizedBox(height: 4),
                            SkeletonLine(width: 32, height: 12),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SkeletonCard(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            SkeletonCircle(size: 24),
                            SizedBox(height: 8),
                            SkeletonLine(width: 48, height: 18),
                            SizedBox(height: 4),
                            SkeletonLine(width: 32, height: 12),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SkeletonCard(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            SkeletonCircle(size: 24),
                            SizedBox(height: 8),
                            SkeletonLine(width: 48, height: 18),
                            SizedBox(height: 4),
                            SkeletonLine(width: 32, height: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Growth Evaluation Banner Skeleton
                SkeletonCard(
                  child: Row(
                    children: [
                      const SkeletonCircle(size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLine(width: 140, height: 16),
                            SizedBox(height: 6),
                            SkeletonLine(width: double.infinity, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Actions Skeleton (2 Action Buttons)
                Row(
                  children: const [
                    Expanded(
                      child: SkeletonCard(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SkeletonCircle(size: 32),
                            SizedBox(height: 10),
                            SkeletonLine(width: 80, height: 14),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SkeletonCard(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SkeletonCircle(size: 32),
                            SizedBox(height: 10),
                            SkeletonLine(width: 80, height: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reminder Card Skeleton
                SkeletonCard(
                  child: Row(
                    children: [
                      const SkeletonCircle(size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLine(width: 90, height: 16),
                            SizedBox(height: 6),
                            SkeletonLine(width: double.infinity, height: 12),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const SkeletonLine(width: 44, height: 24, borderRadius: 12),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
