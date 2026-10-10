class GitHubCodeSearchResult {
  final String name;
  final String path;
  final String? sha;
  final String? htmlUrl;
  final String? repoFullName;
  final int? score;

  GitHubCodeSearchResult({
    required this.name,
    required this.path,
    this.sha,
    this.htmlUrl,
    this.repoFullName,
    this.score,
  });

  /// Ambil extension / bahasa dari nama file
  String get extension {
    final parts = name.split('.');
    if (parts.length > 1) return parts.last.toLowerCase();
    return '';
  }

  factory GitHubCodeSearchResult.fromJson(Map<String, dynamic> json) {
    return GitHubCodeSearchResult(
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      sha: json['sha'] as String?,
      htmlUrl: json['html_url'] as String?,
      repoFullName: json['repository']?['full_name'] as String?,
      score: json['score'] as int?,
    );
  }
}