class GitHubFile {
  final String name;
  final String path;
  final String type; // 'file', 'dir', 'symlink', 'submodule'
  final int? size;
  final String? downloadUrl;
  final String? htmlUrl;
  final String? sha;

  GitHubFile({
    required this.name,
    required this.path,
    required this.type,
    this.size,
    this.downloadUrl,
    this.htmlUrl,
    this.sha,
  });

  bool get isDirectory => type == 'dir';
  bool get isFile => type == 'file';

  factory GitHubFile.fromJson(Map<String, dynamic> json) {
    return GitHubFile(
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      type: json['type'] as String? ?? 'file',
      size: json['size'] as int?,
      downloadUrl: json['download_url'] as String?,
      htmlUrl: json['html_url'] as String?,
      sha: json['sha'] as String?,
    );
  }
}