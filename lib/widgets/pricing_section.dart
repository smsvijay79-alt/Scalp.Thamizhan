import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({Key? key}) : super(key: key);

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection>
    with TickerProviderStateMixin {
  bool _isVisible = false;
  late List<AnimationController> _scanControllers;
  late AnimationController _headerController;
  late List<AnimationController> _hoverControllers;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scanControllers = List.generate(3, (index) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2500),
      );
      return controller;
    });

    _hoverControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    for (var controller in _scanControllers) {
      controller.dispose();
    }
    for (var controller in _hoverControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1024;

    return VisibilityDetector(
      key: const Key('pricing-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_isVisible) {
          setState(() => _isVisible = true);
          _headerController.forward();
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal:
              screenWidth > 1200
                  ? 80
                  : screenWidth > 768
                  ? 40
                  : 20,
          vertical:
              screenWidth > 1200
                  ? 80
                  : screenWidth > 768
                  ? 60
                  : 40,
        ),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(
              height:
                  screenWidth > 1200
                      ? 60
                      : screenWidth > 768
                      ? 48
                      : 32,
            ),
            isMobile ? _buildMobileCards() : _buildDesktopCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize =
        screenWidth > 1200
            ? 48.0
            : screenWidth > 768
            ? 36.0
            : 28.0;
    final subtitleFontSize =
        screenWidth > 1200
            ? 16.0
            : screenWidth > 768
            ? 14.0
            : 12.0;

    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Opacity(
          opacity: _headerController.value,
          child: Column(
            children: [
              const Text(
                'PRICING',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: screenWidth > 768 ? 24 : 16),
              Text(
                'Choose the plan that fits your goals',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Our flexible plans provide the support and knowledge you need to become a profitable trader',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: subtitleFontSize,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSpacing =
        screenWidth > 1400
            ? 32.0
            : screenWidth > 1200
            ? 28.0
            : 24.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Small box - Discord (₹5000)
        _buildPricingCard(
          index: 0,
          color: const Color(0xFF5865F2),
          icon: Icons.discord,
          title: 'DISCORD SUBSCRIPTION',
          price: '₹5000',
          priceSubtitle: 'Per Payout',
          description:
              'The Scalp.Tamizhan Discord Subscription Gives You Access To Our Private Trading Community - Built For Traders Who Want To Level Up Every Single Day Through Real-Time Learning And Mentorship.',
          features: [
            'Phase-1 & Phase-2 Guidance',
            '24/7 Call Support',
            'Scalp Your Funded Account',
            'Complete Step by Step Roadmap',
            'Build Your Trading Skills',
          ],
          scale: 0.95,
        ),
        SizedBox(width: cardSpacing),
        // Large box - AlchemyX (₹23000) - Most Popular
        _buildPricingCard(
          index: 1,
          color: const Color(0xFF2E7D32),
          title: 'INTERMEDIATE',
          price: '₹18000',
          priceSubtitle: 'per year',
          description:
              'Experience Personalized 1-On-1 Mentorship Designed To Match Your Learning Pace. Every Concept Is Taught In Depth With Assigned Tasks For Each Topic, Ensuring True Understanding Before Moving Forward.',
          features: [
            'Build Strategies',
            'Give Proper way',
            'Build tour Trading Skills',
            'Physiology = Disciple and Patience',
            'Step by Step Track Program',
            'Build tour Trading Skills',
            'Physiology = Disciple and Patience',
            'Step by Step Track Program',
          ],
          isPopular: true,
          scale: 1.0,
        ),
        SizedBox(width: cardSpacing),
        // Medium box - Intermediate (₹18000)
        _buildPricingCard(
          index: 2,
          color: const Color(0xFFF57C00),
          title: 'BASIC PLAN',   
          price: '₹23000',
          priceSubtitle: 'Life Time',
          description:
              'The Basic Plan Trading Program Helps Traders Master Forex And US Futures Through Structured, Pre-Recorded Lessons And 1-Year Discord Mentorship. Learn, Apply, And Grow With Real-Time Market Experience And Expert Guidance.',
          features: [
            'Pre-Recorded HD Lessons On Forex & US Futures',
            '1-Year Discord Mentorship & Daily Support',
            'Weekly Live NY Sessions For Real-Time Learning',
            'Bi-Weekly Giveaways For Top Traders',
            'Active Community To Learn And Grow',
          ],
          scale: 0.95,
        ),
      ],
    );
  }

  Widget _buildMobileCards() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPricingCard(
          index: 0,
          color: const Color(0xFF5865F2),
          icon: Icons.discord,
          title: 'DISCORD SUBSCRIPTION',
          price: '₹5000',
          priceSubtitle: 'Per Payout',
          description:
              'The Scalp.Tamizhan Discord Subscription Gives You Access To Our Private Trading Community - Built For Traders Who Want To Level Up Every Single Day Through Real-Time Learning And Mentorship.',
          features: [
            'Phase-1 & Phase-2 Guidance',
            '24/7 Call Support',
            'Scalp Your Funded Account',
            'Complete Step by Step Roadmap',
            'Build Your Trading Skills',
          ],
          scale: 1.0,
        ),
        const SizedBox(height: 32),
        _buildPricingCard(
          index: 1,
          color: const Color(0xFF2E7D32),
          iconText: 'Ax',
          title: 'ALCHEMYX TRADING PROGRAM',
          price: '₹23000',
          priceSubtitle: 'Life Time',
          description:
              'The AlchemyX Trading Program Helps Traders Master Forex And US Futures Through Structured, Pre-Recorded Lessons And 1-Year Discord Mentorship. Learn, Apply, And Grow With Real-Time Market Experience And Expert Guidance.',
          features: [
            'Pre-Recorded HD Lessons On Forex & US Futures',
            '1-Year Discord Mentorship & Daily Support',
            'Weekly Live NY Sessions For Real-Time Learning',
            'Bi-Weekly Giveaways For Top Traders',
            'Active Community To Learn And Grow',
          ],
          isPopular: true,
          scale: 1.0,
        ),
        const SizedBox(height: 32),
        _buildPricingCard(
          index: 2,
          color: const Color(0xFFF57C00),
          title: 'INTERMEDIATE',
          price: '₹18000',
          priceSubtitle: 'per year',
          description:
              'Experience Personalized 1-On-1 Mentorship Designed To Match Your Learning Pace. Every Concept Is Taught In Depth With Assigned Tasks For Each Topic, Ensuring True Understanding Before Moving Forward.',
          features: [
            'Build Strategies',
            'Give Proper way',
            'Build tour Trading Skills',
            'Physiology = Disciple and Patience',
            'Step by Step Track Program',
          ],
          scale: 1.0,
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required int index,
    required Color color,
    IconData? icon,
    String? iconText,
    required String title,
    required String price,
    required String priceSubtitle,
    required String description,
    required List<String> features,
    bool isPopular = false,
    double scale = 1.0,
  }) {
    if (!_scanControllers[index].isAnimating && _isVisible) {
      _scanControllers[index].repeat();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        screenWidth > 1400
            ? 320.0 // Reduced from 350
            : screenWidth > 1200
            ? 300.0 // Reduced from 320
            : 280.0; // Reduced from 300

    return MouseRegion(
      onEnter: (_) {
        _hoverControllers[index].forward();
      },
      onExit: (_) {
        _hoverControllers[index].reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverControllers[index],
        builder: (context, child) {
          final hoverScale = 1.0 + (_hoverControllers[index].value * 0.03);
          return Transform.scale(
            scale: scale * hoverScale,
            child: Transform.translate(
              offset: Offset(0, -_hoverControllers[index].value * 10),
              child: Container(
                width: cardWidth,
                margin: EdgeInsets.only(
                  top: isPopular ? 0 : 20, // Lift the popular card less
                  bottom: isPopular ? 20 : 0, // Drop non-popular cards
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      isPopular
                          ? Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 4,
                          )
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.3 + _hoverControllers[index].value * 0.2,
                      ),
                      blurRadius: 20 + _hoverControllers[index].value * 10,
                      offset: Offset(
                        0,
                        10 + _hoverControllers[index].value * 5,
                      ),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Scanning overlay
                    AnimatedBuilder(
                      animation: _scanControllers[index],
                      builder: (context, child) {
                        return Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Transform.translate(
                              offset: Offset(
                                (MediaQuery.of(context).size.width * 2) *
                                    (_scanControllers[index].value - 0.5),
                                0,
                              ),
                              child: Transform(
                                transform: Matrix4.skewX(-0.2),
                                child: Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Popular badge
                    if (isPopular)
                      Positioned(
                        top: -10,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDFF00),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'MOST POPULAR',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon and Title
                          Row(
                            children: [
                              if (icon != null)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              else if (iconText != null)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    iconText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36, // Slightly reduced
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  priceSubtitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13, // Slightly reduced
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Buy Button
                          _buildBuyButton(color),
                          const SizedBox(height: 24),
                          // Features
                          ...features.map(
                            (feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13, // Slightly reduced
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuyButton(Color cardColor) {
    return Container(
      width: double.infinity,
      height: 48, // Slightly reduced
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final session = Supabase.instance.client.auth.currentSession;
            if (session == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else {
              // User is logged in, proceed with purchase logic (leave it for now)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Proceeding to payment...',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Color(0xFFCDFF00),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BUY NOW',
                  style: TextStyle(
                    color: cardColor,
                    fontSize: 15, // Slightly reduced
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 30, // Slightly reduced
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCDFF00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 16, // Slightly reduced
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
