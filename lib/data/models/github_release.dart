class GitHubRelease {
  final int id;
  final String tagName;
  final String? name;
  final String? body;
  final bool draft;
  final bool prerelease;
  final String? createdAt;
  final String? publishedAt;
  final String? authorLogin;
  final String? authorAvatar;
  final String? htmlUrl;
  final String? tarballUrl;
  final String? zipballUrl;

  GitHubRelease({
    required this.id,
    required this.tagName,
    this.name,
    this.body,
    this.draft = false,
    this.prerelease = false,
    this.createdAt,
    this.publishedAt,
    this.authorLogin,
    this.authorAvatar,
    this.htmlUrl,
    this.tarballUrl,
    this.zipballUrl,
  });

  /// Title: name kalau ada, kalau nggak pake tag_name
  String get displayTitle {
    if (name != null && name!.isNotEmpty) return name!;
    return tagName;
  }

  String get formattedDate {
    final dateStr = publishedAt ?? createdAt;
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '-';
    }
  }

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    return GitHubRelease(
      id: json['id'] as int? ?? 0,
      tagName: json['tag_name'] as String? ?? '',
      name: json['name'] as String?,
      body: json['body'] as String?,
      draft: json['draft'] as bool? ?? false,
      prerelease: json['prerelease'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      publishedAt: json['published_at'] as String?,
      authorLogin: json['author']?['login'] as String?,
      authorAvatar: json['author']?['avatar_url'] as String?,
      htmlUrl: json['html_url'] as String?,
      tarballUrl: json['tarball_url'] as String?,
      zipballUrl: json['zipball_url'] as String?,
    );
  }
}