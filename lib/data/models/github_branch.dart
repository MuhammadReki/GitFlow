class GitHubBranch {
  final String name;
  final String? sha;

  GitHubBranch({required this.name, this.sha});

  factory GitHubBranch.fromJson(Map<String, dynamic> json) {
    return GitHubBranch(
      name: json['name'] as String? ?? '',
      sha: json['commit']?['sha'] as String?,
    );
  }
}