import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class BenefitsSection extends StatefulWidget {
  const BenefitsSection({super.key});

  @override
  State<BenefitsSection> createState() => _BenefitsSectionState();
}

class _BenefitsSectionState extends State<BenefitsSection>
    with TickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _titleController;
  late AnimationController _liveBadgeController;
  late AnimationController _bellController;
  late AnimationController _chartController;
  late List<AnimationController> _cardControllers;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _liveBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _cardControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _liveBadgeController.dispose();
    _bellController.dispose();
    _chartController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1024;

    return VisibilityDetector(
      key: const Key('benefits-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_isVisible) {
          setState(() => _isVisible = true);
          _titleController.forward();

          for (int i = 0; i < _cardControllers.length; i++) {
            Future.delayed(Duration(milliseconds: 200 + (i * 200)), () {
              if (mounted) _cardControllers[i].forward();
            });
          }
        }
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60,
          vertical: 100,
        ),
        child: Column(
          children: [
            // Header
            AnimatedBuilder(
              animation: _titleController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _titleController.value) * 20),
                  child: Opacity(
                    opacity: _titleController.value,
                    child: Text(
                      'Benefits That Keep You Consistent',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 36 : 56,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            AnimatedBuilder(
              animation: _titleController,
              builder: (context, child) {
                return Opacity(
                  opacity: _titleController.value * 0.8,
                  child: Text(
                    'We Got You Covered, Sit Back And Relax',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF888888),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // Cards Grid
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                _buildCard(
                  0,
                  _buildLivestreamVisual(),
                  'Livestream Sessions',
                  'Live London & New York session streams (FOREX & US Futures - Tue, Wed, Thu, Fri) with real-time market analysis and doubt clearing.',
                  const Color(0xFFCDDC39),
                ),
                _buildCard(
                  1,
                  _buildWeekendVisual(),
                  'Weekend Doubt Sessions',
                  'Special sessions for working professionals to clarify concepts and stay consistent.',
                  const Color(0xFFA78BFA),
                ),
                _buildCard(
                  2,
                  _buildMentorVisual(),
                  'Direct Mentor Guidance',
                  'Ask any doubt anytime - we explain it simply and clearly until you get it.',
                  const Color(0xFF3B82F6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    int index,
    Widget visual,
    String title,
    String description,
    Color borderColor,
  ) {
    final isHovered = _hoveredIndex == index;

    return AnimatedBuilder(
      animation: _cardControllers[index],
      builder: (context, child) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Transform.scale(
            scale: 0.9 + (_cardControllers[index].value * 0.1),
            child: Opacity(
              opacity: _cardControllers[index].value,
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          isHovered
                              ? borderColor.withOpacity(0.6)
                              : borderColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow:
                        isHovered
                            ? [
                              BoxShadow(
                                color: borderColor.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ]
                            : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      visual,
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF9CA3AF),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLivestreamVisual() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3A1F), Color(0xFF1A1F14)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            size: const Size(double.infinity, 280),
            painter: GridPainter(),
          ),

          // Animated chart line
          Positioned(
            left: 20,
            right: 20,
            top: 60,
            bottom: 80,
            child: AnimatedBuilder(
              animation: _chartController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ChartLinePainter(_chartController.value),
                );
              },
            ),
          ),

          // Live Badge
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _liveBadgeController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFF44336,
                        ).withOpacity(_liveBadgeController.value * 0.8),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom icons
          Positioned(
            left: 20,
            bottom: 20,
            child: Row(
              children: [
                _buildIconButton(Icons.tv, const Color(0xFFCDDC39)),
                const SizedBox(width: 12),
                _buildIconButton(Icons.person, const Color(0xFFCDDC39)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendVisual() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1F4A), Color(0xFF1A1129)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Bell icon
          Positioned(
            top: 30,
            left: 30,
            child: AnimatedBuilder(
              animation: _bellController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: math.sin(_bellController.value * 2 * math.pi) * 0.2,
                  child: Icon(
                    Icons.notifications,
                    size: 36,
                    color: const Color(0xFFA78BFA).withOpacity(0.8),
                  ),
                );
              },
            ),
          ),

          // Weekend card
          Center(
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFA78BFA).withOpacity(0.3),
                    const Color(0xFF7C3AED).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFA78BFA).withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weekend',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Icon(
                        Icons.more_horiz,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDayButton('SAT'),
                      const SizedBox(width: 16),
                      _buildDayButton('SUN'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat icon top right
          Positioned(
            top: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFA78BFA).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: const Color(0xFFA78BFA),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorVisual() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A5F), Color(0xFF0F1E33)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Chat icon top right
          Positioned(
            top: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
            ),
          ),

          // Center mentor with surrounding circles
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Surrounding circles
                  ...List.generate(8, (index) {
                    final angle = (index * math.pi * 2) / 8;
                    final radius = 80.0;
                    return Positioned(
                      left: 100 + math.cos(angle) * radius - 20,
                      top: 100 + math.sin(angle) * radius - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF3B82F6).withOpacity(0.4),
                              const Color(0xFF3B82F6).withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Center mentor
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.6),
                          const Color(0xFF3B82F6).withOpacity(0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3B82F6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
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

  Widget _buildDayButton(String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFA78BFA).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        day,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFCDDC39).withOpacity(0.1)
          ..strokeWidth = 1;

    // Vertical lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Horizontal lines
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChartLinePainter extends CustomPainter {
  final double progress;

  ChartLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFCDDC39)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.25, size.height * 0.4),
      Offset(size.width * 0.35, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.65, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.35),
      Offset(size.width, size.height * 0.5),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint =
        Paint()
          ..color = const Color(0xFFCDDC39)
          ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(ChartLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
