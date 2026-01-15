import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({Key? key}) : super(key: key);

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = false;
  late List<AnimationController> _cardControllers;

  final List<Map<String, String>> _testimonials = [
    {
      'name': 'Guruprasad',
      'location': 'COIMBATORE',
      'avatar': 'assets/testi3.png',
      'text':
          "I've been trading since 2020 and most courses lacked real guidance. Found the Scalp.Thamizha Community in 2024, and their practical approach stood out. Daily live sessions and weekly discussions changed my learning experience. Now my trading vision is clear and focused.",
    },
    {
      'name': 'Pradeep Srinivasan',
      'location': 'KUMBAKONAM',
      'avatar': 'assets/testi4.png',
      'text':
          'Joining AlchemyX is one of my best trading decisions. The course is well-structured and makes ICT concepts easy to grasp. Live sessions offer real market experience and deepen understanding. The Discord community keeps me motivated and learning every day.',
    },
    {
      'name': 'Anitha J',
      'location': 'CHENNAI',
      'avatar': 'assets/testi1.png',
      'text':
          'The mentorship here is unparalleled. I finally understood how to size my positions correctly and manage risk without fear. The weekly analysis sessions are invaluable for predicting market moves. Highly recommend to anyone serious about trading!',
    },
    {
      'name': 'Mohammed Javid',
      'location': 'COIMBATORE',
      'avatar': 'assets/testi2.png',
      'text':
          "The focus on psychology helped me stay patient, control emotions, and trade with clarity. Live streams by Sri bro are next level - real-time insights you won't find anywhere else. Thanks to Ganesh bro for building this amazing community and to everyone for the constant support. It truly feels like a family of traders growing together.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      _testimonials.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('testimonials-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_isVisible) {
          setState(() => _isVisible = true);
          for (int i = 0; i < _cardControllers.length; i++) {
            Future.delayed(Duration(milliseconds: i * 100), () {
              if (mounted) _cardControllers[i].forward();
            });
          }
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 1024;
            return Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _buildLeftSection()),
        const SizedBox(width: 48),
        Expanded(flex: 8, child: _buildTestimonialsList()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftSection(),
        const SizedBox(height: 48),
        _buildTestimonialsList(),
      ],
    );
  }

  Widget _buildLeftSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Testimonials',
          style: TextStyle(
            fontSize: isMobile ? 42 : 60,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'See What Our Students Tell About Scalp.tamizhan',
          style: TextStyle(fontSize: 18, color: Color(0xFF9CA3AF), height: 1.6),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(Icons.star, color: Color(0xFF34D399), size: 20),
            SizedBox(width: 4),
            Text(
              '4.9/5 Rating',
              style: TextStyle(
                color: Color(0xFF34D399),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Based on 1,200+ student reviews',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        _buildFeatureItem('Daily Live Trading Sessions'),
        _buildFeatureItem('Personal Mentorship'),
        _buildFeatureItem('Active Community Support'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsList() {
    return Column(
      children: List.generate(_testimonials.length, (index) {
        return AnimatedBuilder(
          animation: _cardControllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _cardControllers[index].value)),
              child: Opacity(
                opacity: _cardControllers[index].value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTestimonialCard(
                    name: _testimonials[index]['name']!,
                    location: _testimonials[index]['location']!,
                    avatarPath: _testimonials[index]['avatar']!,
                    testimonial: _testimonials[index]['text']!,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String location,
    required String avatarPath,
    required String testimonial,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmall = constraints.maxWidth < 640;
          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(avatarPath),
                const SizedBox(height: 16),
                _buildTestimonialContent(name, location, testimonial),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(avatarPath),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTestimonialContent(name, location, testimonial),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAvatar(String avatarPath) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          avatarPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.person, color: Colors.white, size: 28),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestimonialContent(
    String name,
    String location,
    String testimonial,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF34D399),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        Text(
          testimonial,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD1D5DB),
            height: 1.625,
          ),
        ),
      ],
    );
  }
}
