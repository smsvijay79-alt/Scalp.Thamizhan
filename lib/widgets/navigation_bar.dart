import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  final Function(String) onNavigate;

  const CustomNavigationBar({super.key, required this.onNavigate});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  bool _isMobileMenuOpen = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  void _checkLoginStatus() {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isLoggedIn = session != null;
    });
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await Supabase.instance.client.auth.signOut();
                // State update listener will handle UI update
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  image: const DecorationImage(
                    image: AssetImage('assets/logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Scalp.tamizhan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Desktop Navigation
          if (!isMobile) ...[
            Row(
              children: [
                _buildNavLink('Home', () => widget.onNavigate('home')),
                const SizedBox(width: 40),
                _buildNavLink('Courses', () => widget.onNavigate('plan')),
                const SizedBox(width: 40),
                _buildNavLink('About Us', () => widget.onNavigate('about')),
                const SizedBox(width: 40),
                _buildNavLink(
                  'Testimonials',
                  () => widget.onNavigate('testimonials'),
                ),
                const SizedBox(width: 40),
                const SizedBox(width: 40),
                _buildNavLink('FAQ', () => widget.onNavigate('faq')),
                const SizedBox(width: 40),
                if (_isLoggedIn)
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemBuilder: (context) {
                      final user = Supabase.instance.client.auth.currentUser;
                      final email = user?.email ?? 'User';
                      // Try to get name from metadata, fallback to email username or 'User'
                      String displayName = 'User';
                      if (user?.userMetadata != null &&
                          user!.userMetadata!['full_name'] != null) {
                        displayName = user.userMetadata!['full_name'];
                      } else {
                        displayName = email.split('@')[0];
                      }

                      return [
                        PopupMenuItem<String>(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'My Profile & Courses',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 'logout') {
                        _showLogoutConfirmation(context);
                      } else if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCDFF00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.black),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDFF00),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCDFF00).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // Mobile Menu Icon
          if (isMobile)
            IconButton(
              icon: Icon(
                _isMobileMenuOpen ? Icons.close : Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _isMobileMenuOpen = !_isMobileMenuOpen;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
