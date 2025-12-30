import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const PremiumBackground(),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return tablet ?? mobile;
            } else {
              return mobile;
            }
          },
        ),
      ],
    );
  }
}

class PremiumBackground extends StatefulWidget {
  const PremiumBackground({super.key});

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: const Color(0xFFF0F4F8),
          child: Stack(
            children: [
              Positioned(
                top: -100 + 100 * (1 + _controller.value),
                right: -100 + 50 * (1 - _controller.value),
                child: _buildBlob(const Color(0xFFBBDEFB).withAlpha(120), 450),
              ),
              Positioned(
                bottom: -150 + 100 * _controller.value,
                left: -100 + 80 * (1 + _controller.value),
                child: _buildBlob(const Color(0xFFC8E6C9).withAlpha(120), 550),
              ),
              Positioned(
                top: 200 * _controller.value,
                left: 300 * (1 - _controller.value),
                child: _buildBlob(const Color(0xFFFFE0B2).withAlpha(100), 350),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: AppTheme.glassDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

class SplitLayout extends StatelessWidget {
  final Widget form;
  final Widget illustration;

  const SplitLayout({
    super.key,
    required this.form,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: illustration,
        ),
        Expanded(
          flex: 1,
          child: ConstrainedCenter(
            maxWidth: 480,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                child: form,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ConstrainedCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ConstrainedCenter({
    super.key,
    required this.child,
    this.maxWidth = 500,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
