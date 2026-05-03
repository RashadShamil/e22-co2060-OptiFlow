import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/app_theme.dart';

/// A reusable shimmer skeleton block — drop-in replacement while loading.
class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerCard({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.radius = AppTheme.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEEEEE),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Pre-built grid of shimmer cards for the Machine Shop loading state.
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => const ShimmerCard(height: 160),
          childCount: 6,
        ),
      ),
    );
  }
}

/// Pre-built list of shimmer cards for task/job loading states.
class ShimmerList extends StatelessWidget {
  final int count;
  final double cardHeight;
  const ShimmerList({super.key, this.count = 4, this.cardHeight = 110});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerCard(height: cardHeight),
          ),
          childCount: count,
        ),
      ),
    );
  }
}
