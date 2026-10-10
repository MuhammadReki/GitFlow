class GitHubUser {
  final String login;
  final String? name;
  final String? avatarUrl;
  final String? bio;
  final String? company;
  final String? location;
  final String? blog;
  final String? twitterUsername;
  final String? email;
  final String? hireable;
  final int publicRepos;
  final int publicGists;
  final int followers;
  final int following;
  final String? createdAt;
  final String? updatedAt;
  final String? htmlUrl;

  GitHubUser({
    required this.login,
    this.name,
    this.avatarUrl,
    this.bio,
    this.company,
    this.location,
    this.blog,
    this.twitterUsername,
    this.email,
    this.hireable,
    this.publicRepos = 0,
    this.publicGists = 0,
    this.followers = 0,
    this.following = 0,
    this.createdAt,
    this.updatedAt,
    this.htmlUrl,
  });

  /// Format tanggal join тЖТ "Joined Jan 2020"
  String get joinedDate {
    if (createdAt == null) return '-';
    try {
      final date = DateTime.parse(createdAt!);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return 'Joined ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '-';
    }
  }

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] as String? ?? 'unknown',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      location: json['location'] as String?,
      blog: json['blog'] as String?,
      twitterUsername: json['twitter_username'] as String?,
      email: json['email'] as String?,
      hireable: json['hireable']?.toString(),
      publicRepos: json['public_repos'] as int? ?? 0,
      publicGists: json['public_gists'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      htmlUrl: json['html_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'login': login,
        'name': name,
        'avatar_url': avatarUrl,
        'bio': bio,
        'company': company,
        'location': location,
        'blog': blog,
        'twitter_username': twitterUsername,
        'email': email,
        'hireable': hireable,
        'public_repos': publicRepos,
        'public_gists': publicGists,
        'followers': followers,
        'following': following,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'html_url': htmlUrl,
      };
}