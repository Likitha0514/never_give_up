import 'package:flutter/material.dart';
import '../../../core/logo/never_give_up_logo.dart';
import '../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    scale = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );
    opacity = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: .07),
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue.withValues(alpha: .05),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: opacity,
              child: ScaleTransition(
                scale: scale,
                child: const NeverGiveUpLogo(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
