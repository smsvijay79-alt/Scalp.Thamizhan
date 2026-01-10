import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Footer Section
class FooterSection extends StatelessWidget {
  const FooterSection({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              // Main Footer Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Section - Logo and Contact
                  SizedBox(
                    width: 1000,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Container(
                          width: 1000,
                          height: 1000,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.white38,
                                  size: 150,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Divider
                        Container(
                          width: 140,
                          height: 1,
                          color: const Color(0xFF2a2a2a),
                        ),
                        const SizedBox(height: 25),
                        // Social Icons
                        Row(
                          children: [
                            _buildSocialIcon(
                              FontAwesomeIcons.instagram,
                              'https://instagram.com',
                            ),
                            const SizedBox(width: 12),
                            _buildSocialIcon(
                              FontAwesomeIcons.youtube,
                              'https://youtube.com',
                            ),
                            const SizedBox(width: 12),
                            _buildSocialIcon(
                              FontAwesomeIcons.discord,
                              'https://discord.gg/UNhEJq7ZeP',
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Contact Info
                        _buildContactLink(
                          'support@Scalp.tamizhan.in',
                          'mailto:support@Scalp.tamizhan.in',
                        ),
                        const SizedBox(height: 12),
                        _buildContactLink(
                          '+91 90254 36814',
                          'tel:+919025436814',
                        ),
                      ],
                    ),
                  ),
                  // Right Section - Footer Columns
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFooterColumn('PAGES', [
                          {'text': 'Home', 'url': '#home'},
                          {'text': 'About Us', 'url': '#about'},
                          {'text': 'Courses', 'url': '#plan'},
                          {'text': 'Testimonials', 'url': '#testimonials'},
                          {'text': 'FAQs', 'url': '#faq'},
                        ]),
                        const SizedBox(width: 80),
                        _buildFooterColumn('PRIVACY POLICY', [
                          {'text': 'Terms And Conditions', 'url': '#'},
                          {
                            'text': 'Responsible Risk Disclosure Policy',
                            'url': '#',
                          },
                          {'text': 'Refund Policy', 'url': '#'},
                          {'text': 'Disclaimer', 'url': '#'},
                        ]),
                        const SizedBox(width: 80),
                        _buildFooterColumn('COURSES', [
                          {'text': 'Discord Subscription', 'url': '#'},
                          {'text': 'AlchemyX Trading Program', 'url': '#'},
                          {'text': 'Personal Mentorship', 'url': '#'},
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Copyright
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 30),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF1a1a1a), width: 1),
                  ),
                ),
                child: const Text(
                  'Copyright © 2024 Scalp.Thamizha - All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2a2a2a), width: 1),
        ),
        child: Center(child: FaIcon(icon, size: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildContactLink(String text, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF888888),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<Map<String, String>> links) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                links.map((link) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _launchURL(link['url']!),
                      child: Text(
                        link['text']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
