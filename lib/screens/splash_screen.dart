import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const SplashScreen({Key? key, this.onFinished}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    
    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();
    _particleController.repeat();
    
    // Delay content animation
    await Future.delayed(const Duration(milliseconds: 500));
    _contentController.forward();
    
    // Finish splash screen
    await Future.delayed(const Duration(milliseconds: 3000));
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    if (widget.onFinished != null) {
      widget.onFinished!();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF312e81), // Indigo 900
              Color(0xFF7c3aed), // Purple 600
              Color(0xFFec4899), // Pink 500
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles
            ...List.generate(20, (index) => _buildParticle(index)),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  _buildLogo(),
                  
                  const SizedBox(height: 48),
                  
                  // Title
                  _buildTitle(),
                  
                  const SizedBox(height: 32),
                  
                  // Features
                  _buildFeatures(),
                  
                  const SizedBox(height: 32),
                  
                  // Loading dots
                  _buildLoadingDots(),
                ],
              ),
            ),
            
            // Version info
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: _buildVersionInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final x = (index * 47) % screenSize.width.toInt();
        final y = (index * 73) % screenSize.height.toInt();
        
        return Positioned(
          left: x.toDouble(),
          top: y.toDouble(),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 2.seconds)
            .fadeOut(duration: 2.seconds),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoController.value,
          child: Transform.rotate(
            angle: (1 - _logoController.value) * 3.14159,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: Icon(
                      Icons.location_on,
                      size: 48,
                      color: Color(0xFF60a5fa), // Blue 400
                    ),
                  ),
                  const Positioned(
                    right: 16,
                    bottom: 16,
                    child: Icon(
                      Icons.card_giftcard,
                      size: 24,
                      color: Color(0xFFa855f7), // Purple 500
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    top: 16,
                    child: Icon(
                      Icons.bolt,
                      size: 20,
                      color: Color(0xFFfbbf24), // Yellow 400
                    ),
                  ),
                  const Positioned(
                    right: 16,
                    top: 16,
                    child: Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Color(0xFF34d399), // Green 400
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _contentController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _contentController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                children: [
                  const TextSpan(text: 'Local '),
                  TextSpan(
                    text: 'Hunt',
                    style: TextStyle(
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF60a5fa), Color(0xFFa855f7)],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tích điểm • Đổi thưởng • Khám phá',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFFd1d5db), // Gray 300
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return FadeTransition(
      opacity: _contentController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _contentController,
          curve: Curves.easeOutCubic,
        )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeatureTag(Icons.location_on_outlined, 'Check-in', const Color(0xFF60a5fa)),
            const SizedBox(width: 16),
            _buildFeatureTag(Icons.card_giftcard_outlined, 'Rewards', const Color(0xFFa855f7)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(IconData icon, String text, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return FadeTransition(
      opacity: _contentController,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: Duration(milliseconds: index * 200))
                .fadeOut(delay: Duration(milliseconds: index * 200)),
          );
        }),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return FadeTransition(
      opacity: _contentController,
      child: Center(
        child: Text(
          'v1.0.0',
          style: GoogleFonts.inter(
            color: const Color(0xFF9ca3af), // Gray 400
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}