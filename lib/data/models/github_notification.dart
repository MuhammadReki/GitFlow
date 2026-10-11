class GitHubNotification {
  final String id;
  final bool unread;
  final String? reason;
  final String? updatedAt;
  final String? subjectTitle;
  final String? subjectType;
  final String? subjectUrl;
  final String? repoFullName;
  final String? repoOwner;
  final String? repoName;

  GitHubNotification({
    required this.id,
    required this.unread,
    this.reason,
    this.updatedAt,
    this.subjectTitle,
    this.subjectType,
    this.subjectUrl,
    this.repoFullName,
    this.repoOwner,
    this.repoName,
  });

  bool get isUnread => unread;

  String get iconName {
    switch (subjectType) {
      case 'Issue':
        return 'issue';
      case 'PullRequest':
        return 'pr';
      case 'Release':
        return 'release';
      case 'Commit':
        return 'commit';
      case 'Discussion':
        return 'discussion';
      default:
        return 'notification';
    }
  }

  String get reasonLabel {
    switch (reason) {
      case 'mention':
        return 'Kamu di-mention';
      case 'author':
        return 'Kamu author';
      case 'comment':
        return 'Ada komentar';
      case 'review_requested':
        return 'Review diminta';
      case 'assign':
        return 'Kamu di-assign';
      case 'state_change':
        return 'Status berubah';
      case 'subscribed':
        return 'Kamu subscribe';
      case 'team_mention':
        return 'Tim di-mention';
      case 'ci_activity':
        return 'CI activity';
      default:
        return reason ?? 'Notifikasi';
    }
  }

  factory GitHubNotification.fromJson(Map<String, dynamic> json) {
    return GitHubNotification(
      id: json['id']?.toString() ?? '',
      unread: json['unread'] as bool? ?? false,
      reason: json['reason'] as String?,
      updatedAt: json['updated_at'] as String?,
      subjectTitle: json['subject']?['title'] as String?,
      subjectType: json['subject']?['type'] as String?,
      subjectUrl: json['subject']?['url'] as String?,
      repoFullName: json['repository']?['full_name'] as String?,
      repoOwner: json['repository']?['owner']?['login'] as String?,
      repoName: json['repository']?['name'] as String?,
    );
  }
}