import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _verifiedPlans = [];
  List<Map<String, dynamic>> _pendingPlans = [];
  List<Map<String, dynamic>> _availableVideos = [];
  bool _isBlurred = false;
  String? _selectedVideoUrl;
  String? _selectedVideoTitle;
  late final FocusNode _focusNode;

  int _violationCount = 0;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadProfileData();
    _setupSecurity();
  }

  void _setupSecurity() {
    _lifecycleListener = AppLifecycleListener(
      onInactive: () {
        if (mounted) setState(() => _isBlurred = true);
        _handleViolation("Focus lost - possible screen capture attempt");
      },
      onResume: () {
        if (mounted) setState(() => _isBlurred = false);
      },
      onHide: () {
        if (mounted) setState(() => _isBlurred = true);
      },
      onShow: () {
        if (mounted) setState(() => _isBlurred = false);
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _handleViolation(String reason) {
    if (!mounted) return;
    setState(() {
      _violationCount++;
    });

    if (_violationCount >= 3) {
      _punishUser();
    } else {
      _warnUser(reason);
    }
  }

  void _warnUser(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'SECURITY WARNING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Screenshot or screen recording attempts are strictly prohibited to protect our premium content.\n\n'
              'Violation Count: $_violationCount/3\n\n'
              'Repeat violations will result in your session being terminated immediately.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'I UNDERSTAND',
                  style: TextStyle(color: Color(0xFFCDFF00)),
                ),
              ),
            ],
          ),
    );
  }

  void _punishUser() {
    // In a real app, you might also update their status in the database to 'banned'
    _supabase.auth.signOut();

    // Attempt to redirect away as "exiting the website"
    // We use a simple redirect to a blank page or a goodbye page
    try {
      // Using navigation to push a "Banned" state locally first
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (context) => Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.block, color: Colors.red, size: 80),
                      const SizedBox(height: 24),
                      const Text(
                        'ACCESS REVOKED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Multiple security violations detected. Access has been terminated.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Error during punishment: $e");
    }
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // 1. Fetch all user payments
      final paymentsResponse = await _supabase
          .from('payments')
          .select()
          .eq('user_id', user.id);

      final allPayments = List<Map<String, dynamic>>.from(paymentsResponse);

      // Separate verified/paid and pending
      // Treat both 'verified' and 'paid' (automated) as active
      _verifiedPlans =
          allPayments
              .where((p) => p['status'] == 'verified' || p['status'] == 'paid')
              .toList();
      _pendingPlans =
          allPayments.where((p) => p['status'] == 'pending').toList();

      if (_verifiedPlans.isNotEmpty) {
        // 2. Fetch videos matching verified plans
        // We match by checking if the video's plan_required matches any of our owned plans
        final planNames =
            _verifiedPlans
                .map((p) => p['plan_name'].toString().toUpperCase())
                .toList();

        final videosResponse = await _supabase.from('videos').select();

        final allVideos = List<Map<String, dynamic>>.from(videosResponse);

        // Filter videos: user sees a video if its 'plan_required' matches any of their paid plans
        _availableVideos =
            allVideos.where((video) {
              final required =
                  video['plan_required']?.toString().toUpperCase() ?? '';

              // If the video is marked for 'ALL', everyone sees it
              if (required == 'ALL' || required.isEmpty) return true;

              return planNames.any((owned) {
                final ownedPlan = owned.toUpperCase();
                // Match if the plan name contains the required keyword or vice versa
                // e.g., 'BASIC PLAN' matches 'BASIC'
                return ownedPlan.contains(required) ||
                    required.contains(ownedPlan);
              });
            }).toList();
      } else {
        _availableVideos = [];
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _watchVideo(String url, String title) async {
    setState(() {
      _selectedVideoUrl = url;
      _selectedVideoTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final email = user?.email ?? 'User';
    String displayName =
        user?.userMetadata?['full_name'] ?? email.split('@')[0];

    return KeyboardListener(
      focusNode: _focusNode..requestFocus(),
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        final keyLabel = event.logicalKey.keyLabel.toLowerCase();
        final isControl = HardwareKeyboard.instance.isControlPressed;
        final isShift = HardwareKeyboard.instance.isShiftPressed;
        final isMeta = HardwareKeyboard.instance.isMetaPressed;
        final isAlt = HardwareKeyboard.instance.isAltPressed;

        bool isViolation = false;

        // PrintScreen (Universal)
        if (keyLabel.contains('print screen') || keyLabel.contains('prtscr')) {
          isViolation = true;
        }

        // Windows: Win+Shift+S (Snipping) or Win+PrtSc
        if (isMeta && (isShift && keyLabel == 's')) isViolation = true;

        // Mac: Cmd+Shift+3 or 4 or 5
        if (isMeta &&
            isShift &&
            (keyLabel == '3' || keyLabel == '4' || keyLabel == '5')) {
          isViolation = true;
        }

        // Common Inspect/DevTools: F12, Ctrl+Shift+I
        if (keyLabel == 'f12') isViolation = true;
        if (isControl && isShift && keyLabel == 'i') isViolation = true;

        // Save Page: Ctrl+S
        if (isControl && keyLabel == 's') isViolation = true;

        if (isViolation) {
          _handleViolation(
            "Security shortcut detected: ${keyLabel.toUpperCase()}",
          );
        }
      },
      child: GestureDetector(
        onSecondaryTap:
            () => _handleViolation("Right-click attempt"), // Block right-click
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFF0F172A),
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: true,
                    pinned: true,
                    backgroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Learning Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFFCDFF00),
                        ),
                        onPressed: _loadProfileData,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child:
                        _isLoading
                            ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFCDFF00),
                                ),
                              ),
                            )
                            : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileHeader(displayName, email),
                                  const SizedBox(height: 40),

                                  if (_verifiedPlans.isNotEmpty) ...[
                                    _buildSectionTitle('ACTIVE PLANS'),
                                    const SizedBox(height: 16),
                                    _buildVerifiedPlansList(),
                                    const SizedBox(height: 40),
                                  ],

                                  if (_availableVideos.isNotEmpty) ...[
                                    _buildSectionTitle('COURSE VIDEOS'),
                                    const SizedBox(height: 16),
                                    _buildVideosGrid(),
                                  ] else if (_verifiedPlans.isEmpty)
                                    _buildEmptyState(
                                      Icons.lock_outline,
                                      'Purchase a plan to unlock premium video content.',
                                    ),
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),

            // 1. FLOATING WATERMARK (Deterrent)
            IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.08,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Text(
                      "$email\nSCALP THAMIZHAN\nDO NOT COPY",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. IMMEDIATE BLUR ON FOCUS LOSS
            if (_isBlurred)
              IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: BackdropFilter(
                    filter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.security,
                            color: Color(0xFFCDFF00),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "SCREEN PROTECTED",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Return to focus to continue viewing.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // 3. VIDEO PLAYER OVERLAY
            if (_selectedVideoUrl != null)
              Positioned.fill(
                child: _VideoPlayerOverlay(
                  url: _selectedVideoUrl!,
                  title: _selectedVideoTitle ?? 'Video Lesson',
                  onClose: () {
                    setState(() {
                      _selectedVideoUrl = null;
                      _selectedVideoTitle = null;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isSub = false}) {
    return Text(
      title,
      style: TextStyle(
        color: isSub ? Colors.white60 : Colors.white,
        fontSize: isSub ? 14 : 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCDFF00), Color(0xFFD4FF33)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCDFF00).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.black,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedPlansList() {
    return Column(
      children:
          _verifiedPlans.map((plan) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      plan['plan_name'].toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPendingPlansList() {
    return Column(
      children:
          _pendingPlans.map((plan) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      plan['plan_name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildVideosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Smaller size by having more columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Taller and thinner cards
      ),
      itemCount: _availableVideos.length,
      itemBuilder: (context, index) {
        final video = _availableVideos[index];
        final String videoUrl = video['video_url'] ?? '';

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap:
                videoUrl.isNotEmpty
                    ? () => _watchVideo(
                      videoUrl,
                      video['title'] ?? 'Untitled Lesson',
                    )
                    : null,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.black26],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child:
                              video['thumbnail_url'] != null &&
                                      video['thumbnail_url']
                                          .toString()
                                          .isNotEmpty
                                  ? Image.network(
                                    video['thumbnail_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.play_circle_fill_rounded,
                                                color: Color(0xFFCDFF00),
                                                size: 32,
                                              ),
                                            ),
                                  )
                                  : const Center(
                                    child: Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: Color(0xFFCDFF00),
                                      size: 32,
                                    ),
                                  ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Premium',
                              style: TextStyle(
                                color: Color(0xFFCDFF00),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video['title'] ?? 'Untitled Lesson',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (video['description'] != null &&
                            video['description'].toString().isNotEmpty)
                          Text(
                            video['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.folder_open,
                              color: Colors.white30,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                video['plan_required'] ?? 'All Plans',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 11,
                                ),
                              ),
                            ),
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
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white10, size: 64),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerOverlay extends StatefulWidget {
  final String url;
  final String title;
  final VoidCallback onClose;

  const _VideoPlayerOverlay({
    required this.url,
    required this.title,
    required this.onClose,
  });

  @override
  State<_VideoPlayerOverlay> createState() => _VideoPlayerOverlayState();
}

class _VideoPlayerOverlayState extends State<_VideoPlayerOverlay> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint("Initializing video: ${widget.url}");
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );

      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError) {
          debugPrint(
            "Video Player Error: ${_videoPlayerController.value.errorDescription}",
          );
          if (mounted && !_hasError) setState(() => _hasError = true);
        }
      });

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFCDFF00),
          handleColor: const Color(0xFFCDFF00),
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white10,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFCDFF00)),
          ),
        ),
        autoInitialize: true,
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Video initialization caught exception: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onClose,
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child:
            _hasError
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Unable to play video here",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This is likely a CORS issue in Supabase.\nCheck your CORS settings and ensure the bucket is Public.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Link copied! Paste it in a new tab to test",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text("COPY VIDEO LINK"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: widget.onClose,
                      child: const Text(
                        "BACK TO HUB",
                        style: TextStyle(color: Color(0xFFCDFF00)),
                      ),
                    ),
                  ],
                )
                : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
                : const CircularProgressIndicator(color: Color(0xFFCDFF00)),
      ),
    );
  }
}
