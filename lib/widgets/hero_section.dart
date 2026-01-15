import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatefulWidget {
  final GlobalKey pricingSectionKey;

  const HeroSection({super.key, required this.pricingSectionKey});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  double _sliderValue = 70.0;
  bool _isDragging = false;
  late AnimationController _shimmerController;
  late AnimationController _tapAnimationController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _tapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _tapAnimationController.dispose();
    super.dispose();
  }

  void _scrollToPricingSection() {
    final context = widget.pricingSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleTap(double maxWidth) {
    if (_isDragging || _tapAnimationController.isAnimating) return;

    final startValue = _sliderValue;
    final endValue = maxWidth;

    final animation = Tween<double>(begin: startValue, end: endValue).animate(
      CurvedAnimation(parent: _tapAnimationController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      setState(() {
        _sliderValue = animation.value;
      });
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scrollToPricingSection();
        // Reset after a delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _sliderValue = 70.0;
            });
            _tapAnimationController.reset();
          }
        });
      }
    });

    _tapAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: Column(
        children: [
          // Social Proof Badge
          _buildSocialProofBadge(),
          const SizedBox(height: 50),

          // Main Heading with Shimmer Effect
          _buildShimmerHeading(isMobile),
          const SizedBox(height: 10),

          // Subtitle
          _buildSubtitle(isMobile),
          const SizedBox(height: 60),

          // Slider Button
          LayoutBuilder(
            builder: (context, constraints) {
              final sliderWidth = math.min(
                constraints.maxWidth,
                isMobile ? 320.0 : 400.0,
              );
              return _buildSliderButton(sliderWidth);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProofBadge() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.374),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 8),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              // Avatars
              SizedBox(
                width: 110,
                height: 32,
                child: Stack(
                  children: List.generate(4, (index) {
                    return Positioned(
                      left: index * 22.0,
                      top: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: AssetImage('assets/testi${index + 1}.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Text(
                'Risk is better than regret',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: _scrollToPricingSection,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Join Us 🎉 →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerHeading(bool isMobile) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.white,
                Color(0xFFAAAAAA),
                Colors.white,
                Color(0xFFAAAAAA),
                Colors.white,
              ],
              stops: [
                0.0,
                _shimmerController.value * 0.4,
                _shimmerController.value * 0.5,
                _shimmerController.value * 0.6,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: Text(
            '"Plan Your Trade and Trade \n Your Plan"',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 40 : 64,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(bool isMobile) {
    return Text(
      'Clear lessons. Real guidance. Learn to trade independently',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: isMobile ? 16 : 20,
        color: const Color(0xFF888888),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSliderButton(double maxWidth) {
    return GestureDetector(
      onTap: () => _handleTap(maxWidth),
      onHorizontalDragUpdate: (details) {
        setState(() {
          _isDragging = true;
          _sliderValue += details.delta.dx;
          _sliderValue = _sliderValue.clamp(70.0, maxWidth);
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _isDragging = false;
          if (_sliderValue >= maxWidth - 10) {
            // Navigate to PricingSection
            _scrollToPricingSection();
          }
          _sliderValue = 70.0;
        });
      },
      child: Container(
        width: maxWidth,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0BE348).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Green sliding background
            AnimatedContainer(
              duration:
                  _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
              width: _sliderValue,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF26D815),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Handle with dotted chevron
            Positioned(
              left: _sliderValue - 70,
              child: Container(
                width: 70,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF26D815),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(18, 18),
                    painter: DottedChevronPainter(),
                  ),
                ),
              ),
            ),
            // Text
            Center(
              child: Text(
                'Join Our Mentorship',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final dotSize = 2.5;

    // Center dot
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.5),
      dotSize,
      paint,
    );

    // Tip (rightmost)
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.5),
      dotSize,
      paint,
    );

    // Upper diagonal
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.3),
      dotSize,
      paint,
    );

    // Lower diagonal
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.7),
      dotSize,
      paint,
    );

    // Upper back
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.2),
      dotSize,
      paint,
    );

    // Lower back
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.8),
      dotSize,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
