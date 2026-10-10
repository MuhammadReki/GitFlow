class GitHubCommitFile {
  final String filename;
  final String? status; // added, modified, removed, renamed
  final int additions;
  final int deletions;
  final int changes;
  final String? patch;
  final String? previousFilename;
  final String? blobUrl;
  final String? rawUrl;

  GitHubCommitFile({
    required this.filename,
    this.status,
    this.additions = 0,
    this.deletions = 0,
    this.changes = 0,
    this.patch,
    this.previousFilename,
    this.blobUrl,
    this.rawUrl,
  });

  factory GitHubCommitFile.fromJson(Map<String, dynamic> json) {
    return GitHubCommitFile(
      filename: json['filename'] as String? ?? '',
      status: json['status'] as String?,
      additions: json['additions'] as int? ?? 0,
      deletions: json['deletions'] as int? ?? 0,
      changes: json['changes'] as int? ?? 0,
      patch: json['patch'] as String?,
      previousFilename: json['previous_filename'] as String?,
      blobUrl: json['blob_url'] as String?,
      rawUrl: json['raw_url'] as String?,
    );
  }
}

class GitHubCommitDetail {
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
  final int totalChanges;
  final int additions;
  final int deletions;
  final List<GitHubCommitFile> files;

  GitHubCommitDetail({
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
    this.totalChanges = 0,
    this.additions = 0,
    this.deletions = 0,
    this.files = const [],
  });

  String get shortSha => sha.length >= 7 ? sha.substring(0, 7) : sha;

  String get title {
    if (message == null || message!.isEmpty) return '(no message)';
    return message!.split('\n').first;
  }

  String get body {
    if (message == null || message!.isEmpty) return '';
    final parts = message!.split('\n');
    if (parts.length <= 1) return '';
    return parts.sublist(1).join('\n').trim();
  }

  String get formattedDate {
    if (authorDate == null) return '-';
    try {
      final date = DateTime.parse(authorDate!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
    } catch (_) {
      return '-';
    }
  }

  factory GitHubCommitDetail.fromJson(Map<String, dynamic> json) {
    final commit = json['commit'] as Map<String, dynamic>? ?? {};
    final author = commit['author'] as Map<String, dynamic>? ?? {};
    final committer = commit['committer'] as Map<String, dynamic>? ?? {};
    final ghAuthor = json['author'] as Map<String, dynamic>?;
    final filesJson = json['files'] as List<dynamic>? ?? [];

    return GitHubCommitDetail(
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
      totalChanges: json['stats']?['total'] as int? ?? 0,
      additions: json['stats']?['additions'] as int? ?? 0,
      deletions: json['stats']?['deletions'] as int? ?? 0,
      files: filesJson
          .map((e) => GitHubCommitFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}