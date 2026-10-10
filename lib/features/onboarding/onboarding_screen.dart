import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _slides = [
    // ─────────────────────────────────────
    // SLIDE 1 — REPOSITORIES
    // ─────────────────────────────────────
    OnboardingData(
      badge: 'REPOSITORIES',
      badgeColor: const Color(0xFF8B5CF6),
      title: 'All Your Repos\nin One Place',
      description:
          'Public, private, forked and starred — beautifully organised, searchable in a keystroke, cached for offline.',
      bgColor: const Color(0xFFF3E8FF),
      accentColor: const Color(0xFF8B5CF6),
      lottiePath: 'assets/lottie/slide_1.json',
    ),

    // ─────────────────────────────────────
    // SLIDE 2 — CODE REVIEW
    // ─────────────────────────────────────
    OnboardingData(
      badge: 'CODE REVIEW',
      badgeColor: const Color(0xFFEC4899),
      title: 'Code, Review,\nMerge — Anywhere',
      description:
          'A native diff renderer with syntax highlighting, inline comments and one-tap merges from the train.',
      bgColor: const Color(0xFFFCE7F3),
      accentColor: const Color(0xFFEC4899),
      lottiePath: 'assets/lottie/slide_2.json',
    ),

    // ─────────────────────────────────────
    // SLIDE 3 — NOTIFICATIONS
    // ─────────────────────────────────────
    OnboardingData(
      badge: 'NOTIFICATIONS',
      badgeColor: const Color(0xFF06B6D4),
      title: 'Stay Notified\nin Real-Time',
      description:
          'Mentions, CI failures and reviews pushed the instant they happen — with smart muting that respects focus.',
      bgColor: const Color(0xFFE0F2FE),
      accentColor: const Color(0xFF06B6D4),
      lottiePath: 'assets/lottie/slide_3.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Get Started → ke Login
      context.go('/login');
    }
  }

  void _skip() {
    // Skip → langsung ke Login
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _slides[_currentPage].bgColor,
        child: SafeArea(
          child: Column(
            children: [
              // ─── Top Bar ───
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'GitFlow',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── PageView ───
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _OnboardingSlide(data: _slides[index]);
                  },
                ),
              ),

              // ─── Bottom Card ───
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _slides[_currentPage]
                            .badgeColor
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _slides[_currentPage].badgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _slides[_currentPage].badge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _slides[_currentPage].badgeColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      _slides[_currentPage].title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      _slides[_currentPage].description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dots + Button
                    Row(
                      children: [
                        Row(
                          children: List.generate(_slides.length, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? _slides[_currentPage].accentColor
                                    : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _slides[_currentPage].accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _slides.length - 1
                                    ? 'Get Started 🎉'
                                    : 'Next',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_currentPage != _slides.length - 1) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 18),
                              ],
                            ],
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
  }
}

// ─────────────────────────────────────────────
// SLIDE — FULL LOTTIE
// ─────────────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: SizedBox(
          width: 320,
          height: 320,
          child: Lottie.asset(
            data.lottiePath,
            fit: BoxFit.contain,
            repeat: true,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.animation,
                        size: 60,
                        color: data.accentColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Animasi belum tersedia',
                        style: TextStyle(
                          fontSize: 14,
                          color: data.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class OnboardingData {
  final String badge;
  final Color badgeColor;
  final String title;
  final String description;
  final Color bgColor;
  final Color accentColor;
  final String lottiePath;

  OnboardingData({
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.accentColor,
    required this.lottiePath,
  });
}