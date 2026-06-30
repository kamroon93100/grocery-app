import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../app/theme/theme.dart';

/// ═══════════════════════════════════════════════════════
/// 🎬 ANIMATED REVEAL LOADER
/// Inspired by theme toggle reveal effects
/// 5 variants: circle, rectangle, polygon, blur, gif
/// ═══════════════════════════════════════════════════════

enum RevealVariant {
  circleCenter,
  circleCorner,
  rectangleBottomUp,
  rectangleLeftRight,
  polygonDiagonal,
  blurRipple,
  liquidFill,
}

class RevealLoader extends StatefulWidget {
  final RevealVariant variant;
  final Duration      duration;
  final Color         color;
  final Color         backgroundColor;
  final String?       logoPath;
  final bool          loop;

  const RevealLoader({
    super.key,
    this.variant         = RevealVariant.liquidFill,
    this.duration        = const Duration(milliseconds: 2000),
    this.color           = AppColors.primary,
    this.backgroundColor = Colors.white,
    this.logoPath        = 'assets/images/logo.png',
    this.loop            = true,
  });

  @override
  State<RevealLoader> createState() => _RevealLoaderState();
}

class _RevealLoaderState extends State<RevealLoader>
    with TickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    if (widget.loop) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          size:    const Size(double.infinity, double.infinity),
          painter: _RevealPainter(
            progress:        _anim.value,
            variant:         widget.variant,
            color:           widget.color,
            backgroundColor: widget.backgroundColor,
          ),
          child: Center(
            child: widget.logoPath != null
                ? Container(
                    width:  120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius:   30 * _anim.value,
                          spreadRadius: 5 * _anim.value),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(widget.logoPath!,
                        fit: BoxFit.contain),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _RevealPainter extends CustomPainter {
  final double         progress;
  final RevealVariant  variant;
  final Color          color;
  final Color          backgroundColor;

  _RevealPainter({
    required this.progress,
    required this.variant,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final bgPaint = Paint()..color = backgroundColor;

    canvas.drawRect(Offset.zero & size, bgPaint);

    switch (variant) {
      case RevealVariant.circleCenter:
        _paintCircleCenter(canvas, size, paint);
        break;
      case RevealVariant.circleCorner:
        _paintCircleCorner(canvas, size, paint);
        break;
      case RevealVariant.rectangleBottomUp:
        _paintRectangleBottomUp(canvas, size, paint);
        break;
      case RevealVariant.rectangleLeftRight:
        _paintRectangleLeftRight(canvas, size, paint);
        break;
      case RevealVariant.polygonDiagonal:
        _paintPolygonDiagonal(canvas, size, paint);
        break;
      case RevealVariant.blurRipple:
        _paintBlurRipple(canvas, size, paint);
        break;
      case RevealVariant.liquidFill:
        _paintLiquidFill(canvas, size, paint);
        break;
    }
  }

  void _paintCircleCenter(Canvas canvas, Size size, Paint paint) {
    final center  = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height) / 2;
    canvas.drawCircle(center, maxRadius * progress, paint);
  }

  void _paintCircleCorner(Canvas canvas, Size size, Paint paint) {
    const corner = Offset(0, 0);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height);
    canvas.drawCircle(corner, maxRadius * progress, paint);
  }

  void _paintRectangleBottomUp(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromLTWH(
      0,
      size.height - (size.height * progress),
      size.width,
      size.height * progress);
    canvas.drawRect(rect, paint);
  }

  void _paintRectangleLeftRight(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromLTWH(
      0, 0, size.width * progress, size.height);
    canvas.drawRect(rect, paint);
  }

  void _paintPolygonDiagonal(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final p = progress;

    path.moveTo(0, 0);
    path.lineTo(w * p, 0);
    path.lineTo(0, h * p);
    path.close();

    path.moveTo(w, h);
    path.lineTo(w - (w * p), h);
    path.lineTo(w, h - (h * p));
    path.close();

    canvas.drawPath(path, paint);
  }

  void _paintBlurRipple(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);

    // Multiple ripples
    for (int i = 0; i < 4; i++) {
      final rippleProgress = ((progress + i * 0.25) % 1.0);
      final radius = (math.min(size.width, size.height) / 2) * rippleProgress;
      final opacity = (1.0 - rippleProgress).clamp(0.0, 1.0);

      final ripplePaint = Paint()
        ..color = color.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, radius, ripplePaint);
    }
  }

  void _paintLiquidFill(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width;
    final fillHeight = size.height * progress;
    final yOffset = size.height - fillHeight;

    path.moveTo(0, size.height);
    path.lineTo(0, yOffset);

    // Wave effect
    for (double x = 0; x <= size.width; x += 5) {
      final y = yOffset + math.sin(
        (x / waveLength * 2 * math.pi) + (progress * 4 * math.pi)) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RevealPainter oldDelegate) =>
    oldDelegate.progress != progress;
}

/// ═══════════════════════════════════════════════════════
/// 🎨 FULL SCREEN REVEAL LOADER (for splash/transitions)
/// ═══════════════════════════════════════════════════════
class FullScreenLoader extends StatefulWidget {
  final RevealVariant variant;
  final Duration      duration;
  final String?       message;

  const FullScreenLoader({
    super.key,
    this.variant  = RevealVariant.liquidFill,
    this.duration = const Duration(milliseconds: 2500),
    this.message,
  });

  @override
  State<FullScreenLoader> createState() => _FullScreenLoaderState();
}

class _FullScreenLoaderState extends State<FullScreenLoader>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _textController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1500),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background reveal animation
          Positioned.fill(
            child: RevealLoader(
              variant:         widget.variant,
              duration:        widget.duration,
              color:           AppColors.primary.withOpacity(0.15),
              backgroundColor: Colors.white,
              logoPath:        null,
              loop:            true,
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _logoController,
                    curve:  Curves.elasticOut),
                  child: Container(
                    width:  140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius:   40,
                          spreadRadius: 6,
                          offset:       const Offset(0, 10)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Animated text
                FadeTransition(
                  opacity: _textController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end:   Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _textController,
                      curve:  Curves.easeOutCubic)),
                    child: Column(
                      children: [
                        Text(
                          widget.message ?? 'Kohli Store',
                          style: AppText.display.copyWith(
                            fontSize: 28,
                            color: AppColors.textStrong)),
                        const SizedBox(height: 6),
                        Text(
                          'Fresh • Fast • Premium',
                          style: AppText.body.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Animated dots loader
                FadeTransition(
                  opacity: _textController,
                  child: _AnimatedDots(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  final Color color;
  const _AnimatedDots({required this.color});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {

  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) =>
      AnimationController(
        vsync:    this,
        duration: const Duration(milliseconds: 600),
      ));
    _start();
  }

  void _start() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) return;
        _controllers[i].forward().then((_) {
          if (mounted) _controllers[i].reverse();
        });
        await Future.delayed(const Duration(milliseconds: 180));
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, _) {
            final scale = 1.0 + (_controllers[i].value * 0.5);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width:  10, height: 10,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}


