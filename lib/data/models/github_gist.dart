class GitHubGistFile {
  final String filename;
  final String? type;
  final String? language;
  final int? size;
  final String? rawUrl;
  final String? content;

  GitHubGistFile({
    required this.filename,
    this.type,
    this.language,
    this.size,
    this.rawUrl,
    this.content,
  });

  factory GitHubGistFile.fromJson(String filename, Map<String, dynamic> json) {
    return GitHubGistFile(
      filename: filename,
      type: json['type'] as String?,
      language: json['language'] as String?,
      size: json['size'] as int?,
      rawUrl: json['raw_url'] as String?,
      content: json['content'] as String?,
    );
  }
}

class GitHubGist {
  final String id;
  final String? description;
  final bool public;
  final String? htmlUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? ownerLogin;
  final String? ownerAvatar;
  final Map<String, GitHubGistFile> files;
  final int comments;

  GitHubGist({
    required this.id,
    this.description,
    this.public = false,
    this.htmlUrl,
    this.createdAt,
    this.updatedAt,
    this.ownerLogin,
    this.ownerAvatar,
    this.files = const {},
    this.comments = 0,
  });

  /// Title: description atau nama file pertama
  String get displayTitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    if (files.isNotEmpty) {
      return files.keys.first;
    }
    return 'Untitled Gist';
  }

  /// Ambil filename pertama
  String get firstFilename {
    if (files.isNotEmpty) return files.keys.first;
    return 'file';
  }

  /// Ambil content file pertama
  String get firstContent {
    if (files.isNotEmpty) {
      final first = files.values.first;
      return first.content ?? '';
    }
    return '';
  }

  int get fileCount => files.length;

  String get formattedDate {
    final dateStr = updatedAt ?? createdAt;
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

  factory GitHubGist.fromJson(Map<String, dynamic> json) {
    final filesJson = json['files'] as Map<String, dynamic>? ?? {};
    final filesMap = <String, GitHubGistFile>{};
    filesJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        filesMap[key] = GitHubGistFile.fromJson(key, value);
      }
    });

    return GitHubGist(
      id: json['id'] as String? ?? '',
      description: json['description'] as String?,
      public: json['public'] as bool? ?? false,
      htmlUrl: json['html_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      ownerLogin: json['owner']?['login'] as String?,
      ownerAvatar: json['owner']?['avatar_url'] as String?,
      files: filesMap,
      comments: json['comments'] as int? ?? 0,
    );
  }
}