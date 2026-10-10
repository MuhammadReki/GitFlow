class GitHubUser {
  final String login;
  final String? name;
  final String? avatarUrl;
  final String? bio;
  final int publicRepos;
  final int followers;
  final int following;
  final String? company;
  final String? location;
  final String? blog;

  GitHubUser({
    required this.login,
    this.name,
    this.avatarUrl,
    this.bio,
    required this.publicRepos,
    required this.followers,
    required this.following,
    this.company,
    this.location,
    this.blog,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] as String? ?? '',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      publicRepos: json['public_repos'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      company: json['company'] as String?,
      location: json['location'] as String?,
      blog: json['blog'] as String?,
    );
  }
}