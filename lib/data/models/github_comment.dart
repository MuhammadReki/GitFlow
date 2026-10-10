class GitHubComment {
  final int id;
  final String? body;
  final String? userLogin;
  final String? userAvatar;
  final String? createdAt;
  final String? updatedAt;
  final String? htmlUrl;

  GitHubComment({
    required this.id,
    this.body,
    this.userLogin,
    this.userAvatar,
    this.createdAt,
    this.updatedAt,
    this.htmlUrl,
  });

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

  factory GitHubComment.fromJson(Map<String, dynamic> json) {
    return GitHubComment(
      id: json['id'] as int? ?? 0,
      body: json['body'] as String?,
      userLogin: json['user']?['login'] as String?,
      userAvatar: json['user']?['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      htmlUrl: json['html_url'] as String?,
    );
  }
}