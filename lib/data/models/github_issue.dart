class GitHubIssue {
  final int number;
  final String title;
  final String? body;
  final String state;
  final String? userLogin;
  final String? userAvatar;
  final int comments;
  final List<String> labels;
  final String? createdAt;
  final String? updatedAt;
  final String? htmlUrl;
  final bool isPullRequest;

  GitHubIssue({
    required this.number,
    required this.title,
    this.body,
    required this.state,
    this.userLogin,
    this.userAvatar,
    this.comments = 0,
    this.labels = const [],
    this.createdAt,
    this.updatedAt,
    this.htmlUrl,
    this.isPullRequest = false,
  });

  bool get isOpen => state == 'open';

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    final labelsJson = json['labels'] as List<dynamic>? ?? [];
    return GitHubIssue(
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      state: json['state'] as String? ?? 'open',
      userLogin: json['user']?['login'] as String?,
      userAvatar: json['user']?['avatar_url'] as String?,
      comments: json['comments'] as int? ?? 0,
      labels: labelsJson
          .map((l) => (l['name'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      htmlUrl: json['html_url'] as String?,
      isPullRequest: json['pull_request'] != null,
    );
  }
}