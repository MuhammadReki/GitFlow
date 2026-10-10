class GitHubRepo {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final int watchersCount;
  final int openIssuesCount;
  final bool isPrivate;
  final bool isFork;
  final String? htmlUrl;
  final String? defaultBranch;
  final String? updatedAt;

  GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    this.language,
    this.stargazersCount = 0,
    this.forksCount = 0,
    this.watchersCount = 0,
    this.openIssuesCount = 0,
    this.isPrivate = false,
    this.isFork = false,
    this.htmlUrl,
    this.defaultBranch,
    this.updatedAt,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String?,
      language: json['language'] as String?,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      watchersCount: json['watchers_count'] as int? ?? 0,
      openIssuesCount: json['open_issues_count'] as int? ?? 0,
      isPrivate: json['private'] as bool? ?? false,
      isFork: json['fork'] as bool? ?? false,
      htmlUrl: json['html_url'] as String?,
      defaultBranch: json['default_branch'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'full_name': fullName,
        'description': description,
        'language': language,
        'stargazers_count': stargazersCount,
        'forks_count': forksCount,
        'watchers_count': watchersCount,
        'open_issues_count': openIssuesCount,
        'private': isPrivate,
        'fork': isFork,
        'html_url': htmlUrl,
        'default_branch': defaultBranch,
        'updated_at': updatedAt,
      };
}