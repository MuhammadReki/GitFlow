class GitHubPR {
  final int number;
  final String title;
  final String? body;
  final String state; // open, closed
  final bool merged;
  final bool? mergeable;
  final String? mergedAt;
  final String? mergedBy;
  final String? headBranch;
  final String? baseBranch;
  final String? userLogin;
  final String? userAvatar;
  final String? createdAt;
  final String? updatedAt;
  final String? htmlUrl;
  final int comments;
  final int additions;
  final int deletions;
  final int changedFiles;
  final List<String> labels;
  final bool draft;

  GitHubPR({
    required this.number,
    required this.title,
    this.body,
    required this.state,
    this.merged = false,
    this.mergeable,
    this.mergedAt,
    this.mergedBy,
    this.headBranch,
    this.baseBranch,
    this.userLogin,
    this.userAvatar,
    this.createdAt,
    this.updatedAt,
    this.htmlUrl,
    this.comments = 0,
    this.additions = 0,
    this.deletions = 0,
    this.changedFiles = 0,
    this.labels = const [],
    this.draft = false,
  });

  bool get isOpen => state == 'open' && !merged;
  bool get isClosed => state == 'closed' && !merged;
  bool get isMerged => merged;

  String get statusLabel {
    if (merged) return 'Merged';
    if (state == 'closed') return 'Closed';
    if (draft) return 'Draft';
    return 'Open';
  }

  String get formattedDate {
    if (createdAt == null) return '-';
    try {
      final date = DateTime.parse(createdAt!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '-';
    }
  }

  factory GitHubPR.fromJson(Map<String, dynamic> json) {
    final labelsJson = json['labels'] as List<dynamic>? ?? [];
    return GitHubPR(
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      state: json['state'] as String? ?? 'open',
      merged: json['merged'] as bool? ?? false,
      mergeable: json['mergeable'] as bool?,
      mergedAt: json['merged_at'] as String?,
      mergedBy: json['merged_by']?['login'] as String?,
      headBranch: json['head']?['ref'] as String?,
      baseBranch: json['base']?['ref'] as String?,
      userLogin: json['user']?['login'] as String?,
      userAvatar: json['user']?['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      htmlUrl: json['html_url'] as String?,
      comments: json['comments'] as int? ?? 0,
      additions: json['additions'] as int? ?? 0,
      deletions: json['deletions'] as int? ?? 0,
      changedFiles: json['changed_files'] as int? ?? 0,
      labels: labelsJson
          .map((l) => (l['name'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      draft: json['draft'] as bool? ?? false,
    );
  }
}