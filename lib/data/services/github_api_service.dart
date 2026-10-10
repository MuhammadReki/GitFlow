import 'package:dio/dio.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';
import '../models/github_file.dart';
import '../models/github_issue.dart';
import '../models/github_notification.dart';
import '../models/github_commit.dart';
import '../models/github_comment.dart';
import '../models/github_branch.dart';
import '../models/github_pr.dart';
import '../models/github_commit_detail.dart';
import '../models/github_release.dart';
import '../models/github_code_search.dart';
import '../models/github_gist.dart';
import '../models/github_action.dart';
import '../models/github_compare.dart';

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

  // ═══ USER ═══
  static Future<Map<String, dynamic>?> validateToken(String token) async {
    try {
      final response = await _dio(token).get('/user');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      rethrow;
    }
  }

  static Future<GitHubUser?> getUser(String token) async {
    try {
      final response = await _dio(token).get('/user');
      return GitHubUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getUser error: ${e.message}');
      return null;
    }
  }

  static Future<GitHubUser?> getUserByUsername(
    String token,
    String username,
  ) async {
    try {
      final response = await _dio(token).get('/users/$username');
      return GitHubUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getUserByUsername error: ${e.message}');
      return null;
    }
  }

  // ═══ UPDATE PROFILE ═══
  static Future<Map<String, dynamic>?> updateProfile(
    String token, {
    String? name,
    String? bio,
    String? company,
    String? location,
    String? blog,
    String? twitterUsername,
    String? hireable,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (bio != null) data['bio'] = bio;
      if (company != null) data['company'] = company;
      if (location != null) data['location'] = location;
      if (blog != null) data['blog'] = blog;
      if (twitterUsername != null) {
        data['twitter_username'] = twitterUsername;
      }
      if (hireable != null) data['hireable'] = hireable == 'true';

      final response = await _dio(token).patch('/user', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('updateProfile error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ═══ FOLLOWERS / FOLLOWING ═══
  static Future<List<GitHubUser>> getFollowers(
    String token, {
    String? username,
    int perPage = 100,
  }) async {
    try {
      final endpoint =
          username == null ? '/user/followers' : '/users/$username/followers';
      final response = await _dio(token).get(
        endpoint,
        queryParameters: {'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getFollowers error: ${e.message}');
      return [];
    }
  }

  static Future<List<GitHubUser>> getFollowing(
    String token, {
    String? username,
    int perPage = 100,
  }) async {
    try {
      final endpoint =
          username == null ? '/user/following' : '/users/$username/following';
      final response = await _dio(token).get(
        endpoint,
        queryParameters: {'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getFollowing error: ${e.message}');
      return [];
    }
  }

  static Future<bool> checkFollowing(
    String token,
    String username,
  ) async {
    try {
      final response = await _dio(token).get('/user/following/$username');
      return response.statusCode == 204;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      print('checkFollowing error: ${e.message}');
      return false;
    }
  }

  static Future<bool> followUser(
    String token,
    String username,
  ) async {
    try {
      await _dio(token).put('/user/following/$username');
      return true;
    } on DioException catch (e) {
      print('followUser error: ${e.message}');
      return false;
    }
  }

  static Future<bool> unfollowUser(
    String token,
    String username,
  ) async {
    try {
      await _dio(token).delete('/user/following/$username');
      return true;
    } on DioException catch (e) {
      print('unfollowUser error: ${e.message}');
      return false;
    }
  }

  // ═══ REPOS ═══
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

  static Future<List<GitHubRepo>> getUserReposByUsername(
    String token,
    String username, {
    int perPage = 30,
  }) async {
    try {
      final response = await _dio(token).get(
        '/users/$username/repos',
        queryParameters: {'sort': 'updated', 'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubRepo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getUserReposByUsername error: ${e.message}');
      return [];
    }
  }

  static Future<GitHubRepo?> getRepo(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final response = await _dio(token).get('/repos/$owner/$repo');
      return GitHubRepo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getRepo error: ${e.message}');
      return null;
    }
  }

  // ═══ CREATE REPO ═══
  static Future<Map<String, dynamic>?> createRepo(
    String token, {
    required String name,
    String? description,
    bool private = false,
    bool autoInit = true,
    String? gitignoreTemplate,
    String? licenseTemplate,
    String? homepage,
    bool hasIssues = true,
    bool hasProjects = true,
    bool hasWiki = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'private': private,
        'auto_init': autoInit,
        'has_issues': hasIssues,
        'has_projects': hasProjects,
        'has_wiki': hasWiki,
      };
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (gitignoreTemplate != null && gitignoreTemplate.isNotEmpty) {
        data['gitignore_template'] = gitignoreTemplate;
      }
      if (licenseTemplate != null && licenseTemplate.isNotEmpty) {
        data['license_template'] = licenseTemplate;
      }
      if (homepage != null && homepage.isNotEmpty) {
        data['homepage'] = homepage;
      }

      final response = await _dio(token).post('/user/repos', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('createRepo error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ═══ STARRED REPOS ═══
  static Future<List<GitHubRepo>> getMyStarredRepos(
    String token, {
    int perPage = 100,
  }) async {
    try {
      final response = await _dio(token).get(
        '/user/starred',
        queryParameters: {
          'per_page': perPage,
          'sort': 'updated',
          'direction': 'desc',
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubRepo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getMyStarredRepos error: ${e.message}');
      return [];
    }
  }

  static Future<List<GitHubRepo>> getUserStarredRepos(
    String token,
    String username, {
    int perPage = 100,
  }) async {
    try {
      final response = await _dio(token).get(
        '/users/$username/starred',
        queryParameters: {
          'per_page': perPage,
          'sort': 'updated',
          'direction': 'desc',
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubRepo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getUserStarredRepos error: ${e.message}');
      return [];
    }
  }

  // ═══ FILES ═══
  static Future<List<GitHubFile>> getRepoContents(
    String token,
    String owner,
    String repo, {
    String path = '',
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/contents/$path',
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubFile.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getRepoContents error: ${e.message}');
      return [];
    }
  }

  // ═══ README ═══
  static Future<String?> getReadme(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/readme',
        options: Options(
          headers: {'Accept': 'application/vnd.github.raw+json'},
        ),
      );
      return response.data as String?;
    } on DioException catch (e) {
      print('getReadme error: ${e.message}');
      return null;
    }
  }

  // ═══ ISSUES (per repo) ═══
  static Future<List<GitHubIssue>> getIssues(
    String token,
    String owner,
    String repo, {
    String state = 'open',
    int perPage = 50,
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/issues',
        queryParameters: {
          'state': state,
          'per_page': perPage,
          'sort': 'updated',
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubIssue.fromJson(e as Map<String, dynamic>))
          .where((issue) => !issue.isPullRequest)
          .toList();
    } on DioException catch (e) {
      print('getIssues error: ${e.message}');
      return [];
    }
  }

  // ═══ PULL REQUESTS (per repo, return GitHubIssue) ═══
  static Future<List<GitHubIssue>> getPullRequests(
    String token,
    String owner,
    String repo, {
    String state = 'open',
    int perPage = 50,
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/pulls',
        queryParameters: {
          'state': state,
          'per_page': perPage,
          'sort': 'updated',
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubIssue.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getPullRequests error: ${e.message}');
      return [];
    }
  }

  // ═══ ALL ISSUES ═══
  static Future<List<GitHubIssue>> getAllIssues(
    String token, {
    String state = 'open',
    int perPage = 100,
  }) async {
    try {
      final response = await _dio(token).get(
        '/issues',
        queryParameters: {
          'state': state,
          'per_page': perPage,
          'sort': 'updated',
          'direction': 'desc',
          'filter': 'all',
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubIssue.fromJson(e as Map<String, dynamic>))
          .where((issue) => !issue.isPullRequest)
          .toList();
    } on DioException catch (e) {
      print('getAllIssues error: ${e.message}');
      return [];
    }
  }

  // ═══ ALL PULL REQUESTS ═══
  static Future<List<GitHubIssue>> getAllPullRequests(
    String token, {
    String state = 'open',
    int perPage = 50,
  }) async {
    try {
      final query = 'is:pr author:@me state:$state';
      final response = await _dio(token).get(
        '/search/issues',
        queryParameters: {
          'q': query,
          'per_page': perPage,
          'sort': 'updated',
          'order': 'desc',
        },
      );
      final items = (response.data['items'] as List<dynamic>? ?? <dynamic>[]);
      return items
          .map((e) => GitHubIssue.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getAllPullRequests error: ${e.message}');
      return [];
    }
  }

  // ═══ NOTIFICATIONS ═══
  static Future<List<GitHubNotification>> getNotifications(
    String token, {
    bool all = false,
    int perPage = 50,
  }) async {
    try {
      final response = await _dio(token).get(
        '/notifications',
        queryParameters: {'all': all, 'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getNotifications error: ${e.message}');
      return [];
    }
  }

  static Future<bool> markNotificationAsRead(
    String token,
    String notificationId,
  ) async {
    try {
      await _dio(token).patch('/notifications/threads/$notificationId');
      return true;
    } on DioException catch (e) {
      print('markNotificationAsRead error: ${e.message}');
      return false;
    }
  }

  static Future<bool> markAllNotificationsAsRead(String token) async {
    try {
      await _dio(token).put('/notifications');
      return true;
    } on DioException catch (e) {
      print('markAllNotificationsAsRead error: ${e.message}');
      return false;
    }
  }

  // ═══ SEARCH ═══
  static Future<List<GitHubRepo>> searchRepos(
    String token,
    String query, {
    int perPage = 30,
  }) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio(token).get(
        '/search/repositories',
        queryParameters: {
          'q': query,
          'per_page': perPage,
          'sort': 'stars',
          'order': 'desc',
        },
      );
      final items = (response.data['items'] as List<dynamic>? ?? <dynamic>[]);
      return items
          .map((e) => GitHubRepo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('searchRepos error: ${e.message}');
      return [];
    }
  }

  static Future<List<GitHubUser>> searchUsers(
    String token,
    String query, {
    int perPage = 30,
  }) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio(token).get(
        '/search/users',
        queryParameters: {'q': query, 'per_page': perPage},
      );
      final items = (response.data['items'] as List<dynamic>? ?? <dynamic>[]);
      return items
          .map((e) => GitHubUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('searchUsers error: ${e.message}');
      return [];
    }
  }

  // ═══ STAR REPO ═══
  static Future<bool> isRepoStarred(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final response = await _dio(token).get('/user/starred/$owner/$repo');
      return response.statusCode == 204;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      print('isRepoStarred error: ${e.message}');
      return false;
    }
  }

  static Future<bool> starRepo(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      await _dio(token).put('/user/starred/$owner/$repo');
      return true;
    } on DioException catch (e) {
      print('starRepo error: ${e.message}');
      return false;
    }
  }

  static Future<bool> unstarRepo(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      await _dio(token).delete('/user/starred/$owner/$repo');
      return true;
    } on DioException catch (e) {
      print('unstarRepo error: ${e.message}');
      return false;
    }
  }

  // ═══ COMMITS ═══
  static Future<List<GitHubCommit>> getCommits(
    String token,
    String owner,
    String repo, {
    String? path,
    int perPage = 30,
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/commits',
        queryParameters: {
          'per_page': perPage,
          if (path != null && path.isNotEmpty) 'path': path,
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubCommit.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getCommits error: ${e.message}');
      return [];
    }
  }

  static Future<GitHubCommit?> getCommitDetail(
    String token,
    String owner,
    String repo,
    String sha,
  ) async {
    try {
      final response =
          await _dio(token).get('/repos/$owner/$repo/commits/$sha');
      return GitHubCommit.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getCommitDetail error: ${e.message}');
      return null;
    }
  }

  // ═══ COMMIT DETAIL WITH FILES ═══
  static Future<GitHubCommitDetail?> getCommitWithFiles(
    String token,
    String owner,
    String repo,
    String sha,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/commits/$sha',
      );
      return GitHubCommitDetail.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      print('getCommitWithFiles error: ${e.message}');
      return null;
    }
  }

  // ═══ COMPARE BRANCHES ═══
  static Future<GitHubCompare?> compareBranches(
    String token,
    String owner,
    String repo,
    String base,
    String head,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/compare/$base...$head',
      );
      return GitHubCompare.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('compareBranches error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ═══ FORK REPO ═══
  static Future<Map<String, dynamic>?> forkRepo(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final response = await _dio(token).post('/repos/$owner/$repo/forks');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('forkRepo error: ${e.message}');
      return null;
    }
  }

  static Future<String?> getMyFork(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final me = await getUser(token);
      if (me == null) return null;

      final response = await _dio(token).get(
        '/repos/$owner/$repo/forks',
        queryParameters: {'per_page': 100, 'sort': 'newest'},
      );

      final List<dynamic> forks = response.data as List<dynamic>;
      for (final f in forks) {
        final forkOwner = f['owner']?['login'] as String?;
        if (forkOwner != null && forkOwner == me.login) {
          return f['full_name'] as String?;
        }
      }
      return null;
    } on DioException catch (e) {
      print('getMyFork error: ${e.message}');
      return null;
    }
  }

  // ═══ CREATE ISSUE ═══
  static Future<Map<String, dynamic>?> createIssue(
    String token,
    String owner,
    String repo, {
    required String title,
    String? body,
  }) async {
    try {
      final response = await _dio(token).post(
        '/repos/$owner/$repo/issues',
        data: {
          'title': title,
          if (body != null && body.isNotEmpty) 'body': body,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('createIssue error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ═══ GET ISSUE DETAIL ═══
  static Future<GitHubIssue?> getIssueDetail(
    String token,
    String owner,
    String repo,
    int issueNumber,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/issues/$issueNumber',
      );
      return GitHubIssue.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getIssueDetail error: ${e.message}');
      return null;
    }
  }

  // ═══ GET ISSUE COMMENTS ═══
  static Future<List<GitHubComment>> getIssueComments(
    String token,
    String owner,
    String repo,
    int issueNumber, {
    int perPage = 100,
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/issues/$issueNumber/comments',
        queryParameters: {'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubComment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getIssueComments error: ${e.message}');
      return [];
    }
  }

  // ═══ CREATE COMMENT ═══
  static Future<GitHubComment?> createIssueComment(
    String token,
    String owner,
    String repo,
    int issueNumber,
    String body,
  ) async {
    try {
      final response = await _dio(token).post(
        '/repos/$owner/$repo/issues/$issueNumber/comments',
        data: {'body': body},
      );
      return GitHubComment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('createIssueComment error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ═══ UPDATE ISSUE ═══
  static Future<Map<String, dynamic>?> updateIssue(
    String token,
    String owner,
    String repo,
    int issueNumber, {
    String? title,
    String? body,
    String? state,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (body != null) data['body'] = body;
      if (state != null) data['state'] = state;

      final response = await _dio(token).patch(
        '/repos/$owner/$repo/issues/$issueNumber',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('updateIssue error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ═══ CLOSE ISSUE ═══
  static Future<bool> closeIssue(
    String token,
    String owner,
    String repo,
    int issueNumber,
  ) async {
    try {
      await _dio(token).patch(
        '/repos/$owner/$repo/issues/$issueNumber',
        data: {'state': 'closed'},
      );
      return true;
    } on DioException catch (e) {
      print('closeIssue error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ═══ REOPEN ISSUE ═══
  static Future<bool> reopenIssue(
    String token,
    String owner,
    String repo,
    int issueNumber,
  ) async {
    try {
      await _dio(token).patch(
        '/repos/$owner/$repo/issues/$issueNumber',
        data: {'state': 'open'},
      );
      return true;
    } on DioException catch (e) {
      print('reopenIssue error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ═══ BRANCHES ═══
  static Future<List<GitHubBranch>> getBranches(
    String token,
    String owner,
    String repo, {
    int perPage = 100,
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/branches',
        queryParameters: {'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubBranch.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getBranches error: ${e.message}');
      return [];
    }
  }

  // ═══ PULL REQUESTS (detail PR) ═══
  static Future<GitHubPR?> getPRDetail(
    String token,
    String owner,
    String repo,
    int prNumber,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/pulls/$prNumber',
      );
      return GitHubPR.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getPRDetail error: ${e.message}');
      return null;
    }
  }

  static Future<List<GitHubPR>> getPRs(
    String token,
    String owner,
    String repo, {
    String state = 'open',
    int perPage = 50,
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/pulls',
        queryParameters: {
          'state': state,
          'per_page': perPage,
          'sort': 'updated',
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubPR.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getPRs error: ${e.message}');
      return [];
    }
  }

  // ═══ CREATE PR ═══
  static Future<Map<String, dynamic>?> createPR(
    String token,
    String owner,
    String repo, {
    required String title,
    required String head,
    required String base,
    String? body,
    bool draft = false,
  }) async {
    try {
      final response = await _dio(token).post(
        '/repos/$owner/$repo/pulls',
        data: {
          'title': title,
          'head': head,
          'base': base,
          if (body != null && body.isNotEmpty) 'body': body,
          'draft': draft,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('createPR error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ═══ MERGE PR ═══
  static Future<bool> mergePR(
    String token,
    String owner,
    String repo,
    int prNumber, {
    String? commitTitle,
    String? commitMessage,
    String mergeMethod = 'merge',
  }) async {
    try {
      await _dio(token).put(
        '/repos/$owner/$repo/pulls/$prNumber/merge',
        data: {
          if (commitTitle != null) 'commit_title': commitTitle,
          if (commitMessage != null) 'commit_message': commitMessage,
          'merge_method': mergeMethod,
        },
      );
      return true;
    } on DioException catch (e) {
      print('mergePR error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ═══ RELEASES ═══
  static Future<List<GitHubRelease>> getReleases(
    String token,
    String owner,
    String repo, {
    int perPage = 30,
  }) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/releases',
        queryParameters: {'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubRelease.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getReleases error: ${e.message}');
      return [];
    }
  }

  static Future<GitHubRelease?> getLatestRelease(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/releases/latest',
      );
      return GitHubRelease.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      print('getLatestRelease error: ${e.message}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createRelease(
    String token,
    String owner,
    String repo, {
    required String tagName,
    String? targetCommitish,
    String? name,
    String? body,
    bool draft = false,
    bool prerelease = false,
  }) async {
    try {
      final response = await _dio(token).post(
        '/repos/$owner/$repo/releases',
        data: {
          'tag_name': tagName,
          if (targetCommitish != null && targetCommitish.isNotEmpty)
            'target_commitish': targetCommitish,
          if (name != null && name.isNotEmpty) 'name': name,
          if (body != null && body.isNotEmpty) 'body': body,
          'draft': draft,
          'prerelease': prerelease,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('createRelease error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  static Future<bool> deleteRelease(
    String token,
    String owner,
    String repo,
    int releaseId,
  ) async {
    try {
      await _dio(token).delete(
        '/repos/$owner/$repo/releases/$releaseId',
      );
      return true;
    } on DioException catch (e) {
      print('deleteRelease error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ═══ CODE SEARCH ═══
  static Future<List<GitHubCodeSearchResult>> searchCode(
    String token,
    String owner,
    String repo,
    String query, {
    int perPage = 30,
  }) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio(token).get(
        '/search/code',
        queryParameters: {
          'q': '$query repo:$owner/$repo',
          'per_page': perPage,
        },
      );
      final items = (response.data['items'] as List<dynamic>? ?? <dynamic>[]);
      return items
          .map((e) =>
              GitHubCodeSearchResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('searchCode error: ${e.response?.data ?? e.message}');
      return [];
    }
  }

  // ═══ GET FILE CONTENT ═══
  static Future<String?> getFileContent(
    String token,
    String owner,
    String repo,
    String path,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/contents/$path',
        options: Options(
          headers: {'Accept': 'application/vnd.github.raw+json'},
        ),
      );
      return response.data as String?;
    } on DioException catch (e) {
      print('getFileContent error: ${e.message}');
      return null;
    }
  }

  // ═══ GISTS ═══
  static Future<List<GitHubGist>> getMyGists(
    String token, {
    int perPage = 30,
  }) async {
    try {
      final response = await _dio(token).get(
        '/gists',
        queryParameters: {'per_page': perPage},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => GitHubGist.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getMyGists error: ${e.message}');
      return [];
    }
  }

  static Future<GitHubGist?> getGistDetail(
    String token,
    String gistId,
  ) async {
    try {
      final response = await _dio(token).get('/gists/$gistId');
      return GitHubGist.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('getGistDetail error: ${e.message}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createGist(
    String token, {
    required String filename,
    required String content,
    String? description,
    bool public = true,
  }) async {
    try {
      final response = await _dio(token).post(
        '/gists',
        data: {
          'description': description ?? '',
          'public': public,
          'files': {
            filename: {'content': content},
          },
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('createGist error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  static Future<bool> deleteGist(
    String token,
    String gistId,
  ) async {
    try {
      await _dio(token).delete('/gists/$gistId');
      return true;
    } on DioException catch (e) {
      print('deleteGist error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ═══ GITHUB ACTIONS ═══
  static Future<List<GitHubWorkflow>> getWorkflows(
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/actions/workflows',
      );
      final workflowsJson =
          response.data['workflows'] as List<dynamic>? ?? <dynamic>[];
      return workflowsJson
          .map((e) => GitHubWorkflow.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getWorkflows error: ${e.message}');
      return [];
    }
  }

  static Future<List<GitHubWorkflowRun>> getWorkflowRuns(
    String token,
    String owner,
    String repo, {
    int perPage = 30,
    int? workflowId,
  }) async {
    try {
      final endpoint = workflowId == null
          ? '/repos/$owner/$repo/actions/runs'
          : '/repos/$owner/$repo/actions/workflows/$workflowId/runs';
      final response = await _dio(token).get(
        endpoint,
        queryParameters: {'per_page': perPage},
      );
      final runsJson =
          response.data['workflow_runs'] as List<dynamic>? ?? <dynamic>[];
      return runsJson
          .map((e) => GitHubWorkflowRun.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getWorkflowRuns error: ${e.message}');
      return [];
    }
  }

  static Future<List<GitHubWorkflowJob>> getWorkflowRunJobs(
    String token,
    String owner,
    String repo,
    int runId,
  ) async {
    try {
      final response = await _dio(token).get(
        '/repos/$owner/$repo/actions/runs/$runId/jobs',
      );
      final jobsJson =
          response.data['jobs'] as List<dynamic>? ?? <dynamic>[];
      return jobsJson
          .map((e) => GitHubWorkflowJob.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('getWorkflowRunJobs error: ${e.message}');
      return [];
    }
  }
}