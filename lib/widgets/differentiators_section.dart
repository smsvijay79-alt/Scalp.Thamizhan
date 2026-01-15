import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DifferentiatorsSection extends StatefulWidget {
  const DifferentiatorsSection({Key? key}) : super(key: key);

  @override
  State<DifferentiatorsSection> createState() => _DifferentiatorsSectionState();
}

class _DifferentiatorsSectionState extends State<DifferentiatorsSection>
    with TickerProviderStateMixin {
  bool _isVisible = false;
  late List<AnimationController> _cardControllers;
  late AnimationController _headerController;
  late List<AnimationController> _barControllers;
  late AnimationController _progressController;
  late AnimationController _leaderboardController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    // Bar chart animation controllers - repeating
    _barControllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500 + (index * 200)),
      )..repeat(reverse: true);
    });

    // Progress loading animation - repeating
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Leaderboard scrolling animation - continuous
    _leaderboardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Pulse animation for icons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Rotate animation for trophy
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _headerController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    for (var controller in _barControllers) {
      controller.dispose();
    }
    _progressController.dispose();
    _leaderboardController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _headerController.forward();

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return VisibilityDetector(
      key: const Key('differentiators-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_isVisible) {
          setState(() => _isVisible = true);
          _startAnimations();
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isMobile),
            const SizedBox(height: 60),
            _buildCards(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Opacity(
          opacity: _headerController.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WANNA KNOW MORE?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: Colors.white24,
                margin: const EdgeInsets.only(bottom: 40),
              ),
              isMobile
                  ? _buildMobileHeaderContent()
                  : _buildDesktopHeaderContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopHeaderContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'What Makes\nSCALP.TAMIZHAN\nDifferent?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'At Scalp.Tamizhan, we mentor you live in the markets, clear every doubt, support you on weekends, reward top performers, and encourage discipline in both trading and health. Our approach is practical, community-driven, and focused on building real skill - not shortcuts or hype.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Makes\nSCALP.TAMIZHAN\nDifferent?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'At Scalp.Tamizhan, we mentor you live in the markets, clear every doubt, support you on weekends, reward top performers, and encourage discipline in both trading and health. Our approach is practical, community-driven, and focused on building real skill - not shortcuts or hype.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 16,
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCards(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildAnimatedCard(0, _buildPerformanceCard()),
          const SizedBox(height: 20),
          _buildAnimatedCard(1, _buildGuidanceCard()),
          const SizedBox(height: 20),
          _buildAnimatedCard(2, _buildHolisticCard()),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildAnimatedCard(0, _buildPerformanceCard())),
        const SizedBox(width: 24),
        Expanded(child: _buildAnimatedCard(1, _buildGuidanceCard())),
        const SizedBox(width: 24),
        Expanded(child: _buildAnimatedCard(2, _buildHolisticCard())),
      ],
    );
  }

  Widget _buildAnimatedCard(int index, Widget card) {
    return AnimatedBuilder(
      animation: _cardControllers[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _cardControllers[index].value)),
          child: Opacity(opacity: _cardControllers[index].value, child: card),
        );
      },
    );
  }

  Widget _buildPerformanceCard() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    const pricingGreen = Color(0xFF2E7D32);
    const pricingGreenLight = Color(0xFF43A047);

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pricingGreenLight, pricingGreen],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: pricingGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated bar chart with continuous leaderboard effect
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildAnimatedBar(0, 0.6, pricingGreen),
                const SizedBox(width: 8),
                _buildAnimatedBar(1, 0.8, pricingGreen),
                const SizedBox(width: 8),
                _buildAnimatedBar(2, 0.5, pricingGreen),
                const SizedBox(width: 8),
                _buildAnimatedBar(3, 1.0, const Color(0xFF128C7E)),
                const SizedBox(width: 8),
                _buildAnimatedBar(4, 0.7, pricingGreen),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Animated trophy icon
          Align(
            alignment: Alignment.topRight,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pulseController,
                _rotateController,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.15),
                  child: Transform.rotate(
                    angle: _rotateController.value * 0.3,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(
                              0.5 + _pulseController.value * 0.3,
                            ),
                            blurRadius: 12 + (_pulseController.value * 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Color(0xFFFFB300),
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Content section
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: pricingGreen.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Performer Reward',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$10,000 Funded\nAccount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'We to make\nProfessional Trader',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBar(int index, double heightFactor, Color color) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _barControllers[index],
        _leaderboardController,
      ]),
      builder: (context, child) {
        // Continuous growing and shrinking animation
        final dynamicHeight =
            heightFactor + (_barControllers[index].value * 0.2);
        final barHeight = 100.0 * dynamicHeight;

        // Continuous bouncing for winner bar
        final bounceOffset =
            index == 3
                ? 8 * (0.5 - (_leaderboardController.value - 0.5).abs())
                : 0.0;

        return Transform.translate(
          offset: Offset(0, bounceOffset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow:
                      index == 3
                          ? [
                            BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius:
                                  8 + (_leaderboardController.value * 4),
                              spreadRadius: 1,
                            ),
                          ]
                          : null,
                ),
                child:
                    barHeight > 20
                        ? Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.2),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : null,
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF128C7E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuidanceCard() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    const pricingGreen = Color(0xFF2E7D32);
    const pricingGreenLight = Color(0xFF43A047);

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pricingGreenLight, pricingGreen],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: pricingGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress steps with continuous loading animation
          _buildProgressStep(
            number: '1',
            label: 'Phase 1 Complete',
            baseProgress: 1.0,
            color: const Color(0xFF128C7E),
            isComplete: true,
          ),
          const SizedBox(height: 16),
          _buildProgressStep(
            number: '2',
            label: 'Phase 2 Active',
            baseProgress: 0.6,
            color: const Color(0xFFFFB300),
            isComplete: false,
          ),
          const SizedBox(height: 16),
          _buildProgressStep(
            number: '\$',
            label: 'Funded Account',
            baseProgress: 0.3,
            color: const Color(0xFF7B1FA2),
            isComplete: false,
          ),
          const SizedBox(height: 32),
          // Animated Live guidance box
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.03),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFFFB300,
                        ).withOpacity(0.3 + _pulseController.value * 0.2),
                        blurRadius: 12 + (_pulseController.value * 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _rotateController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateController.value * 6.28,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB300),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Guidance Active',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Real-time mentor support',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Bottom text
          const Text(
            'Guidance in Cracking\nFunded Accounts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required String number,
    required String label,
    required double baseProgress,
    required Color color,
    required bool isComplete,
  }) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        // Continuous loading animation
        double animatedProgress;
        if (isComplete) {
          animatedProgress = 1.0;
        } else {
          // Creates a wave effect that repeats
          animatedProgress =
              baseProgress +
              ((1 - baseProgress) * _progressController.value * 0.3);
        }

        return Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(
                            0.4 + _pulseController.value * 0.3,
                          ),
                          blurRadius: 8 + (_pulseController.value * 6),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child:
                          isComplete
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                              : Text(
                                number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: animatedProgress,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHolisticCard() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    const pricingGreen = Color(0xFF2E7D32);
    const pricingGreenLight = Color(0xFF43A047);

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pricingGreenLight, pricingGreen],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: pricingGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Three animated icons at top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTopIcon(
                icon: Icons.trending_up,
                label: 'Trading Skills',
                color: const Color(0xFF1976D2),
                delay: 0,
              ),
              _buildTopIcon(
                icon: Icons.fitness_center,
                label: 'Discipline growth',
                color: const Color(0xFF388E3C),
                delay: 0.33,
              ),
              _buildTopIcon(
                icon: Icons.psychology,
                label: 'Mindset Growth',
                color: const Color(0xFF7B1FA2),
                delay: 0.66,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Overall progress card with continuous loading
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              // Continuous counting animation
              final baseProgress = 0.85;
              final progress =
                  baseProgress -
                  (baseProgress * 0.15 * (1 - _progressController.value));

              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.02),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF2E7D32,
                            ).withOpacity(0.2 + _pulseController.value * 0.15),
                            blurRadius: 12 + (_pulseController.value * 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Overall Progress',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF25D366),
                                        Color(0xFF128C7E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF25D366,
                                        ).withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 18),
          // Animated Discipline rewards card
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.03),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFFFB300,
                        ).withOpacity(0.3 + _pulseController.value * 0.2),
                        blurRadius: 12 + (_pulseController.value * 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _rotateController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateController.value * 6.28,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB300),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discipline Rewards',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Stay consistent, get recognized',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Bottom text
          const Text(
            'More Than Just\nCharts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon({
    required IconData icon,
    required String label,
    required Color color,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
