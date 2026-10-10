class GitHubRepo {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final bool isPrivate;
  final bool isFork;
  final int stargazersCount;
  final int forksCount;
  final int watchersCount;
  final String? language;
  final String? updatedAt;
  final String htmlUrl;

  GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.isPrivate,
    required this.isFork,
    required this.stargazersCount,
    required this.forksCount,
    required this.watchersCount,
    this.language,
    this.updatedAt,
    required this.htmlUrl,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String?,
      isPrivate: json['private'] as bool? ?? false,
      isFork: json['fork'] as bool? ?? false,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      watchersCount: json['watchers_count'] as int? ?? 0,
      language: json['language'] as String?,
      updatedAt: json['updated_at'] as String?,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}