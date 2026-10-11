class GitHubReview {
  final int id;
  final String? userLogin;
  final String? userAvatar;
  final String state; // APPROVED, CHANGES_REQUESTED, COMMENTED, PENDING
  final String? body;
  final String? submittedAt;

  GitHubReview({
    required this.id,
    this.userLogin,
    this.userAvatar,
    required this.state,
    this.body,
    this.submittedAt,
  });

  bool get isApproved => state == 'APPROVED';
  bool get isChangesRequested => state == 'CHANGES_REQUESTED';
  bool get isCommented => state == 'COMMENTED';
  bool get isPending => state == 'PENDING';

  String get statusLabel {
    switch (state) {
      case 'APPROVED':
        return 'Approved';
      case 'CHANGES_REQUESTED':
        return 'Changes Requested';
      case 'COMMENTED':
        return 'Commented';
      case 'PENDING':
        return 'Pending';
      default:
        return state;
    }
  }

  String get formattedDate {
    if (submittedAt == null) return '-';
    try {
      final date = DateTime.parse(submittedAt!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '-';
    }
  }

  factory GitHubReview.fromJson(Map<String, dynamic> json) {
    return GitHubReview(
      id: json['id'] as int? ?? 0,
      userLogin: json['user']?['login'] as String?,
      userAvatar: json['user']?['avatar_url'] as String?,
      state: json['state'] as String? ?? 'PENDING',
      body: json['body'] as String?,
      submittedAt: json['submitted_at'] as String?,
    );
  }
}