import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

// PropFirms Section
class PropFirmsSection extends StatefulWidget {
  const PropFirmsSection({Key? key}) : super(key: key);

  @override
  State<PropFirmsSection> createState() => _PropFirmsSectionState();
}

class _PropFirmsSectionState extends State<PropFirmsSection>
    with TickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _controller;
  late List<AnimationController> _hoverControllers;

  final List<String> _propFirmImages = [
    'assets/cert1.png',
    'assets/cert2.jpeg',
    'assets/cert3.jpeg',
    'assets/cert4.jpeg',
    'assets/cert5.jpeg',
    'assets/cert6.jpeg',
  ];
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _hoverControllers = List.generate(
      _propFirmImages.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _hoverControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('propfirms-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_isVisible) {
          setState(() => _isVisible = true);
          _controller.forward();
        }
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _controller.value,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF737171),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'STILL HAVING DOUBTS?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Witness Our Students Success in Cracking PropFirms',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
            _buildPropFirmsCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropFirmsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: List.generate(
            _propFirmImages.length,
            (index) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final staggeredValue = (_controller.value - (index * 0.1))
                    .clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 0.9 + (staggeredValue * 0.1),
                  child: Opacity(
                    opacity: staggeredValue,
                    child: _buildPropFirmCard(_propFirmImages[index], index),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropFirmCard(String imagePath, int index) {
    return MouseRegion(
      onEnter: (_) => _hoverControllers[index].forward(),
      onExit: (_) => _hoverControllers[index].reverse(),
      child: AnimatedBuilder(
        animation: _hoverControllers[index],
        builder: (context, child) {
          final hoverValue = _hoverControllers[index].value;
          return Transform.scale(
            scale: 1.0 + (hoverValue * 0.05),
            child: Transform.translate(
              offset: Offset(0, -10 * hoverValue),
              child: Container(
                width: 180,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        Color.lerp(
                          Colors.white.withOpacity(0.1),
                          const Color(0xFF10B981).withOpacity(0.5),
                          hoverValue,
                        )!,
                    width: 1 + hoverValue,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 40 + (20 * hoverValue),
                      offset: Offset(0, 15 + (5 * hoverValue)),
                    ),
                    BoxShadow(
                      color: const Color(
                        0xFF10B981,
                      ).withOpacity(0.3 * hoverValue),
                      blurRadius: 30,
                      spreadRadius: 5 * hoverValue,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1E293B),
                              const Color(0xFF0F172A),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.workspace_premium,
                              color: Color(0xFF10B981),
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'PropFirm\nCertificate',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
