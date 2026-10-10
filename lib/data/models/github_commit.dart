class GitHubCommit {
  final String sha;
  final String? message;
  final String? authorName;
  final String? authorEmail;
  final String? authorLogin;
  final String? authorAvatar;
  final String? authorDate;
  final String? committerName;
  final String? committerDate;
  final String? htmlUrl;
  final int? totalChanges;
  final int? additions;
  final int? deletions;

  GitHubCommit({
    required this.sha,
    this.message,
    this.authorName,
    this.authorEmail,
    this.authorLogin,
    this.authorAvatar,
    this.authorDate,
    this.committerName,
    this.committerDate,
    this.htmlUrl,
    this.totalChanges,
    this.additions,
    this.deletions,
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

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    final commit = json['commit'] as Map<String, dynamic>? ?? {};
    final author = commit['author'] as Map<String, dynamic>? ?? {};
    final committer = commit['committer'] as Map<String, dynamic>? ?? {};
    final ghAuthor = json['author'] as Map<String, dynamic>?;

    return GitHubCommit(
      sha: json['sha'] as String? ?? '',
      message: commit['message'] as String?,
      authorName: author['name'] as String?,
      authorEmail: author['email'] as String?,
      authorDate: author['date'] as String?,
      committerName: committer['name'] as String?,
      committerDate: committer['date'] as String?,
      authorLogin: ghAuthor?['login'] as String?,
      authorAvatar: ghAuthor?['avatar_url'] as String?,
      htmlUrl: json['html_url'] as String?,
      totalChanges: json['stats']?['total'] as int?,
      additions: json['stats']?['additions'] as int?,
      deletions: json['stats']?['deletions'] as int?,
    );
  }
}