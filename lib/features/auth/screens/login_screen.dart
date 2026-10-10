import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import '../../../data/services/github_oauth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with WidgetsBindingObserver {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _isOAuthLoading = false;
  bool _isGoogleLoading = false;
  bool _isWaitingForOAuth = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tokenController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _isWaitingForOAuth) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isWaitingForOAuth) {
          setState(() {
            _isWaitingForOAuth = false;
            _isOAuthLoading = false;
            _isGoogleLoading = false;
          });
        }
      });
    }
  }

  // ═════════════════════════════════════
  // GITHUB OAUTH
  // ═════════════════════════════════════
  Future<void> _loginWithOAuth() async {
    setState(() {
      _isOAuthLoading = true;
      _isWaitingForOAuth = true;
      _errorMessage = null;
    });

    try {
      final authUrl = Uri.parse(GitHubOAuthService.getAuthUrl());
      if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
        _showError('Gagal membuka browser');
        return;
      }

      final code = await GitHubOAuthService.waitForAuthCode();
      if (!mounted) return;

      if (code == null) {
        setState(() {
          _isOAuthLoading = false;
          _isWaitingForOAuth = false;
        });
        return;
      }

      final result = await GitHubOAuthService.exchangeCodeForToken(code);
      if (!mounted) return;

      if (result == null || result['access_token'] == null) {
        _showError('Gagal menukar code dengan token');
        return;
      }

      final user = result['user'] as Map<String, dynamic>?;
      await AuthStorage.saveToken(
        token: result['access_token'] as String,
        username: user?['login'] as String?,
        avatarUrl: user?['avatar_url'] as String?,
      );

      if (mounted) context.go('/home');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isOAuthLoading = false;
          _isWaitingForOAuth = false;
        });
      }
    }
  }

  // ═════════════════════════════════════
  // GOOGLE OAUTH
  // ═════════════════════════════════════
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _isWaitingForOAuth = true;
      _errorMessage = null;
    });

    try {
      final authUrl = Uri.parse(GitHubOAuthService.getGoogleAuthUrl());
      if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
        _showError('Gagal membuka browser');
        return;
      }

      final result = await GitHubOAuthService.waitForGoogleCallback();
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isGoogleLoading = false;
          _isWaitingForOAuth = false;
        });
        return;
      }

      if (result['error'] != null && result['error']!.isNotEmpty) {
        _showError('Google error: ${result['error']}');
        return;
      }

      final token = result['access_token'];
      if (token == null || token.isEmpty) {
        _showError('Token tidak diterima');
        return;
      }

      await AuthStorage.saveToken(
        token: token,
        username: result['name'] ?? result['email'] ?? 'Google User',
        avatarUrl: result['picture'],
      );

      if (mounted) context.go('/home');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isWaitingForOAuth = false;
        });
      }
    }
  }

  // ═════════════════════════════════════
  // PAT LOGIN
  // ═════════════════════════════════════
  Future<void> _openGitHubTokenPage() async {
    final url = Uri.parse(
      'https://github.com/settings/tokens/new'
      '?scopes=repo,user,notifications,read:org'
      '&description=GitFlow%20Mobile%20App',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) _showError('Gagal membuka browser');
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _tokenController.text = data.text!.trim();
        _errorMessage = null;
      });
    }
  }

  Future<void> _loginWithPAT() async {
    FocusScope.of(context).unfocus();
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      _showError('Token tidak boleh kosong');
      return;
    }

    if (!token.startsWith('ghp_') && !token.startsWith('github_pat_')) {
      _showError('Format token tidak valid');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await GitHubApiService.validateToken(token);
      if (!mounted) return;

      if (user == null) {
        _showError('Token tidak valid atau sudah expired');
        return;
      }

      await AuthStorage.saveToken(
        token: token,
        username: user['login'] as String?,
        avatarUrl: user['avatar_url'] as String?,
      );

      if (mounted) context.go('/home');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
      _isOAuthLoading = false;
      _isGoogleLoading = false;
      _isWaitingForOAuth = false;
    });
  }

  // ═════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ═══ BACKGROUND MESH GRADIENT — FULL SCREEN ═══
            const _MeshGradientBackground(),

            // ═══ CONTENT ═══
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // ─── LOGO ───
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.35),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_tree_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─── TITLE ───
                    const Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.8,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Sign in to continue to GitFlow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ─── CONTINUE WITH GITHUB ───
                    _buildPrimaryButton(
                      onPressed: _isOAuthLoading || _isWaitingForOAuth
                          ? null
                          : _loginWithOAuth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.code_rounded,
                              size: 20, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Continue with GitHub',
                            style: _buttonTextStyle(Colors.white),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF111827),
                      isLoading: _isOAuthLoading,
                      loadingColor: Colors.white,
                    ),

                    const SizedBox(height: 12),

                    // ─── CONTINUE WITH GOOGLE ───
                    _buildPrimaryButton(
                      onPressed: _isGoogleLoading || _isWaitingForOAuth
                          ? null
                          : _loginWithGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _GoogleLogo(size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Continue with Google',
                            style: _buttonTextStyle(const Color(0xFF111827)),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFFE5E7EB),
                      isLoading: _isGoogleLoading,
                      loadingColor: const Color(0xFF6366F1),
                    ),

                    const SizedBox(height: 28),

                    // ─── DIVIDER ───
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: Color(0xFFE5E7EB))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const Expanded(
                            child: Divider(color: Color(0xFFE5E7EB))),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ─── SECTION HEADER ───
                    Row(
                      children: [
                        const Icon(
                          Icons.vpn_key_rounded,
                          size: 16,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Use Personal Access Token',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ─── TOKEN INPUT ───
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _tokenController,
                        obscureText: true,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                            onPressed: _pasteFromClipboard,
                            tooltip: 'Paste',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ─── OPEN GITHUB SETTINGS ───
                    Center(
                      child: TextButton.icon(
                        onPressed: _openGitHubTokenPage,
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: const Text('Generate a token on GitHub'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ─── SIGN IN BUTTON ───
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginWithPAT,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF6366F1)
                              .withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Sign In with Token',
                                style: _buttonTextStyle(Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── ERROR MESSAGE ───
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFFDC2626),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ─── SECURITY NOTE ───
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF16A34A),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tokens are encrypted and stored only on your device.',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Color(0xFF166534),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── FOOTER ───
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'By continuing you agree to our '),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════
  // HELPER WIDGETS
  // ═════════════════════════════════════
  TextStyle _buttonTextStyle(Color color) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.1,
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required Widget child,
    required Color backgroundColor,
    Color? borderColor,
    bool isLoading = false,
    Color loadingColor = Colors.white,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: loadingColor,
                  strokeWidth: 2.5,
                ),
              )
            : child,
      ),
    );
  }
}

// ═════════════════════════════════════
// MESH GRADIENT BACKGROUND
// ═════════════════════════════════════
class _MeshGradientBackground extends StatelessWidget {
  const _MeshGradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E8FF),
            Color(0xFFE0E7FF),
            Color(0xFFFCE7F3),
            Color(0xFFF0FDFA),
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Blob 1 — ungu atas kiri
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Blob 2 — pink bawah kanan
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withValues(alpha: 0.25),
                    const Color(0xFFEC4899).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Blob 3 — indigo tengah atas
          Positioned(
            top: 100,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.20),
                    const Color(0xFF6366F1).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Blob 4 — cyan bawah kiri
          Positioned(
            bottom: 50,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withValues(alpha: 0.18),
                    const Color(0xFF06B6D4).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════
// GOOGLE LOGO (mini widget)
// ═════════════════════════════════════
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;

    paint.strokeWidth = strokeWidth;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.butt;

    // Biru — atas
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -0.5,
      1.2,
      false,
      paint,
    );

    // Hijau — kiri bawah
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      1.7,
      1.0,
      false,
      paint,
    );

    // Kuning — kiri
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      2.7,
      1.0,
      false,
      paint,
    );

    // Merah — atas kiri
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.7,
      1.5,
      false,
      paint,
    );

    // Horizontal bar biru
    paint.color = const Color(0xFF4285F4);
    paint.strokeWidth = strokeWidth;
    final barY = center.dy;
    final barStartX = center.dx;
    final barEndX = size.width - strokeWidth * 0.2;
    canvas.drawLine(
      Offset(barStartX, barY),
      Offset(barEndX, barY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}