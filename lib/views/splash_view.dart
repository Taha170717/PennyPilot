import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'home_view.dart';
import '../controllers/auth_controller.dart';
import 'login_view.dart';
class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<SplashView> createState() => _SplashViewState();
}
class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
    _animationController.forward();
    // Navigate after 3 seconds depending on auth state
    Timer(const Duration(seconds: 3), () {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn) {
        Get.offAll(() => const HomeView(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 800));
      } else {
        Get.offAll(() => const LoginView(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 800));
      }
    });
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient glowing background circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha((0.15 * 255).round()),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha((0.15 * 255).round()),
                      blurRadius: 100,
                      spreadRadius: 80,
                      offset: Offset.zero,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withAlpha((0.12 * 255).round()),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withAlpha((0.12 * 255).round()),
                      blurRadius: 120,
                      spreadRadius: 90,
                      offset: Offset.zero,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Premium glassmorphic logo icon
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withAlpha((0.3 * 255).round()),
                            AppColors.secondary.withAlpha((0.05 * 255).round()),
                          ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.primary.withAlpha((0.4 * 255).round()),
                          width: 1.5,
                        ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha((0.2 * 255).round()),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      size: 55,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // App Name with modern design
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      'PennyPilot',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'NAVIGATE YOUR WEALTH',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Modern pulsing loader indicator
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(
                       valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary.withAlpha((0.8 * 255).round())),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Footer branding
            Positioned(
              bottom: 40,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'FINANCIAL FREEDOM AWAITS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
