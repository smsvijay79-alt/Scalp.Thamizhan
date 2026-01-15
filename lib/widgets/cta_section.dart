import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// CTA Section
class CTASection extends StatelessWidget {
  const CTASection({Key? key}) : super(key: key);

  Future<void> _launchDiscord() async {
    final Uri url = Uri.parse('https://discord.gg/UNhEJq7ZeP');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                top: 0,
                left: -200,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF282828).withOpacity(0.5),
                    border: Border.all(
                      color: const Color(0xFF282828).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -50,
                left: -250,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF3c3c3c).withOpacity(0.67),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Main content
              Container(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 24 : 60,
                  80,
                  isMobile ? 24 : 60,
                  80,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A3A3A), Color(0xFF2E2E2E)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Wanna Trade Live With Us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 36 : 56,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Then Join Our Discord Server And Trade With Experienced Folks To Level Up Your Trading Career',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFFb0b0b0),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeature('Community To Help'),
                        _buildFeature('Live Trading Sessions'),
                        _buildFeature('Direct Mentor Guidance'),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isMobile) ...[
                          _buildDivider(),
                          const SizedBox(width: 20),
                        ],
                        ElevatedButton(
                          onPressed: _launchDiscord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00ee83),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 32 : 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Join Discord',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 20),
                          _buildDivider(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF01fb2f),
            ),
            child: const Center(
              child: Icon(Icons.check, size: 12, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Color(0xFFd0d0d0)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 120,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
