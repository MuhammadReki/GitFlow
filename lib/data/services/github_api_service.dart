import 'package:dio/dio.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';

class GitHubApiService {
  static const String _baseUrl = 'https://api.github.com';

  static Dio _dio(String token) {
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  /// Validate token — cek ke GitHub API
  /// Return: Map dengan info user kalau valid, null kalau invalid
  static Future<Map<String, dynamic>?> validateToken(String token) async {
    try {
      final response = await _dio(token).get('/user');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }
      rethrow;
    }
  }

  /// Get user info
  static Future<GitHubUser?> getUser(String token) async {
    try {
      final response = await _dio(token).get('/user');
      return GitHubUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getUser error: ${e.message}');
      return null;
    }
  }

  /// Get user repos — sort by updated, 100 per page
  static Future<List<GitHubRepo>> getUserRepos(
    String token, {
    int perPage = 100,
  }) async {
    try {
      final response = await _dio(token).get(
        '/user/repos',
        queryParameters: {
          'sort': 'updated',
          'per_page': perPage,
          'affiliation': 'owner,collaborator,organization_member',
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubRepo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getUserRepos error: ${e.message}');
      return [];
    }
  }
}