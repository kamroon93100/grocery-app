import 'package:flutter/material.dart';

class KohliShimmer extends StatefulWidget {
  final Widget child;
  const KohliShimmer({super.key, required this.child});

  @override
  State<KohliShimmer> createState() => _KohliShimmerState();
}

class _KohliShimmerState extends State<KohliShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _c.value * 2.0, 0),
              end: Alignment(0.0 + _c.value * 2.0, 0),
              colors: const [
                Color(0xffeeeeee),
                Color(0xffffffff),
                Color(0xffeeeeee),
              ],
              stops: const [.25, .5, .75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffeeeeee),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class HomeShimmerSkeleton extends StatelessWidget {
  const HomeShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return KohliShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const SkeletonBox(width: double.infinity, height: 54, radius: 18),
          const SizedBox(height: 18),
          const SkeletonBox(width: double.infinity, height: 165, radius: 30),
          const SizedBox(height: 22),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const Column(
                children: [
                  SkeletonBox(width: 62, height: 62, radius: 20),
                  SizedBox(height: 8),
                  SkeletonBox(width: 54, height: 10, radius: 99),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SkeletonBox(width: 160, height: 22, radius: 99),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 190,
              mainAxisExtent: 262,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (_, __) => const ProductCardSkeleton(),
          ),
        ],
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffeeeeee)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 18)),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 13, radius: 99),
          SizedBox(height: 7),
          SkeletonBox(width: 90, height: 12, radius: 99),
          SizedBox(height: 10),
          SkeletonBox(width: 76, height: 18, radius: 99),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 38, radius: 13),
        ],
      ),
    );
  }
}

class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return KohliShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: const Row(
            children: [
              SkeletonBox(width: 58, height: 58, radius: 16),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: double.infinity, height: 13, radius: 99),
                    SizedBox(height: 8),
                    SkeletonBox(width: 110, height: 12, radius: 99),
                  ],
                ),
              ),
              SizedBox(width: 12),
              SkeletonBox(width: 58, height: 32, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}
