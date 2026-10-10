import 'github_commit_detail.dart';

class GitHubCompare {
  final String status; // ahead, behind, diverged, identical
  final int aheadBy;
  final int behindBy;
  final int totalCommits;
  final List<GitHubCompareCommit> commits;
  final List<GitHubCommitFile> files;
  final String? baseBranch;
  final String? headBranch;

  GitHubCompare({
    required this.status,
    this.aheadBy = 0,
    this.behindBy = 0,
    this.totalCommits = 0,
    this.commits = const [],
    this.files = const [],
    this.baseBranch,
    this.headBranch,
  });

  bool get isIdentical => status == 'identical';
  bool get isAhead => status == 'ahead';
  bool get isBehind => status == 'behind';
  bool get isDiverged => status == 'diverged';

  String get statusLabel {
    switch (status) {
      case 'ahead':
        return 'Ahead by $aheadBy commit${aheadBy > 1 ? 's' : ''}';
      case 'behind':
        return 'Behind by $behindBy commit${behindBy > 1 ? 's' : ''}';
      case 'diverged':
        return 'Diverged тАФ $aheadBy ahead, $behindBy behind';
      case 'identical':
        return 'Identical';
      default:
        return status;
    }
  }

  factory GitHubCompare.fromJson(Map<String, dynamic> json) {
    final commitsJson = json['commits'] as List<dynamic>? ?? [];
    final filesJson = json['files'] as List<dynamic>? ?? [];

    return GitHubCompare(
      status: json['status'] as String? ?? 'unknown',
      aheadBy: json['ahead_by'] as int? ?? 0,
      behindBy: json['behind_by'] as int? ?? 0,
      totalCommits: json['total_commits'] as int? ?? 0,
      commits: commitsJson
          .map((e) =>
              GitHubCompareCommit.fromJson(e as Map<String, dynamic>))
          .toList(),
      files: filesJson
          .map((e) => GitHubCommitFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      baseBranch: json['base_commit']?['commit']?['message'] as String? != null
          ? null
          : null,
    );
  }
}

class GitHubCompareCommit {
  final String sha;
  final String? message;
  final String? authorName;
  final String? authorLogin;
  final String? authorAvatar;
  final String? authorDate;
  final String? htmlUrl;

  GitHubCompareCommit({
    required this.sha,
    this.message,
    this.authorName,
    this.authorLogin,
    this.authorAvatar,
    this.authorDate,
    this.htmlUrl,
  });

  String get shortSha => sha.length >= 7 ? sha.substring(0, 7) : sha;

  String get title {
    if (message == null || message!.isEmpty) return '(no message)';
    return message!.split('\n').first;
  }

  String get formattedDate {
    if (authorDate == null) return '-';
    try {
      final date = DateTime.parse(authorDate!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '-';
    }
  }

  factory GitHubCompareCommit.fromJson(Map<String, dynamic> json) {
    final commit = json['commit'] as Map<String, dynamic>? ?? {};
    final author = commit['author'] as Map<String, dynamic>? ?? {};
    final ghAuthor = json['author'] as Map<String, dynamic>?;

    return GitHubCompareCommit(
      sha: json['sha'] as String? ?? '',
      message: commit['message'] as String?,
      authorName: author['name'] as String?,
      authorDate: author['date'] as String?,
      authorLogin: ghAuthor?['login'] as String?,
      authorAvatar: ghAuthor?['avatar_url'] as String?,
      htmlUrl: json['html_url'] as String?,
    );
  }
}