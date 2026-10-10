import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GitHubOAuthService {
  // ─────────────────────────────────────
  // KONFIGURASI GITHUB
  // ─────────────────────────────────────
  static const String clientId = 'Ov23li93g6M8gDfk5taM';
  static const String backendUrl =
      'https://gitflow-backend-xi.vercel.app/api/auth/github';
  static const String redirectUri = 'gitflow://auth/callback';
  static const String scopes = 'repo,user,notifications,read:org';

  // ─────────────────────────────────────
  // KONFIGURASI GOOGLE
  // тЪая╕П GANTI INI: copy pake tombol ЁЯУЛ di Google Console
  // ─────────────────────────────────────
  static const String googleClientId =
      'PASTE_CLIENT_ID_DISINI.apps.googleusercontent.com';
  static const String googleRedirectUri =
      'https://gitflow-backend-xi.vercel.app/api/auth/google/callback';
  static const String googleScopes = 'email profile';

  // ═════════════════════════════════════
  // GITHUB OAUTH
  // ═════════════════════════════════════

  static String getAuthUrl() {
    return 'https://github.com/login/oauth/authorize'
        '?client_id=$clientId'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&scope=${Uri.encodeComponent(scopes)}';
  }

  static Future<String?> waitForAuthCode({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final completer = Completer<String?>();
    final appLinks = AppLinks();

    late StreamSubscription<Uri> subscription;

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        debugPrint('[GitHubOAuth] тП▒ Timeout nunggu callback');
        subscription.cancel();
        completer.complete(null);
      }
    });

    subscription = appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[GitHubOAuth] ЁЯФЧ Deep link masuk: $uri');

        // тмЗ Lebih fleksibel: cek scheme aja + path
        final isGitflow = uri.scheme == 'gitflow';
        final isAuth = uri.host == 'auth';
        final isCallback = uri.path == '/callback' || uri.path.isEmpty;

        if (isGitflow && isAuth && isCallback) {
          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];

          debugPrint('[GitHubOAuth] code=$code, error=$error');

          if (!completer.isCompleted) {
            timer.cancel();
            subscription.cancel();

            if (error != null) {
              completer.complete(null);
            } else {
              completer.complete(code);
            }
          }
        }
      },
      onError: (err) {
        debugPrint('[GitHubOAuth] тЭМ Stream error: $err');
        if (!completer.isCompleted) {
          timer.cancel();
          completer.complete(null);
        }
      },
    );

    return completer.future;
  }

  static Future<Map<String, dynamic>?> exchangeCodeForToken(
    String code,
  ) async {
    try {
      debugPrint('[GitHubOAuth] ЁЯФД Exchange code ke backend...');
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      final response = await dio.post(
        backendUrl,
        data: {'code': code},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      debugPrint('[GitHubOAuth] тЬЕ Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[GitHubOAuth] тЭМ Backend error: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      debugPrint('[GitHubOAuth] тЭМ Unexpected error: $e');
      return null;
    }
  }

  // ═════════════════════════════════════
  // GOOGLE OAUTH
  // ═════════════════════════════════════

  static String getGoogleAuthUrl() {
    return 'https://accounts.google.com/o/oauth2/v2/auth'
        '?client_id=$googleClientId'
        '&redirect_uri=${Uri.encodeComponent(googleRedirectUri)}'
        '&response_type=code'
        '&scope=${Uri.encodeComponent(googleScopes)}'
        '&access_type=offline'
        '&prompt=consent';
  }

  static Future<Map<String, String>?> waitForGoogleCallback({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final completer = Completer<Map<String, String>?>();
    final appLinks = AppLinks();

    late StreamSubscription<Uri> subscription;

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        debugPrint('[GoogleOAuth] тП▒ Timeout nunggu callback');
        subscription.cancel();
        completer.complete(null);
      }
    });

    subscription = appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[GoogleOAuth] ЁЯФЧ Deep link masuk: $uri');

        final isGitflow = uri.scheme == 'gitflow';
        final isAuth = uri.host == 'auth';
        final isGoogle = uri.path == '/google';

        if (isGitflow && isAuth && isGoogle) {
          debugPrint('[GoogleOAuth] Params: ${uri.queryParameters}');
          if (!completer.isCompleted) {
            timer.cancel();
            subscription.cancel();
            completer.complete(uri.queryParameters);
          }
        }
      },
      onError: (err) {
        debugPrint('[GoogleOAuth] тЭМ Stream error: $err');
        if (!completer.isCompleted) {
          timer.cancel();
          completer.complete(null);
        }
      },
    );

    return completer.future;
  }
}