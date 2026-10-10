class GitHubWorkflow {
  final int id;
  final String name;
  final String path;
  final String state; // active, disabled, etc

  GitHubWorkflow({
    required this.id,
    required this.name,
    required this.path,
    required this.state,
  });

  factory GitHubWorkflow.fromJson(Map<String, dynamic> json) {
    return GitHubWorkflow(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      state: json['state'] as String? ?? 'unknown',
    );
  }
}

class GitHubWorkflowRun {
  final int id;
  final String? name;
  final int? runNumber;
  final String? event;
  final String status; // queued, in_progress, completed
  final String? conclusion; // success, failure, cancelled, skipped, etc
  final String? headBranch;
  final String? headSha;
  final String? actorLogin;
  final String? actorAvatar;
  final String? createdAt;
  final String? updatedAt;
  final String? htmlUrl;
  final int? runAttempt;
  final int? workflowId;

  GitHubWorkflowRun({
    required this.id,
    this.name,
    this.runNumber,
    this.event,
    required this.status,
    this.conclusion,
    this.headBranch,
    this.headSha,
    this.actorLogin,
    this.actorAvatar,
    this.createdAt,
    this.updatedAt,
    this.htmlUrl,
    this.runAttempt,
    this.workflowId,
  });

  bool get isSuccess => conclusion == 'success';
  bool get isFailure => conclusion == 'failure';
  bool get isInProgress => status == 'in_progress' || status == 'queued';
  bool get isCancelled => conclusion == 'cancelled';
  bool get isSkipped => conclusion == 'skipped';
  bool get isCompleted => status == 'completed';

  String get statusLabel {
    if (isInProgress) {
      return status == 'queued' ? 'Queued' : 'Running';
    }
    if (conclusion == null) return 'Unknown';
    return conclusion![0].toUpperCase() + conclusion!.substring(1);
  }

  String get shortSha {
    if (headSha == null) return '-';
    return headSha!.length >= 7 ? headSha!.substring(0, 7) : headSha!;
  }

  String get formattedDate {
    final dateStr = updatedAt ?? createdAt;
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
    } catch (_) {
      return '-';
    }
  }

  /// Durasi dari created ke updated (kalau udah kelar)
  String get duration {
    if (createdAt == null || updatedAt == null) return '-';
    try {
      final start = DateTime.parse(createdAt!);
      final end = DateTime.parse(updatedAt!);
      final diff = end.difference(start);
      if (diff.inMinutes < 1) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ${diff.inSeconds % 60}s';
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    } catch (_) {
      return '-';
    }
  }

  factory GitHubWorkflowRun.fromJson(Map<String, dynamic> json) {
    return GitHubWorkflowRun(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      runNumber: json['run_number'] as int?,
      event: json['event'] as String?,
      status: json['status'] as String? ?? 'queued',
      conclusion: json['conclusion'] as String?,
      headBranch: json['head_branch'] as String?,
      headSha: json['head_sha'] as String?,
      actorLogin: json['actor']?['login'] as String?,
      actorAvatar: json['actor']?['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      htmlUrl: json['html_url'] as String?,
      runAttempt: json['run_attempt'] as int?,
      workflowId: json['workflow_id'] as int?,
    );
  }
}

class GitHubWorkflowJob {
  final int id;
  final String name;
  final String status;
  final String? conclusion;
  final String? startedAt;
  final String? completedAt;
  final String? htmlUrl;

  GitHubWorkflowJob({
    required this.id,
    required this.name,
    required this.status,
    this.conclusion,
    this.startedAt,
    this.completedAt,
    this.htmlUrl,
  });

  bool get isSuccess => conclusion == 'success';
  bool get isFailure => conclusion == 'failure';
  bool get isInProgress => status == 'in_progress' || status == 'queued';

  String get statusLabel {
    if (isInProgress) {
      return status == 'queued' ? 'Queued' : 'Running';
    }
    if (conclusion == null) return 'Unknown';
    return conclusion![0].toUpperCase() + conclusion!.substring(1);
  }

  factory GitHubWorkflowJob.fromJson(Map<String, dynamic> json) {
    return GitHubWorkflowJob(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'queued',
      conclusion: json['conclusion'] as String?,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
      htmlUrl: json['html_url'] as String?,
    );
  }
}